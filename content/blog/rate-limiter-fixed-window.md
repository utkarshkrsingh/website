+++
date = '2026-10-07T22:25:46+05:30'
draft = false
title = 'One Window, N Requests: Building a Rate Limiter from Scratch in Go'
+++

## Why Does a Rate Limiter Exist?

Suppose you build a REST API for some business purpose and deploy it. Suddenly, one morning, you see that your server has crashed due to an overwhelming number of incoming requests.

Now you're thinking:

*How am I supposed to handle this many requests?*

The most basic answer is to implement a **rate limiter middleware** for incoming requests.

Then you might be thinking:

*What is the benefit of using a rate limiter?*

A rate limiter helps in many ways. Some of them are:

- Reduces the risk of resource abuse and Denial-of-Service (DoS) attacks, improving performance, reliability, and security.
- Helps manage traffic to web servers, APIs, network resources, and database access.
- Ensures fair resource usage among multiple users.

Today, I implemented a similar rate limiter using the **Fixed Window** algorithm.

## Fixed Window Algorithm

The Fixed Window algorithm counts requests within discrete, non-overlapping time intervals.

For example, we can divide time into fixed-length windows of 10 seconds:

```text
Window 1: 0s  ───────── 10s
           max 5 requests

Window 2: 10s ───────── 20s
           max 5 requests

Window 3: 20s ───────── 30s
           max 5 requests
```

Each window gets its own counter. Every request increments the counter, and once the counter reaches the limit, further requests are denied until the current window expires.

When a new window starts, the counter is reset.

### Implementation in Go

This is the implementation of an in-memory **Fixed Window** algorithm that I implemented from scratch.

```go
// algo.go
package fixedwindow

import (
	"sync"
	"time"
)

// FixedWindow keeps track of how many requests a single client
// has made during the current time window.
type FixedWindow struct {
	count       int
	capacity    int
	windowSize  time.Duration
	windowStart time.Time
	mu          sync.Mutex
}

func NewFixedWindow(capacity int, windowSize time.Duration) *FixedWindow {
	return &FixedWindow{
		capacity:   capacity,
		windowSize: windowSize,

		// The window starts when this limiter is created.
		windowStart: time.Now(),
	}
}

func (fw *FixedWindow) Allow() bool {
	// A client can make requests concurrently, so we need to make
	// checking and updating the counter one atomic operation.
	fw.mu.Lock()
	defer fw.mu.Unlock()

	now := time.Now()

	// Once the current window expires, start a fresh one.
	if now.Sub(fw.windowStart) >= fw.windowSize {
		fw.count = 0
		fw.windowStart = now
	}

	// The client has already used all the requests allowed
	// for this window.
	if fw.capacity <= fw.count {
		return false
	}

	fw.count++
	return true
}

func (fw *FixedWindow) RequestsRemaining() int {
	fw.mu.Lock()
	defer fw.mu.Unlock()

	now := time.Now()

	// Lazily reset the window instead of running a timer for every client.
	if now.Sub(fw.windowStart) >= fw.windowSize {
		fw.count = 0
		fw.windowStart = now
	}

	return fw.capacity - fw.count
}

func (fw *FixedWindow) Expired() bool {
	fw.mu.Lock()
	defer fw.mu.Unlock()

	// Used by the parent rate limiter to remove clients
	// whose current window has expired.
	return time.Since(fw.windowStart) >= fw.windowSize
}
```

## Managing Multiple Clients

The `FixedWindow` implementation above manages the rate limit for a single client.

But in a real API, there will be multiple clients. We need to maintain a separate `FixedWindow` for each client.

For example:

```text
Client A → FixedWindow
Client B → FixedWindow
Client C → FixedWindow
Client D → FixedWindow
```

For this, I created an `InMemoryRateLimiter`.

```go
// rateLimiter.go
package fixedwindow

import (
	"sync"
	"time"
)

type InMemoryRateLimiter struct {
	// Each key gets its own FixedWindow. sync.Map lets us safely
	// access these client limiters from multiple goroutines.
	clients    sync.Map
	capacity   int
	windowSize time.Duration

	// Instead of keeping expired clients forever, we periodically
	// look for clients whose windows have expired and remove them.
	cleanupInterval time.Duration

	// Closing this channel tells the cleanup goroutine to stop.
	stopCleanup chan struct{}

	// Close() can safely be called more than once.
	closeOnce sync.Once
}

func NewInMemoryRateLimiter(
	capacity int,
	windowSize time.Duration,
	cleanupInterval time.Duration,
) *InMemoryRateLimiter {
	rateLimiter := &InMemoryRateLimiter{
		capacity:        capacity,
		windowSize:      windowSize,
		cleanupInterval: cleanupInterval,
		stopCleanup:     make(chan struct{}),
	}

	// Cleanup runs in the background so expired clients don't
	// keep occupying memory indefinitely.
	go rateLimiter.startCleanup()

	return rateLimiter
}

func (rl *InMemoryRateLimiter) Allow(key string) bool {
	// If we already have a limiter for this client, use it.
	if client, ok := rl.clients.Load(key); ok {
		return client.(*FixedWindow).Allow()
	}

	// This is the first request we've seen for this client,
	// so create a new window for them.
	newClient := NewFixedWindow(rl.capacity, rl.windowSize)

	// Multiple requests for a new client could arrive at the same time.
	// LoadOrStore makes sure only one limiter is actually stored.
	actual, _ := rl.clients.LoadOrStore(key, newClient)

	// Use the limiter that ended up in the map. It might be the one
	// we just created, or one created by another goroutine.
	return actual.(*FixedWindow).Allow()
}

func (rl *InMemoryRateLimiter) startCleanup() {
	ticker := time.NewTicker(rl.cleanupInterval)
	defer ticker.Stop()

	for {
		select {
		case <-ticker.C:
			// Periodically remove clients whose windows have expired.
			rl.cleanup()

		case <-rl.stopCleanup:
			// The rate limiter is shutting down, so the background
			// cleanup goroutine can exit.
			return
		}
	}
}

func (rl *InMemoryRateLimiter) cleanup() {
	// sync.Map allows us to safely range over the clients while
	// other goroutines may still be adding, using, or removing clients.
	rl.clients.Range(func(key, value any) bool {
		client := value.(*FixedWindow)

		// If the client's current window has expired, we no longer
		// need to keep its state in memory.
		if client.Expired() {
			rl.clients.Delete(key)
		}

		return true
	})
}

func (rl *InMemoryRateLimiter) Stats() int {
	count := 0

	// Useful for observing how many client limiters are currently
	// being kept in memory.
	rl.clients.Range(func(key, value any) bool {
		count++
		return true
	})

	return count
}

func (rl *InMemoryRateLimiter) Close() {
	// Closing an already-closed channel panics, so sync.Once makes
	// shutdown safe even if Close() is called multiple times.
	rl.closeOnce.Do(func() {
		close(rl.stopCleanup)
	})
}
```

## Using It as Middleware

After this, we can use it as a rate limiter middleware before every incoming request gets processed:

```go
// middleware/rateLimiter.go
package middleware

import (
	fixedwindow "go-rate-limiting/internal/rate-limiting/fixed-window"
	"net"
	"net/http"
)

func RateLimiter(
	limiter *fixedwindow.InMemoryRateLimiter,
) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			host, _, err := net.SplitHostPort(r.RemoteAddr)
			if err != nil {
				http.Error(
					w,
					"unable to split host from port",
					http.StatusBadRequest,
				)
				return
			}

			if !limiter.Allow(host) {
				http.Error(
					w,
					"rate limit exceeded",
					http.StatusTooManyRequests,
				)
				return
			}

			next.ServeHTTP(w, r)
		})
	}
}
```

The middleware checks whether the client has exceeded its rate limit before passing the request to the next handler.

If the limit has been exceeded, we return:

```text
HTTP 429 Too Many Requests
```

Otherwise, the request continues normally.

## Conclusion

This was my implementation of an in-memory **Fixed Window rate limiter in Go**.

The algorithm itself is fairly straightforward, but implementing it made me think about several other things as well, such as concurrent requests, managing state for multiple clients, cleaning up expired clients, and using the limiter as HTTP middleware.

While testing it with `curl`, I also came across an interesting detail with `RemoteAddr`.

Initially, I was using `r.RemoteAddr` directly as the client key. But I noticed that every request was getting a different value:

```text
[::1]:52139
[::1]:52140
[::1]:52141
[::1]:52142
```

It looked like the IP address was changing with every request.

But the actual IP was the same:

```text
[::1]
```

The changing part was the ephemeral TCP port.

So instead of using `r.RemoteAddr` directly, I used `net.SplitHostPort()` to extract only the host:

```go
host, _, err := net.SplitHostPort(r.RemoteAddr)
```

Now all requests from the same IP are correctly handled by the same rate-limit bucket.

There is still a lot that can be improved here. This is an **in-memory** implementation, so if the API is running on multiple instances, each instance will have its own rate limiter and counters.

The next step would be to use something like **Redis** to maintain shared rate-limit state across multiple instances.

But for now, this was a good exercise in understanding the Fixed Window algorithm and implementing it from scratch.

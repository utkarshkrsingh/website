+++
date = '2026-09-14T14:36:42+05:30'
draft = false
title = "Functional Interfaces in Java: It's Not Just About One Method"
+++
## Functional Interfaces in Java: It's Not Just About One Method

When we first learn about **functional interfaces** in Java, the definition seems pretty simple:

> A functional interface is an interface that contains exactly one abstract method.

This is also known as a **SAM (Single Abstract Method)** interface.

For example:

```java
@FunctionalInterface
interface DemoInterface {
    void work();
}
```

There is only one method, and it is abstract. So, `DemoInterface` is clearly a functional interface.

But now consider this:

```java
@FunctionalInterface
interface AnotherInterface {
    void work();

    default void print() {
        System.out.println("Hello, World");
    }
}
```

At first glance, something seems wrong.

There are **two methods** in the interface. So how can Java still consider `AnotherInterface` a functional interface?

### The Important Part: Abstract Methods

The key here is that Java isn't asking:

> "Does this interface have only one method?"

Instead, it is asking:

> "Does this interface have exactly one **qualifying abstract method**?"

In our example:

```java
void work();
```

is an abstract method.

But:

```java
default void print() {
    System.out.println("Hello, World");
}
```

is a **default method**. It already has an implementation, so it does not count toward the single abstract method requirement.

Therefore, `AnotherInterface` still has exactly **one abstract method**, making it a valid functional interface.

### So, What Exactly Is a Functional Interface?

We can now refine our original definition:

> A **functional interface** is an interface that has exactly one abstract method, while `default` and `static` methods do not count toward that requirement. Methods that correspond to public methods of `Object` also do not count as additional abstract methods.

This is a more complete definition than simply saying *"an interface with one method."*

And that's an important distinction.

A functional interface **can have multiple methods**. What matters is that only **one abstract method qualifies as its functional method**.

### A Real-World Example: `Comparator`

A great example of this is Java's `Comparator` interface.

`Comparator` is a functional interface because its primary abstract method is:

```java
int compare(T o1, T o2);
```

At the same time, `Comparator` contains several other methods, including `default` and `static` methods.

It also declares:

```java
boolean equals(Object obj);
```

But this does not turn `Comparator` into a non-functional interface. `equals()` corresponds to the public `equals()` method inherited from `Object`, so it does not count as another abstract method for the purpose of determining whether the interface is functional.

### The Mental Model to Remember

This is probably the most useful way to think about functional interfaces:

> **Functional interface ≠ interface with only one method.**

Instead:

> **Functional interface = interface with exactly one qualifying abstract method.**

Once this distinction is clear, lambda expressions and method references become much easier to understand, because Java only needs that **one abstract method** to determine what the lambda or method reference represents.

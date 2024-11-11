+++
title = 'Runsync'
date = 2024-11-03T01:55:44+05:30
draft = false
+++

I recently started working on a project, and I generally use Neovim as my code editor. However, to compile the program, I had to exit Neovim, compile and run the code, and then reopen Neovim. Since I tend to be a bit lazy, I disliked having to compile and run things repeatedly. So, I came up with an idea for a program that monitors a specified directory. If any file is modified, it checks the file type against a config file, and if an entry exists, it compiles and runs the file.

I chose Go as the language for this project. Since I am currently learning it, this project gives me valuable insight into system-level programming in Go. I named the program "runsync"—not the best name, but it serves the purpose. At this stage, runsync doesn’t support a config file and only works with Python, Go, C, and C++. Support for a config file is planned for a future release. I haven’t considered cross-platform compatibility yet, so I’m not sure if I’ll make it compatible with Windows or macOS.

#### What does runsync use under the hood ?
There is a Linux service called [inotify](https://man7.org/linux/man-pages/man7/inotify.7.html), which monitors every directory in the file system and keeps track of the files within it. All file explorers use it to manage file accessibility. I used [fsnotify](https://github.comfanotify/fsnotify), a Go module that provides bindings for inotify, enabling its use in Go. Additionally, I used [faith/color](https://github.com/faith/color), a module that adds color to terminal text.

#### What do I think about runsync ?
It’s a great project for Linux users who want to gain a deeper understanding of how file systems work in Linux. I believe anyone using Linux should try coding a similar program in the language of their choice. While runsync may seem simple at first glance, it has a depth that makes it an interesting project. In the end, I encourage everyone to give it a try and see how far they can take it. Creating new programs is the core purpose of a programmer, and making it exceptional adds a personal touch as a skilled programmer. Thank you.

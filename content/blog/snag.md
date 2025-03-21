+++
title = 'Snag'
date = 2024-11-11T01:55:44+05:30
draft = false
+++

I recently started working on a project and generally use Neovim as my code editor. However, I had to exit Neovim to compile and run my code, then reopen it, which became inconvenient. To streamline the process, I came up with an idea for a program that monitors a specified directory for file modifications. If any file is modified, it checks the file type against a config file. If a match is found, it automatically compiles and runs the file.

I chose Go as the language for this project. Since I am currently learning it, this project gives me valuable insight into system-level programming in Go. I named the program "snag"—not the best name, but it serves the purpose. At this stage, snag doesn’t support a config file and only works with Python, Go, C, and C++. Support for a config file is planned for a future release. I haven’t considered cross-platform compatibility yet, so I’m not sure if I’ll make it compatible with Windows or macOS.

#### What does snag use under the hood ?
There is a Linux service called [inotify](https://man7.org/linux/man-pages/man7/inotify.7.html), which monitors every directory in the file system and keeps track of the files within it. All file explorers use it to manage file accessibility. I used [fsnotify](https://github.com/fsnotify/fsnotify), a Go module that provides bindings for inotify, enabling its use in Go. Additionally, I used [fatih/color](https://github.com/fatih/color), a module that adds color to terminal text.

#### What do I think about snag ?
It’s a great project for Linux users who want to gain a deeper understanding of how file systems work in Linux. I believe anyone using Linux should try coding a similar program in the language of their choice. While snag may seem simple at first glance, it has a depth that makes it an interesting project. In the end, I encourage everyone to give it a try and see how far they can take it. Creating new programs is the core purpose of a programmer, and making it exceptional adds a personal touch as a skilled programmer. Thank you. I will keep you updated on the progress of this project.

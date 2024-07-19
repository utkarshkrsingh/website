+++
title = 'std::endl vs \n'
date = 2024-07-19T23:22:45+05:30
draft = false
+++

C++ offers multiple ways to insert newline in your output. You might encounter `std::endl` and `'\n'` used for this purpose. But are they exactly the same. While they appear to achieve identical results, there is a slight yet significant difference between the two!

When we use `std::cout` it sends the data to the console. However, that output is typically not sent to the console immediately. Instead, the requested output "gets in line", and is stored in a region of memory set aside to collect such requests (called a buffer). Periodically, the buffer is flushed, meaning all of the data collected in the buffer is transferred to its destination (in this case, the console).

## `std::endl` vs `'\n'`
Using `std::endl` is often inefficient, as it actually does two jobs: it outpus a newline (moving the cursor to the next line of the console), and it flushes the buffer (which is slow). If we output multiple lines of text ending with `std::endl`, we will get multiple flushes, which is slow and probably unnecessay.

When we output text to the console, we rarely need to flush the buffer directly. The output system in C++ is meant to flush itself on a regular basis, and allowing it to do so is both easier and more efficient.

To output a newline without flushing the output buffer, we use `\n` (in single or double quotes), a special symbol that the compiler recognizes as a newline character. `\n` moves the cursor to the next line of the console without causing a flush, resulting in better performance. `\n` is also easier to type and can be inserted into existing double-quoted text.

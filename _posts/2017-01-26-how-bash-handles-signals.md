---
layout: post
title:  Signal handling and What Bash Does to It
Date:   2017-01-26
categories: computer-science
commentIssueId:
---


If you are looking for a gentle introduction to signals on linux or a
tutorial on using `trap` to handle signals in bash script, this
article is not for you. Instead, I will recount my encounter with a
rare bug when testing signal handling in C inside bash driver script.
Remember, man pages are your best friends when coding in C, and
[signal(7)](http://man7.org/linux/man-pages/man7/signal.7.html)
is your savior.

Here is a simple C program that ignores signal 1 (`SIGHUP`) and
handles signal 15 (`SIGTERM`) with a custom handler using
[signal(2)](http://man7.org/linux/man-pages/man2/signal.2.html),
then waits for signal with
[pause(2)](http://man7.org/linux/man-pages/man2/pause.2.html).

```c
/* sig.c */
#include <unistd.h>
#include <stdio.h>
#include <signal.h>

void handler(int sig)
{
    const char msg[] = "SIGTERM caught\n";
    if (SIGTERM == sig) {
        /* do not use printf inside signal handler */
        write(STDERR_FILENO, msg, sizeof(msg)-1);
    }
}

int main()
{
    /* maybe use sigaction instead */
    signal(SIGHUP, SIG_IGN);
    signal(SIGTERM, handler);
    pause();
    return 0;
}
```

An important detail that many people overlook when handling signals in
C is that it is not safe to use `printf` inside a signal handler! Here
is a short answer from a stackoverflow:

> The primary problem is that if the signal interrupts malloc() or
> some similar function, the internal state may be temporarily
> inconsistent while it is moving blocks of memory between the free
> and used list, or other similar operations. If the code in the
> signal handler calls a function that then invokes malloc(), this may
> completely wreck the memory management.

I will not give more details here in this brief post. But these
articles are great references that you should checkout.

 - [stackoverflow answer](http://stackoverflow.com/a/16891799/5478848)
 - [article from IBM](http://www.ibm.com/developerworks/linux/library/l-reent/index.html)


Then I compile the program with gcc, and run it in bash
interactively, in which case everything works perfectly.

```sh
$ gcc sig.c
$ ./a.out &
[1] 3218
$ kill -TERM 3209
SIGTERM caught
[1]+  Done                    ./a.out
```

As you can see, the program works as expected by writing to `stderr`
and exit normally when I send `SIGTERM` to it. Also the program did
ignore `SIGHUP`, and was interrupted on `SIGINT`, which I did not
handle, shown as follows.

```sh
$ ./a.out &
[1] 3209
$ kill -HUP 3209
$ kill -INT 3209
[1]+  Interrupt               ./a.out
```

But when I put my commands in a bash script, weird things happened.

```sh

```

Some explanation:

 - `$!` is a special bash variable which stores the PID of last job run
   in background.
 - `kill -0 <PID>` is used to check for the existence of a process
   ID. This `kill` invoked from bash should be a shell builtin rather
   than `/usr/bin/kill`. See
   [kill(2)](http://man7.org/linux/man-pages/man2/kill.2.html)
   for more detail. Here is some relevant quote.

> If sig is 0, then no signal is sent, but error checking is still
> performed; this can be used to check for the existence of a
> process ID or process group ID.

How a command is executed in
[bash source code](http://git.savannah.gnu.org/cgit/bash.git/tree/execute_cmd.c#n5095)

[bash signals](https://www.gnu.org/software/bash/manual/html_node/Signals.html)

[signal handling in linux](http://www.alexonlinux.com/signal-handling-in-linux)

---
layout: post
title:  Signal Handling and What Bash Does to It
Date:   2017-01-27
categories: computer-science
commentIssueId: 13
---


If you are looking for a gentle introduction to signals on linux or a
tutorial on using `trap` to handle signals in bash script, this
article is not for you. This article
[signal handling in linux](http://www.alexonlinux.com/signal-handling-in-linux)
serves as a good introduction. Instead, I will recount my encounter
with a rare bug when testing signal handling in C inside bash driver
script.

Signal handling is hard since it is asynchronous by nature, and it is
going to be a lot messier when multithreading is involved. Luckily, I
am only doing single threaded programs here.
Remember, man pages are your best friends when coding in C, and
[signal(7)](http://man7.org/linux/man-pages/man7/signal.7.html)
is your savior.


## Signal Handling Program in C

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


## Bash Driver Script

But when I put my commands in a bash script `sig.sh`, weird things
happened.

```sh
#!/bin/bash

set -e

./sig &
pid=$!
echo $pid

# if we don't sleep, ./sig process might be sent SIGHUP before execve
sleep 1
echo "send SIGHUP to process $pid"
# send SIGHUP to process
kill -HUP $pid || exit 1
# signal propagation might take time
sleep 1
# check whether process is still alive
kill -0 $pid || exit 1

# process should still be alive since we ignored SIGHUP

echo "send SIGINT to process $pid"
# send SIGINT to process
kill -INT $pid || exit 1
# signal propagation might take time
sleep 1
# check whether process is still alive
kill -0 $pid && { echo "process $pid still alive"; }
```

Some explanation:

 - `$!` is a special bash variable which stores the PID of last job run
   in background.
 - `kill -0 <PID>` is used to check for the existence of a process
   ID. This `kill` invoked from bash should be a shell builtin rather
   than `/usr/bin/kill`. See
   job control builtin [`kill` for bash(1)](https://www.gnu.org/software/bash/manual/bashref.html#Job-Control-Builtins)
   and [kill(2)](http://man7.org/linux/man-pages/man2/kill.2.html)
   for more detail. Here is the relevant quote from `kill(2)`.

> If sig is 0, then no signal is sent, but error checking is still
> performed; this can be used to check for the existence of a
> process ID or process group ID.

Now execute the script:

```
$ ./sig.sh
3418
send SIGHUP to process 3418
send SIGINT to process 3418
process 3418 still alive
$ pstree -s -p 3418  # -s shows parent processes
systemd(1)───sig(3418)
```

`./sig` process is still alive after `SIGINT` and it became an orphan
process after the bash script process dies.
But wait, why is the process still alive after `SIGINT`? `sig.c`
program does not handle `SIGINT`, and by default `SIGINT` terminates
the process. So what happened here?


## Strace to the Rescue

Now I turn to another best friend of ours,
[strace(1)](http://man7.org/linux/man-pages/man1/strace.1.html).
`strace` traces system calls and signals and print it in a quite human
readable format. It's even more readable than my source code!

```sh
$ strace -f -b execve -o sig.strace ./sig.sh
```

`-f` option makes `strace` trace child process of `./sig.sh` process
as well. `-b execve` makes `strace` detach from traced process when
`execve` is reached. `-o sig.strace` writes the output of `strace` to
the file `sig.strace`. I have reproduced the relevant content of
`sig.strace` below.

```
3814  clone(child_stack=0, flags=CLONE_CHILD_CLEARTID|CLONE_CHILD_SETTID|SIGCHLD, child_tidptr=0x7fb0a8961a10) = 3815
3815  rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
3815  rt_sigaction(SIGTSTP, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_DFL, [], 0}, 8) = 0
3815  rt_sigaction(SIGTTIN, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_DFL, [], 0}, 8) = 0
3815  rt_sigaction(SIGTTOU, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_DFL, [], 0}, 8) = 0
3815  rt_sigaction(SIGINT, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, 8) = 0
3815  rt_sigaction(SIGQUIT, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_IGN, [], SA_RESTORER, 0x7fb0a7f93250}, 8) = 0
3815  rt_sigaction(SIGCHLD, {SIG_DFL, [], SA_RESTORER|SA_RESTART, 0x7fb0a7f93250}, {0x441200, [], SA_RESTORER|SA_RESTART, 0x7fb0a7f93250}, 8) = 0
3815  open("/dev/null", O_RDONLY)       = 3
3815  dup2(3, 0)                        = 0
3815  close(3)                          = 0
3815  rt_sigaction(SIGINT, {SIG_IGN, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, 8) = 0
3815  rt_sigaction(SIGQUIT, {SIG_IGN, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, 8) = 0
3815  execve("./sig", ["./sig"], [/* 24 vars */] <detached ...>
```

So between `fork` (`clone` actually) and `execve`, a lot of things
happended here. In particular, `SIGINT` signal handler has been
installed on the process as shown below. It has been set to `SIG_IGN`,
which ignores `SIGINT` entirely.

```
3815  rt_sigaction(SIGINT, {SIG_IGN, [], SA_RESTORER, 0x7fb0a7f93250}, {SIG_DFL, [], SA_RESTORER, 0x7fb0a7f93250}, 8) = 0
```

Now I found the culprit, it's bash! Bash inserted multiple signal
handlers after we forked, and that's why `SIGINT` cannot terminate
the `./sig` program.

So If I want to restore default `SIGINT` handler to my program, I just
need to add `signal(SIGINT, SIG_DFL);` to the top of the main function
in my `sig.c` program. Problem solved!


## Conclusion

Bash installs signal handler for subcommands executed in bash
scripts. This may not be the desired behavior for a low level signal
handling C program, so ___do not rely on a signal handler being the
default one, but always set it to the default signal handler
explicitly___.

Here the [bash documentation](https://www.gnu.org/software/bash/manual/html_node/Signals.html)
specifies that `SIGINT` is ignored when executed as a asynchronous
command, which is the case in my example above.

> Non-builtin commands started by Bash have signal handlers set to the
> values inherited by the shell from its parent. When job control is
> not in effect, asynchronous commands ignore SIGINT and SIGQUIT in
> addition to these inherited handlers. Commands run as a result of
> command substitution ignore the keyboard-generated job control
> signals SIGTTIN, SIGTTOU, and SIGTSTP.

Also
[bash source code](http://git.savannah.gnu.org/cgit/bash.git/tree/execute_cmd.c?id=bc007799f0e1362100375bb95d952d28de4c62fb#n5095)
provides a good insight on how this is done in bash's C
implementation.

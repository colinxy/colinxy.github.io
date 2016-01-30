---
layout: post
title:  Set up Powerline for Bash, Vim and Emacs
date:   2016-01-30
categories: software-installation
---


This post will try to go through the process of installing
powerline for bash, vim and emacs.


### Prerequisite

This instruction is based on iTerm2 under Mac OS X 10.
For vim, I use vim 7.4 from homebrew, not MacVim. For emacs,
I use emacs 24.5 from homebrew and invoke it in terminal mode
with -nw (I don't like the gui version).

People would wonder why I would post installation guide for
both emacs and vim, and the answer is that since I am a novice
to both editors, I would experiment with both. For now, I
am particularly intrigued by the power of emacs and use it more
often than vim.


### Intro to Powerline

> Powerline is a status line plugin for vim, and provides
> status lines and prompts for several other applications,
> including zsh, bash, tmux, IPython, Awesome, i3 and Qtile.

-- from [powerline documentation](https://powerline.readthedocs.org)

So basically, powerline is just a fancy status line that make
your editor/command prompt look good.

Here are some of my screenshots to get you hooked.

<p style="text-align: center"><strong>Vim</strong></p>
![vim]({{ site.baseurl }}/res/powerline_vim.png)

<p style="text-align: center"><strong>Emacs</strong></p>
![emacs]({{ site.baseurl }}/res/powerline_emacs.png)

<p style="text-align: center"><strong>Bash Prompt</strong></p>
![bash prompt]({{ site.baseurl }}/res/powerline_bash.png)

For some unfathomable reasons, powerline also has many
implementations. [The first one](https://github.com/powerline/powerline)
in the list seems to be the most actively-developed and well-maintained.
[This link](https://github.com/riobard/bash-powerline#see-also)
has a list of major powerline development which I have copied
below.

- [powerline](https://github.com/powerline/powerline): Unified Powerline
  written in Python. This is the future of all Powerline derivatives.
- [vim-powerline](https://github.com/Lokaltog/vim-powerline): Powerline
  in Vim writtien in pure Vimscript. __Deprecated__.
- [tmux-powerline](https://github.com/erikw/tmux-powerline): Powerline
  for Tmux written in Bash script. __Deprecated__.
- [powerline-shell](https://github.com/milkbikis/powerline-shell):
  Powerline for Bash/Zsh/Fish implemented in Python. Might be merged
  into the unified Powerline.
- [emacs powerline](https://github.com/milkypostman/powerline):
  Powerline for Emacs

In this tutorial, we use the first powerline written in Python for
both bash prompt and vim, but not emacs. The emacs powerline is a separate
project, and as any emacs packages, it is written in emacs lisp.


### Powerline for Vim

First, install powerline

`pip install powerline-status`


### Powerline for bash



### Powerline for Emacs

[](http://emacs.stackexchange.com/a/306)

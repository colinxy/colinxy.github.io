---
layout: post
title:  Emacs 25 EasyPG Issue
Date:   2016-09-24
categories: software-installation
commentIssueId: 11
---


Upgrading software is always a hassle. Missing dependencies and
renamed variables alone could make one's life miserable. In a word,
things just break. Even for a mature program like Emacs that has been
around for more than 3 decades.

I recently upgraded emacs 24.5 to 25.1, and most things worked
seamlessly. A really nice feature made available is that
the completion buffer will only pop up as big as needed, a lot
smoother than the previous design of rigidly taking up half of the
window. One new feature that gets me really excited is the Xwidgets.
Just take a look at this snapshot, but take an extra look at the
modeline, meaning that it runs inside emacs.

![snapshot](https://raw.githubusercontent.com/tuhdo/xwidgete/master/demo/emacs_watch_youtube.gif)

*(gif credit to tuhdo)*

Emacs finally has the capability of running as a full
operating system with pretty graphics, though it's still in "alpha"
status. A life entirely inside emacs is possible in the near future.
Unfortunate for Mac OS X users, a homebrew build for emacs with
Xwidgets is still not available currently, but you can always build
from source by yourself.

<br/>

Back to bussiness about EasyPG problem.
The problem starts with gnus being broken in my emacs 25. Initially I
tried to find answers related to gnus, but the error message says
something otherwise.

```
Error while decrypting with "gpg2":

gpg: encrypted with 2048-bit RSA key, ...

gpg: public key decryption failed: Operation cancelled
gpg: decryption failed: No secret key
```

I use `~/.authinfo.gpg` to store my password and emacs automatically
encrypt it with my GnuPG key (great feature! try it).
It complained about not being about to read my password file
`~/.authinfo.gpg` which is protected with my GnuPG passphrase.

Since Emacs use EasyPG as the interface to GnuPG program, we can now
locate the problem to EasyPG. When I tried to open `~/.authinfo.gpg`
file, emacs automatically loads it through EasyPG. But emacs did not
bring up the interface to enter the passphrase for my secret key. Here
is the relevant error message for me.

```
gpg-agent: command get_passphrase failed: inappropriate ioctl for device
```

It looks like that emacs cannot read my passphrase through some interface.

Everywhere I looked, I couldn't find a solution.
But then I came across a [source diff for epa.el for emacs 24.5 and
emacs 25.1](http://fossies.org/diffs/emacs/24.5_vs_25.1/lisp/epa.el-diff.html).
It gives me a nice insight of what is going on inside the epa.el
(EasyPG) source code. I have reproduced the relevant diff below.

```elisp
(defcustom epa-pinentry-mode nil
  "The pinentry mode.

GnuPG 2.1 or later has an option to control the behavior of
Pinentry invocation.  Possible modes are: `ask', `cancel',
`error', and `loopback'.  See the GnuPG manual for the meanings.

In epa commands, a particularly useful mode is `loopback', which
redirects all Pinentry queries to the caller, so Emacs can query
passphrase through the minibuffer, instead of external Pinentry
program."
  :type '(choice (const nil)
                 (const ask)
                 (const cancel)
                 (const error)
                 (const loopback))
  :group 'epa
  :version "25.1")
```

On line 47 of `epa.el` for emacs 25.1, a new variable
`epa-pinentry-mode` is introduced with `defcustom`.
Its documentation says something about the invocation of `pinentry`,
which sounds like the interface for entering the passphrase. And as
the documentation says, by setting `epa-pinentry-mode` to `'loopback`
Emacs will handle querying the passphrase through minibuffer, the
perfect desired behavior.

Now I add this line of code to my `.emacs`, and problem solved! Though
good proctice might add it though `custom-set-variables`.

```elisp
(setf epa-pinentry-mode 'loopback)
```

A caveat if you are a Mac OS X user like I am, is that `brew install
gnupg2` would only install GnuPG 2.0, but not GnuPG 2.1. To install
GnuPG 2.1, you need to do `brew install gnupg21`. The reason for this
design is that GnuPG 2.1 has a new keychain format that is not
compatible with GnuPG 2.0 and GnuPG 1.x.
Somehow emacs 25's EasyPG **only supports GnuPG 2.1 in my case**, so
you might have to look out for that.

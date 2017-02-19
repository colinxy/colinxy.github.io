---
layout: revealjs
title:  Emacs Workshop (Complete Version, 47 slides)
date:   2017-02-17
categories: computer-science
theme: moon
---


<style>
code { background: #3f3f3f; }
</style>

<section data-markdown>
<script type="text/template">

# Emacs Workshop

Colin Yang

Linux User Group @ UCLA

2017-02-21

</script>
</section>


<section data-markdown>
<script type="text/template">

## Emacs overview

 - learning curve

![editor learning curve](/res/editor-learning-curve.png)

</script>
</section>


<section data-markdown>
<script type="text/template">

## Platforms

 - For this workshop, use Emacs 25.1
 - Emacs on seasnet server, use `lnxsrv06`, `lnxsrv07`, `lnxsrv09`
   - add this line to your ~/.bash_profile

 `export PATH=/usr/local/cs/bin:$PATH`

 - Linux should just work
   - install Emacs 25 on Ubuntu

</script>
</section>


<section data-markdown>
<script type="text/template">

## Platforms

 - macOS
   - do not use system Emacs, which is only Emacs 22.1
   - `brew install emacs --with-cocoa`
   - Prefer to use GUI version
   - Meta key in iTerm2
     - Preference -> Profiles -> Keys:
       Left option key acts as `+Esc`

</script>
</section>


<section data-markdown>
<script type="text/template">

## Platforms

 - Windows
   - [Install on Windows](https://www.gnu.org/software/emacs/download.html#windows)
   - Windows bash issues
   - ssh into sesnet server: PuTTY xterm-256color
     - `export TERM=xterm-256color`

</script>
</section>


<section data-markdown>
<script type="text/template">

## Platforms

 - Terminal Emacs vs GUI Emacs
   - GUI Emacs is more capable
     - can display images, pdfs, etc
     - better font handling, more color
     - allows mouse, scrolling
   - some keybindings are not available in terminal Emacs
   - to run emacs without GUI (window system): `emacs -nw`

</script>
</section>


<section data-markdown>
<script type="text/template">

## Emacs Survival

</script>
</section>


<section data-markdown>
<script type="text/template">

### Terminology

<img src="/res/emacs-terminology.png" alt="emacs layout" height="85%" width="85%">

</script>
</section>


<section data-markdown>
<script type="text/template">

### How to read keybindings

 - Meta: usually alt
   - example: `M-g`, hold Meta key, and press `g`
 - Control
   - example: `C-c`, hold Control key, and press `c`
 - combination of these keys
   - `C-h k`: hold Control key, and press `h`, release, then press `k`
   - `C-M-a`: hold Control key, hold Meta key, and press `a`

</script>
</section>


<section data-markdown>
<script type="text/template">

### How to read keybindings

 - `TAB` or `<tab>`: tab key
 - `RET` or `<return>`: enter key
 - `SPC`: space bar
 - keybindings are shortcuts to emacs lisp functions

</script>
</section>


<section data-markdown>
<script type="text/template">

### *Panicking*

 - I just mishit some keys, what do I do?
 - `C-g`: cancel
 - `C-/` or `C-_` or `C-x u`: undo
 - `C-x C-s`: save file
 - `C-x C-c`: close emacs

</script>
</section>


<section data-markdown>
<script type="text/template">

### Getting Help

 - `C-h`: builtin help
   - `C-h C-h`: *HELP!* show a list of available helps
   - `C-h m`: help for current mode
   - `C-h k`: help for keybinding
   - `C-h f`: help for emacs lisp function
 - Google

</script>
</section>


<section data-markdown>
<script type="text/template">

### Basic Movements Within Buffer

 - character
   - `C-f`: Forward *character*
   - `C-b`: Backward *character*
 - word
   - `M-f`: Forward *word*
   - `M-b`: Backward *word*
 - buffer
   - `M->`: end of buffer
   - `M-<`: end of buffer

</script>
</section>


<section data-markdown>
<script type="text/template">

### More Basic Movements Within Buffer

 - line
   - `C-a`: beginning of *line*
   - `C-e`: end of *line*
   - `M-m`: goto first nonspace character on this *line*
   - `C-n`: Next *line*
   - `C-p`: Previous *line*
   - `M-g M-g`: Goto *line*
 - page
   - `C-v`: next *page*
   - `M-v`: previous *page*

</script>
</section>


<section data-markdown>
<script type="text/template">

### Additional Basic Movements Within Buffer

 - function
   - `C-M-a`: beginning of *function* definition
   - `C-M-e`: end of *function* definition
 - sexp (balanced group of parentheses / brackets / braces)
   - `C-M-n`: end of *sexp*
   - `C-M-p`: beginning of *sexp*
 - using prefix command
   - example: `C-u 3 C-n`, move 3 lines down

</script>
</section>


<section data-markdown>
<script type="text/template">

### Editing Within Buffer

 - terminology
   - copy → kill without delete
   - cut → kill
   - paste → yank
 - `C-SPC`: set region mark
   - then use movement keys to select a region
 - when mark is active (you have selected a region)
   - `C-w`: kill region (<span style="color: green">cut</span>)
   - `M-w`: kill region without delete (<span style="color: green">copy</span>)
 - `C-y`: yank (<span style="color: green">paste</span>)

</script>
</section>


<section data-markdown>
<script type="text/template">

### More Editing Within Buffer

 - `DEL`: delete *character* backward
 - `M-DEL`: kill (cut) *word* backward
 - `C-k`: kill (cut) *line*
 - `M-y`: yank (paste) previously-killed text,
   used immediately after `C-y`
 - `C-M-h`: mark function definition

</script>
</section>


<section data-markdown>
<script type="text/template">

### Window Management

 - `C-x 0`: *close* the active window
 - `C-x 1`: *close* all windows except the active window
 - `C-x 2`: *split* the active window vertically into two
 - `C-x 3`: *split* the active window vertically into two
 - `C-x o`: *change* the active window to another

</script>
</section>


<section data-markdown>
<script type="text/template">

### Movement Across Buffers

 - `C-x b`: switch buffer
 - `C-x C-b`: show buffer list

</script>
</section>


<section data-markdown>
<script type="text/template">

### Search & Replace

 - `C-s`: search forward
   - after search activated, use `C-s` to search for next candidate
 - `C-r`: search backward
   - after search activated, use `C-r` to search for next candidate
 - `C-M-s`: search forward for regexp
 - `C-M-r`: search backward for regexp
 - `M-%`: query replace

</script>
</section>


<section data-markdown>
<script type="text/template">

## Configure Your Emacs

</script>
</section>


<section data-markdown>
<script type="text/template">

### Configuration File

 - `~/.emacs`
   - add configurations to this file
   - Emacs will load this file on startup
 - configuration is written in Emacs Lisp, a Lisp dialet
   - S-Expression (*sexp*): balanced expression (parentheses)
   - comment starts with `;`
   - by convention, comments that goes from
     beginning of line starts with `;; `

</script>
</section>


<section data-markdown>
<script type="text/template">

### Color Theme

 - builtin themes
 - `M-x load-theme RET`
 - then hit `TAB` to see a list of available themes
 - enter the theme name
 - add your favorite theme to your config file
   - `(load-theme 'tango-dark t)`
   - replace `tango-dark` with your favorite theme name
 - will talk about installing 3rd party themes after we introduce
   package manager

</script>
</section>


<section data-markdown>
<script type="text/template">

### Some Sane Defaults

```lisp
;; disbale startup messages
(setq inhibit-startup-message t)
;; substitute y-or-n-p for yes-or-no-p
(defalias 'yes-or-no-p 'y-or-n-p)
;; do not blink cursor
(blink-cursor-mode -1)
;; use DEL to delete selected text
(delete-selection-mode 1)
;; highlight region when mark is active
(transient-mark-mode 1)
;; visualize matching parens
(show-paren-mode 1)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### Backup Files

 - if you don't want backup files to clutter your current directory,
   add the following to your config file
 - backup files will be saved under `~/.saves` directory
   with version numbers

```lisp
(setq backup-directory-alist '(("." . "~/.saves"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 10
      kept-old-versions 2
      version-control t)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### Smooth Scrolling

```lisp
;; smooth scrolling
;; keyboard
(setq scroll-margin 1
      scroll-step 1
      scroll-conservatively 10000
      scroll-preserve-screen-position 1)
;; mouse
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ; one line at a time
;; (setq mouse-wheel-progressive-speed nil) ; don't accelerate scrolling
(setq mouse-wheel-follow-mouse t)       ; scroll window under mouse
;; do not show scroll bar
(scroll-bar-mode -1)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### Auto Revert Mode

 - revert buffer when the files changes

```lisp
;; auto revert
(global-auto-revert-mode)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### Space or TAB?

```lisp
;; do not indent with tabs
(setq-default indent-tabs-mode nil)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### Line Number

```lisp
(global-linum-mode 1)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### Ido Mode

 - interactively do things
   - useful for opening files and switching buffers

```lisp
;; enable interactively do things (ido)
(require 'ido)
(ido-mode 1)
(setq ido-enable-flex-matching t)
(ido-everywhere t)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### Create keybindings

http://ergoemacs.org/emacs/keyboard_shortcuts.html

</script>
</section>


<section data-markdown>
<script type="text/template">

### Builtin Customization Interface

 - `M-x customize`

</script>
</section>


<section data-markdown>
<script type="text/template">

### Programming Language Specific Customization

 - Lisp
 - C/C++
 - Python
 - web (HTML/CSS)
 - Javascript
 - Markdown

</script>
</section>


<section data-markdown>
<script type="text/template">

## Additional Text Editing Modes

</script>
</section>


<section data-markdown>
<script type="text/template">

### Dired: directory editor

 - special mode for file management
 - `C-x d` to launch dired
 - In dired
   - `RET`: open file or directory
   - `d`: mark file for deletion, then hit `x` to delete
   - `v`: view file
     - in that viewed file, use `q` to go back to dired
   - `q`: quit dired

</script>
</section>


<section data-markdown>
<script type="text/template">

### More Dired: directory editor

 - `C`: copy file
 - `R`: rename/move file
 - `g`: update dired buffer
 - marking and batch processing
   - `m`: mark file
   - `u`: unmark file
   - `U`: unmark all files
   - `% m`: mark file by regexp

</script>
</section>


<section data-markdown>
<script type="text/template">

### Tramp: Editing Remote Files

 - use the same keys as open file `C-x C-f`
 - enter the filename as `/ssh:name@lnxsrv.seas.ucla.edu:cs111/test.c`
 - edit as normal file
 - make tramp respect remote `$PATH` variable,
   add the following config

 ```lisp
 (with-eval-after-load 'tramp
   (add-to-list 'tramp-remote-path 'tramp-own-remote-path))
 ```

</script>
</section>


<section data-markdown>
<script type="text/template">

## Package Management

</script>
</section>


<section data-markdown>
<script type="text/template">

### package.el

 - builtin package manager since Emacs 24
 - put the following configuration at the
   <em style="color: crimson">BEGINNING</em> of your config file

```lisp
(setq package-enable-at-startup nil)
(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
        ("melpa" . "http://melpa.milkbox.net/packages/")
        ("melpa-stable" . "https://stable.melpa.org/packages/")))
(package-initialize)
```

</script>
</section>


<section data-markdown>
<script type="text/template">

### package.el

 - either of the following works
 - `M-x package-list-packages`
   - find the package you want to install (put the cursor on that line)
   - hit `i`, then `x`
   - wait for the package to be installed
 - `M-x package-install`
   - enter the name of the package, then hit `RET`
   - wait for the package to be installed

</script>
</section>


<section data-markdown>
<script type="text/template">

### Auto Completion

 - [company-mode](https://company-mode.github.io/)
   - company stands for COMPlete ANYthing
   - can complete multiple languages
     - pluggable back-ends and front-ends
   - install with package manager

</script>
</section>


<section data-markdown>
<script type="text/template">

### Auto Completion: company mode

 - configure company-mode: add the following config
 ```lisp
 (add-hook 'after-init-hook 'global-company-mode)
 ```
 - completion will start after you type 3 characters
   - after the completion popup appears
   - `M-p`: previous candidate
   - `M-n`: next candidate
   - `<return>`: complete with current candidate
   - `<tab>`: complete common parts

</script>
</section>


<section data-markdown>
<script type="text/template">

### [Neotree](https://github.com/jaypei/emacs-neotree)

 - directory tree like NerdTree for Vim
 - install from melpa with package manager
 - add the following config
 ```lisp
 (global-set-key (kbd "<f8>") 'neotree-toggle)
 ```

 - use `<f8>` to open/close neotree

</script>
</section>


<section data-markdown>
<script type="text/template">

### Color Themes

 - [solarized](https://github.com/bbatsov/solarized-emacs)
 - [zenburn](https://github.com/bbatsov/zenburn-emacs)
 - read instructions on their README

</script>
</section>


<section data-markdown>
<script type="text/template">

## Stuff That We Did Not Talk About

 - [spacemacs](http://spacemacs.org/): better configured emacs
 - [helm](https://github.com/emacs-helm/helm):
   incremental completion & selection narrowing
 - [flycheck](http://www.flycheck.org/en/latest/): on-the-fly syntax checking
 - [magit](https://magit.vc/): A Git Porcelain inside Emacs
 - [pdf-tools](https://github.com/politza/pdf-tools): view/edit pdf
 - [org-mode](http://orgmode.org/): keeping notes, TODO list, ...
 - [AUCTeX](https://www.gnu.org/software/auctex/): edit/preview LaTeX
 - Emacs Lisp
 - **AND A LOT MORE!**

</script>
</section>


<section data-markdown>
<script type="text/template">

## References & Resources

 - builtin help
 - http://ergoemacs.org/emacs/emacs.html
 - http://www.jesshamrick.com/2012/09/10/absolute-beginners-guide-to-emacs/
 - http://www.jesshamrick.com/2012/09/18/emacs-as-a-python-ide/

</script>
</section>


<section data-markdown>
<script type="text/template">

## Questions?

</script>
</section>

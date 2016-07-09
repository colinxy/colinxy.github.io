---
layout: post
title:  A First Step In Lisp
Date:   2016-05-10
categories: computer-science
commentIssueId: 9
---


I want to dedicate this post to something technical.

I have been learning emacs and enjoying
this powerful text editor, as it is immensely powerful and customizable.
So far I can navigate through most of the basic customizations with
my limited knowledge of emacs lisp, and sometimes copy and paste other
people's code to achieve the effect I want.
But to bend emacs to suit my everchanging needs,
more knowledge of lisp is needed to further my understanding
of emacs as a whole.

As a result, I chose common lisp, a close relative to emacs lisp
as a starting point of my adventure in lispland.


## Common Lisp ##

Common Lisp is not like any other languages I have learned so far.
Case insensitivity in identifiers, many parentheses and strange
indentations take some time to get used to,
but with emacs handling my parentheses and indentations,
I can focus more on interesting language features.

One thing that I have to mention about lisp is the macro system.
The macro system in lisp is such an interesting and ubiquitous concept,
which brings up the concept of `symbol`.

This concept of `symbol` is detached from data, unlike a language
like Python, where symbol is just the name of a variable (identifier),
and usage of a symbol is analogous to its value.
I think answers from
[this stack overflow question](http://stackoverflow.com/q/8846628/5478848)
does clarify a bit. But of course, I want you to read my article,
where I compare and contrast several features to give you a
better idea of symbols in Lisp.

### Symbol: 'literal ###

Simply said, `quote` or the quote sign `'` means to return the
arguments unevaluated, please refer to
[this stack overflow answer](http://stackoverflow.com/a/137774/5478848).

```cl
(quote x)
'x
```

From
[Common Lisp Hyper Spec](http://www.lispworks.com/documentation/HyperSpec/Body/t_symbol.htm),
symbols have the following attributes:

- name
  - a string used to identify the symbol
- package
  - home package of the symbol
- property list
  - the property list provides a mechanism for associating
    named attributes with that symbol
- value
  - if a symbol has a value attribute, it is said to be __*bound*__
  - value
- function
  - if a symbol has a function attribute, it is said to be __*fbound*__
  - function value

The following code illustrates the idea of symbols.

```cl
(defvar a 1)
a                 ; 1    (value)
'a                ; A    (symbol)
(symbol-name 'a)  ; "A"  (a string, symbol name of a)
(boundp 'a)       ; T    (true, symbol a is bounded to a value)
(fboundp 'a)      ; NIL  (not true, symbol a is not bounded to a function)
```

A common beginner's mistake would be

```cl
(symbol-name a)  ; ERROR, The value 1 is not of type SYMBOL.
(symbol-name 1)  ; ERROR, The value 1 is not of type SYMBOL.
```

Common Lisp evaluates the symbol `a` before passing it
into function `symbol-name`,
therefore it would have the same effect as passing in `1`.

The [Emacs Lisp reference manual](https://www.gnu.org/software/emacs/manual/html_node/elisp/Symbol-Components.html)
here also provides good documentation on symbols.

From a beginner's perspective, the key is to differentiate a symbol
from its value (or function, if the symbol can be appied in a function call).


### Function, Anonymous Function ###

In lisp, `lambda` macro creates an anonymous function. Anonymous
functions are common in modern languages, thanks to this legacy
from Lisp. But it's more complicated in Lisp itself.
Occasionally a sharp quote sign is added before the function.
The question is, what difference does it make.

```cl
(lambda (x) (* x 2))
#'(lambda (x) (* x 2))
```

Evaluating both expression in common lisp gives me the result of
an anonymous function.

However, making function calls with these 2 expressions make a difference.

```cl
((lambda (x) (* x 2)) 7)     ; compiles
(#'(lambda (x) (* x 2)) 7)   ; ERROR, illegal function call

(funcall (lambda (x) (* x 2)) 7)    ; compiles
(funcall #'(lambda (x) (* x 2)) 7)  ; compiles
```

It also common to see people define factory functions in this way;
however, in this case, the result seems to be equivalent.

```cl
(defun dummy ()
  #'(lambda () nil))       ; compiles

(defun dummy ()
  (lambda () nil))         ; compiles
```

Some googling led me to
[this answer on stack overflow](http://stackoverflow.com/a/4873847/5478848).
It partially helped me understand the idea of variable value and
function value.

```cl
(defun foo ()
  1)

(foo)            ; 1  (result of function application)
(fboundp 'foo)   ; T  (true, symbol foo is bounded to a function value)

foo              ; ERROR, variable FOO is unbound
#'foo            ; #<FUNCTION FOO>
(function foo)   ; #<FUNCTION FOO>
```

Putting `foo` at the first element of the list will cause the function
to be applied, thereby producing the result 1.

However, directly referencing `foo` will cause it to be looked up in the
variable namespace,
but because foo only has a function value and
only exists in the function namespace, it produce an error.
But with sharp quote (`#'`), the symbol `foo` will be looked up
in function namespace.

The sharp quote here (`#'`) is quite different from quote (`'`).
Quote asks compiler to not to evaluate the symbol, whereas
sharp quote asks compiler to look up the symbol in
another (function) namespace and return its correspinding (function) value.

It turns out, that sharp quote (`#'`) is equivalent to `function`, as

```cl
(function foo)   ; #<FUNCTION FOO>
#'foo            ; #<FUNCTION FOO>
```

causing common lisp to look up `foo` in function namespace, while
without `#` symbol, common lisp will look for it in variable namespace
(okay, I know I have already said it in the previous paragraph).
Scheme, another Lisp dialect, on the other hand, do not need this
kind of construct, because it does not keep different variables
and functions in different namespaces.

It is worthy to note that `function` here does not look like a normal
function. Because if it were, `foo` would have been evaluated,
causing an error (`foo` does not exist in variable namespace).
`function` is similar to symbols like `defun` or `lambda` where the arguments
after it are specially treated (not yet evaluated), which makes me
speculate it is some kind of macro or special-form.
But my current knowledge of Lisp is not sufficient enough to answer
this question. Maybe I will devote another post to explain this
kind of problem.

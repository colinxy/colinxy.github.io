---
layout: post
title:  Print Math Beautifully
date:   2015-11-08
categories: software-installation
---


*Update 2016-1-30:*

I realized that the link to a another blog is no longer
working, and that some of the content may not be explained
clearly. I will try to address these issues with this update.

- fix

<br>

Thanks to python module [sympy](http://www.sympy.org/en/index.html)
and instructions from [this blog](http://gastonsanchez.com/opinion/2014/02/16/Mathjax-with-jekyll/),
I can now render math equations in this blog.

I know perfectly well the struggle that one has to go through to
set up everything perfectly. Yet how reluctant one is when prompted
to repeat the painful struggle. I will try to reconstruct the process
for your reference. _**NOTICE:**_ The following instructions are for
blogs powered by Jekyll, if this does not applies to you, you may want
to seek help elsewhere.

The following steps I am trying to explain is just to one solution to rendering
math expressions. There are many choices out there with options like MathJax or
MathML, but the general idea for my approach is first generate LaTeX from plain
math expressions and then convert LaTeX to MathJax, which could be rendered in
most major browsers.

The outline is illustrated in the following diagram.

```
                   Python            LaTeX to
                   sympy             MathJax
                   module            js library
Math Expressions  ========>  LaTeX  ============>  MathJax  ==>  rendered
                                                                on browser
```

For those of you who already know how to write in LaTeX, you can totally skip the
following paragraph on installing python sympy. It's just for people like me
who are too lazy to learn LaTeX.

The first step is to generate LaTeX code. Thanks to Python sympy,
a module for doing symbolic math, I can totally rely on the skills that I currently have.
The `sympy.printing.latex.latex` function convert any sympy expression to LaTex.
I can then copy and paste the code onto my blog markdown source code and enclose them with
either `<span>$$ (LaTeX here) $$</span>` or `<div>$$ (LaTeX here) $$</div>`.

For python sympy module, install it with `python -m pip install sympy`.
If you don't know what python or pip is, check out my python tutorial
later in my blog.

Now that you have latex code for your math expression, there are only
two more things to set up.

- 1. change the markdown rendering machine to redcarpet.
     Add the following line to your `_config.yml` file.

```
markdown: redcarpet
```


- 2. include the MathJax library. In this case, you
     have to use HTML tags, add the following line at the end of the markdown file.

```
<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
```


</br>
The following math expression `Integral(exp(-x**2))`
can be rendered as
<div>
$$ \\int e^{- x^{2}}\\, dx $$
</div>

Please go to my [source code](https://github.com/colinxy/colinxy.github.io/blob/master/_posts/2015-11-08-print-math-beatifully.md)
to see how it is actually done.

<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>

---
layout: post
title: Print Math Beautifully
date:   2015-11-08
categories: software-installation
---


Print Math Beautifully
======================

Thanks to python module [sympy](http://www.sympy.org/en/index.html) and instructions from [this blog](http://gastonsanchez.com/blog/opinion/2014/02/16/Mathjax-with-jekyll.html), 
I can now render math equations in this blog. 

I know perfectly well the struggle that one has to go through to set up everything perfectly.
Yet how reluctant one is when prompted to repeat the painful struggle.
I will try to reconstruct the process for your reference. _**NOTICE:**_
The following instructions are for blogs powered by Jekyll, 
if this does not applies to you, you may want to seek help elsewhere.

I first generate latex code from python code in sympy with the ```sympy.printing.latex.latex``` function, 
and then paste the code onto my blog markdown source code and enclose them with 
either ```<span></span>``` or ```<div></div>```. For python sympy module, install it 
with ```python -m pip install sympy```. If you don't know what python or pip is,
follow my python tutorial later in my blog.

Then there are only two more things to set up in my jekyll blog -- 
change the markdown rendering machine to redcarpet and include the MathJax library.
For this part, please refer to the blog I have referred to above, its explanation
is much more detailed than mine.

The following math expression ```Integral(exp(-x**2))```
can be rendered as
<div>
$$ \\int e^{- x^{2}}\\, dx $$
</div>

Please go to my [source code](https://github.com/colinxy/colinxy.github.io/blob/master/_posts/2015-11-08-print-math-beatifully.md)
to see how it is actually done

<script type="text/javascript" src="http://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>

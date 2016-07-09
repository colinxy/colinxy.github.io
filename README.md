
[My Blog](http://colinxy.github.io)

This is the master branch. All generated site content goes here.
The source of posts, written in markdown, can be viewed in source branch.

Although this blog is hosted on github, it does not make use of github's
jekyll to generate blog contents (for its lack of support for certain features).
All blog contents are generated locally and pushed to github for remote hosting.

#### Workflow (primarily written for myself) ####

 - generate site content from source branch
 - *commit changes !!!*
 - switch to master branch
 - run `.publish.sh`
 - push all branches to remote

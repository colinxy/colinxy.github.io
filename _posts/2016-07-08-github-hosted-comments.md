---
layout: post
title:  Add Github Hosted Comments to This Blog
Date:   2016-07-08
categories: software-installation
commentIssueId: 3
---


This post is based on the reference
[here](http://ivanzuzak.info/2011/02/18/github-hosted-comments-for-github-hosted-blogs.html),
with some personalized customizations. Though the reference is somewhat
outdated, it still offers a feasible way hosting comments on github
for github based blog.

Comments need to be stored in a database, but for static blog, I have to
resort to an external host to store them. A popular choice seems to be
[disqus](https://disqus.com/), a free plugin to your blog that manages
everything related to comments. But using this plugin would mean that I have
to host comments separately, something I am reluctant to do.
Also, I would lose control of how I want to present the comments,
and miss all the fun tweaking personalized customizations. So when I came
across [this reference](http://ivanzuzak.info/2011/02/18/github-hosted-comments-for-github-hosted-blogs.html)
aforementioned, I was surprised by its elegance and creativity. It
immediately became clear to me that this is the right way for me to host
the comments to my blog.

![github issue](/res/github_issue.png)
![comments](/res/github_comment.png)


The general idea behind this method is to treat each blog as a issue, and
each blog comment maps to each comment of the corresponding issue.
Thus, I have to create an issue for each of my blog post and provide
a link to the issue page. Fortunately, there is a unique id associated
with each issue, so linking them wouldn't be a problem. Also to
inform Jekyll about the id of the issue, simply add the id to
[YAML front matter block](http://jekyllrb.com/docs/frontmatter/)
of the markdown source. I have used this post itself as an example.

```
layout: post
title:  Add Github Hosted Comments to This Blog
Date:   2016-07-08
categories: software-installation
commentIssueId: 3
```

In this case, I have called this variable `commentIssueId`.
This variable will be available to the template system, and therefore
can be present in the javascript code. It can be accessed as
`page.commentIssueId`.

```javascript
var commentIssueId = {% raw %} {{ page.commentIssueId }} {% endraw %};
```

The next challenge is to present all the comments on my blog.

TODO : finish up this post

ajax

```javascript
var url = "https://api.github.com/repos/colinxy/colinxy.github.io/issues/" +
          commentIssueId + "/comments";

var request = new XMLHttpRequest();
request.onload = function() {
    ...  // omitted
};
request.error = function() {
    ...  // omitted
};
request.open('GET', url, true);
request.setRequestHeader("Accept", "application/vnd.github.v3.html+json");
request.send();
```

For more detail, checkout my code on
[github](https://github.com/colinxy/colinxy.github.io/blob/source/_layouts/post.html).

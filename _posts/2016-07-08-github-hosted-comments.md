---
layout: post
title:  Add Github Hosted Comments to This Blog
Date:   2016-07-08
categories: software-hack
commentIssueId: 3
---

*edit: 2016-8-31*

Updated with mention of same origin policy.

</br>

The idea of this design originated from this
[blog post](http://ivanzuzak.info/2011/02/18/github-hosted-comments-for-github-hosted-blogs.html).
I have adopted its idea, and added some personalized customizations.
Though the reference blog post is somewhat outdated, it still offers
a feasible way of hosting comments on github for github based blog.

Traditional blogs tend to store everything in a database, and
accessing a particular blog post along with its comments would be
equivalent to asking the server to make a query on blog database and
render the resulting HTML file for you.
However, static blogs like this one store all the posts as static contents,
and visiting a blog post would be like visiting a public html file on a
remote server. But since comments are always generated dynamically
(provided by visitors), managing them statically can be a pain.

Therefore I have to resort to an external host to store comments.
A popular choice seems to be
[disqus](https://disqus.com/), a free plugin to your blog that manages
everything related to comments. But using this plugin would mean that I have
to host comments separately, something I am reluctant to do.
Also, I would lose control of how I want to present the comments,
and miss all the fun tweaking personalized customizations. So when I came
across [this reference](http://ivanzuzak.info/2011/02/18/github-hosted-comments-for-github-hosted-blogs.html)
aforementioned, I was surprised by its elegance and creativity. It
immediately became clear to me that this is the right way for me to host
the comments on my blog.

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
categories: software-hack
commentIssueId: 3
```

In this case, I have called this variable `commentIssueId`.
This variable will be available to the template system, and therefore
can be present in the javascript code. It can be accessed as
`page.commentIssueId`.

```javascript
var commentIssueId = {% raw %} {{ page.commentIssueId }} {% endraw %};
```

![github issue](/res/github_issue.png)
*hosting comments as github issues*

The next challenge is to present all the comments on my blog.
Luckily github has provide us with issue API, which I can pull all
the comments with an asynchronous javascript call.
[github issue API](https://developer.github.com/v3/issues/)
It is easy to form URL for issue API, and in my case, it's
`https://api.github.com/repos/colinxy/colinxy.github.io/issues/<issue id>`,
where issue id is the variable `commentIssueId` I have mentioned above.
Github will respond with a json that easy to parse with javascript
function `JSON.parse`.

An example response looks like this.

```json
{
    "url": "https://api.github.com/repos/colinxy/colinxy.github.io/issues/comments/231508173",
    "html_url": "https://github.com/colinxy/colinxy.github.io/issues/3#issuecomment-231508173",
    "issue_url": "https://api.github.com/repos/colinxy/colinxy.github.io/issues/3",
    "id": 231508173,
    "user": {
        "login": "colinxy",
        "id": 8478254,
        "avatar_url": "https://avatars.githubusercontent.com/u/8478254?v=3",
        "gravatar_id": "",
        "url": "https://api.github.com/users/colinxy",
        "html_url": "https://github.com/colinxy",
        "followers_url": "https://api.github.com/users/colinxy/followers",
        "following_url": "https://api.github.com/users/colinxy/following{/other_user}",
        "gists_url": "https://api.github.com/users/colinxy/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/colinxy/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/colinxy/subscriptions",
        "organizations_url": "https://api.github.com/users/colinxy/orgs",
        "repos_url": "https://api.github.com/users/colinxy/repos",
        "events_url": "https://api.github.com/users/colinxy/events{/privacy}",
        "received_events_url": "https://api.github.com/users/colinxy/received_events",
        "type": "User",
        "site_admin": false
    },
    "created_at": "2016-07-09T01:53:43Z",
    "updated_at": "2016-07-09T01:54:45Z",
    "body_html": "<p>test comment.<br>\nComment with <strong>markdown</strong> <em>styling</em></p>"
}
```

But as the reference blog post points out, I might need to consider the
same origin policy. Javascript code from this wesite `http://colinxy.github.io`
have a different origin from `https://api.github.com`, so requests made to
`api.github.com` from `colinxy.github.io` might be restricted by the
browser for security.
The good news is that github API supports [Cross Origin Resource
Sharing (CORS) for AJAX](https://developer.github.com/v3/#cross-origin-resource-sharing),
so I don't have to concern myself with this problem.

As seen in the following example (with slight modification, and most
output omitted) using curl from github API reference, response
headers from `api.github.com` contain `Access-Control-Allow-Origin: *`,
which means code from any website can call this github API.
And thanks to this line, our browsers won't block the response from github API.

```
$ curl -I https://api.github.com -H "Origin: http://colinxy.github.io"
HTTP/1.1 200 OK
Server: GitHub.com
...
Access-Control-Allow-Origin: *
...
```

The next big step is to render the comments.
Since github issue comments come in as markdown, so I also want to be able
to render markdown in comment box. But Luckily, github provides an option
to request comments in HTML, saving me a lot of trouble.
The key is to specify media type in request header asking for
comments as HTML. Simply supply
`{Accept: "application/vnd.github.v3.html+json"}`
in the request header, and github will return the comment body as HTML.
In the example json response seen above, the `body_html` attribute
is the comment body, and it is rendered as HTML, not markdown,
which I can directly insert into the HTML nodes.
Find more information on github API media type
[here](https://developer.github.com/v3/media/).

The example javascript code to make AJAX request to github API, without
jQuery. Since I use a template system to render blog post, I put the
javascript code in post template under `_layout` folder.
You can see the full code
[here](https://github.com/colinxy/colinxy.github.io/blob/source/_layouts/post.html#L24).

```javascript
var url = "https://api.github.com/repos/colinxy/colinxy.github.io/issues/" +
          commentIssueId + "/comments";

var request = new XMLHttpRequest();
request.onload = function() {
    // render comments
};
request.error = function() {
    // log error
};
request.open('GET', url, true);
request.setRequestHeader("Accept", "application/vnd.github.v3.html+json");
request.send();
```

The last part is to render the comment HTML nodes onto the webpage. Since I am
working without any external javascript library, I had to manually
append nodes into HTML documents.

It took some tweaking with HTML and CSS to make comments box look
somewhat nicer, but I have to give credit to github, as I borrowed most
of the relevant CSS design from their website.
You can checkout the relevant CSS code
[here](https://github.com/colinxy/colinxy.github.io/blob/source/_sass/_layout.scss#L241).

![comments](/res/github_comment.png)
*comments rendered for this blog*


For more detail, checkout my code on
[github](https://github.com/colinxy/colinxy.github.io/blob/source/_layouts/post.html).

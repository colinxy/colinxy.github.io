---
layout: post
title:  Dockerize SSH Service
Date:   2016-08-30
categories: devops
commentIssueId:
---

It is debatable to run docker as a ssh server, sicnce docker primarily
provide a level of isolation between different applications, with each
application running in a clean container.

Other technologies that we have considered are Xen and KVM. Xen is the
technology that we have been running now, and 3 other virtual servers
run Xen technology. But the virtual ssh server crashes crashes
occasionally, and

Docker is a light weight replacement for those full virtualization
technologies.

But there are several technical difficulties to overcome.

 1. ssh service needs to have a public ip, while docker container sits
    behind
 2. user home directories need to be mounted from another ldap server

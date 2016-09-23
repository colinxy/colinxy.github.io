---
layout: post
title:  First Time Screwing up Remote Servers
Date:   2016-09-02
categories: devops
commentIssueId: 10
---

*edit: 2016-09-22*

Updated with the joke from nixcraft

<br/>


I guess there is always a first time for everything. When I first heard
of jokes like `rm -rf /` and laughed at how ridiculous it was, little did
I know that these kinds of mistakes, though not as severe, could happen
to most people. So instead of the usual long technical blog post, I
will briefly document how I screwed up our servers at Linux User Group
remotely. Though I did not cause any trouble as permanent as wiping
out our disk, my mistake caused hours of downtime for our servers.

I sshed into the remote server as root (yes, you know how the story
goes) to configure our ssh service. This physical server holds 2 other
virtual machines, which are critical to the running of our website.
How networking on this server works gets really interesting.
Since both VMs have their own public IPs, the physical server has to
sort out traffic forwarded to itself and the 2 virtual servers. The 2
virtual servers runs on Xen hypervisor, and here comes the `xenbr0`
network interface.

A quick run of `ifconfig` command showed the `xenbr0` interface, which
I supposed to handle packets forwarded to VMs, but I was unable to find
the default `eth0` interface on the host physical server. So I thought
how about temporarily bringing the interface down, since it's easy to
bring it back up anyway. *(stupid, stupid idea)*

```
xenbr0    Link encap:Ethernet  HWaddr XX:XX:XX:XX:XX:XX
          inet addr:XXX.XXX.XXX.XXX  Bcast:XXX.XXX.XXX.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
```
*ifconfig output concerning xenbr0 interface, some info omitted*

So I ran `ifconfig xenbr0 down` on this physical server and
waited, but the command was unresponsive for a long time. Then I
realized something was going wrong. Looking at the `xenbr0` interface,
I saw that its inet addr has the same addr as the physical server
itself, which means that `xenbr0` handles all incoming traffic to both
the physical server and the 2 VMs. Now I was in a big trouble -- I
just brought down the network interface for the physical server. No
wonder the command has no response. All 3 servers, the physical server
and the 2 VMs were down now. I would have to ask my friend/colleague
to re-enable it at the console.

So the story ends. Any takeaway messages? I will quote my friend on
this.

> Protip: if you're gonna ssh into a machine and turn off
> network interfaces, you're gonna have a bad time.


The other day, I came across
[this joke](https://twitter.com/nixcraft/statuses/774612618547834880)
from nixcraft, which perfectly illustrates the mistake I made here,
though in terms of sshd.

> I’ve never locked my keys in my car, but I did once kill sshd and
> that’s basically the same thing.

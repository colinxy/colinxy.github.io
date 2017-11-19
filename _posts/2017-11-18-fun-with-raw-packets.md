---
layout: post
title:  Fun with Raw Packets
Date:   2017-11-18
categories: computer-science
commentIssueId: 16
---

I came across this awesome Python package
[`scapy`](https://github.com/secdev/scapy/) through Julia Evans' blog
[post](https://jvns.ca/blog/2013/10/31/day-20-scapy-and-traceroute/).
I will talk about my (debugging) experience of sending a simple http
request in raw packets.
I will be using the python3 port of the same package
[here](https://github.com/phaethon/scapy).

So our goal is to send a http request to Google and get a response
back.  We will only use ip layer APIs, even though `scapy` has APIs for
sending even lower layer packets i.e. link layer.

Normally when we were to use syscall to send and receive packets, we
operate above transport layer. The process is roughly the following
for tcp and udp.

```
fd <- socket: with socket type SOCK_STREAM for tcp, SOCK_DGRAM for udp.

for TCP:
connect: tcp 3-way handshake
send: (sendto could also be used)
recv: (recvfrom could also be used)

for UDP:
sendto
recvfrom

In the end
close: cleanup
```

I guess scapy people implement this through creating a socket with
`SOCK_RAW` socket type. This allows us to speak at a lower level, or
even implement a different protocol.
However this will require root privileges or `CAP_NET_RAW`
[capabilities(7)](http://man7.org/linux/man-pages/man7/capabilities.7.html).
You can observe this through the `ping` program, which is either a
setuid binary owned by root, or has `CAP_NET_RAW` capabilities enabled
on some Linux distributions. So all code example below should be run
with root privileges.

To achieve our goal, let's start with writing a simple DNS query.
With scapy, we can clearly see the structure of a packet. Higher level
packets get encapsulated in a lower level packet. And this case, DNS
query (application layer) gets encapsulated in a UDP packet
(transport layer), and the UDP packet gets encapsulated in a IP packet
(network layer).
The `sr1` function in scapy sends our packet and receives only
the first answer.

```python
from scapy.all import *

def dns_query(hostname, dnsserver='8.8.8.8'):
    # rd: recursion desired
    dns = IP(dst=dnsserver) / UDP() / DNS(rd=1, qd=DNSQR(qname=hostname))
    answer = sr1(dns)
    print(answer.summary())
    ip = answer[DNS].an.rdata
    return ip
```

This experiment turns out to be uneventful. Below are the outputs.

```
In [1]: ip = dns_query('google.com')
Begin emission:
.................................................................Finished to send 1 packets.
........................................................................................................................*
Received 186 packets, got 1 answers, remaining 0 packets
IP / UDP / DNS Ans "'172.217.4.142'"

In [2]: ip
Out[2]: '172.217.4.142'
```

As a retrospection, this worked so well because dns queries were
designed to be small in size and thus can fit within one ip packet
comfortably. This also fits the fire-and-forget philosophy of
UDP.

Now onto HTTP request. Similar to DNS, but we need to implement tcp
3-way handshake by ourselves. We do that by sending a packet with
`SYN` flag on and after that we send another packet with `ACK` flag on
to ack our peer's `SYN`. (There is a bug in this program. I will
present the correct version at the end.)

```python
from scapy.all import *

# do NOT copy and paste, there is a bug
def http(payload, ip, dport=80):
    sport = RandNum(1025, 65535)
    seq = RandInt()
    # ip_pkt = IP(dst=ip, id=0)
    syn = IP(dst=ip) / TCP(dport=dport, sport=sport, flags='S', seq=seq)
    synack = sr1(syn)
    print(synack.summary())

    seq = synack[TCP].ack
    ack = synack[TCP].seq + 1

    request = IP(dst=ip) / TCP(dport=dport, sport=sport, flags='A', seq=seq, ack=ack) / Raw(ensure_bytes(payload))
    ans, unans = sr(request)
    ans.summary()
    return ans
```

The above code is able to get a `ACK` from server, but cannot get
response for the payload. So we use `tcpdump` to investigate what is
going on here. Below is the `tcpdump` output.
I ran the experiment from my Linux virtual machine, and that's why you
can see private ip addresses here.

```
$ sudo tcpdump -nnttttvv port 80
tcpdump: listening on enp0s3, link-type EN10MB (Ethernet), capture size 262144 bytes
2017-11-11 22:41:07.868697 IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto TCP (6), length 40)
    10.0.2.15.10979 > 172.217.11.174.80: Flags [S], cksum 0x53e2 (correct), seq 628762301, win 8192, length 0
2017-11-11 22:41:07.879954 IP (tos 0x0, ttl 64, id 7659, offset 0, flags [none], proto TCP (6), length 44)
    172.217.11.174.80 > 10.0.2.15.10979: Flags [S.], cksum 0xf51b (correct), seq 2969024001, ack 628762302, win 65535, options [mss 1460], length 0
2017-11-11 22:41:07.879978 IP (tos 0x0, ttl 64, id 28975, offset 0, flags [DF], proto TCP (6), length 40)
    10.0.2.15.10979 > 172.217.11.174.80: Flags [R], cksum 0x73df (correct), seq 628762302, win 0, length 0
2017-11-11 22:41:07.934721 IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto TCP (6), length 76)
    10.0.2.15.5909 > 172.217.11.174.80: Flags [.], cksum 0x3dc7 (correct), seq 628762302:628762338, ack 2969024002, win 8192, length 36: HTTP, length: 36
        GET / HTTP/1.1
        Host: google.com

2017-11-11 22:41:07.935864 IP (tos 0x0, ttl 255, id 7686, offset 0, flags [none], proto TCP (6), length 40)
    172.217.11.174.80 > 10.0.2.15.5909: Flags [R], cksum 0x6ceb (correct), seq 2969024002, win 0, length 0
```

There are also a few relevant stackoverflow questions that addresses
this issue.

<https://stackoverflow.com/questions/37683026/how-to-create-http-get-request-scapy>
<https://stackoverflow.com/questions/9058052/unwanted-rst-tcp-packet-with-scapy>

And indeed, I had the same situation as them. We can observe from the
3rd packet from the above output:
`10.0.2.15.10979 > 172.217.11.174.80: Flags [R]`.
A tcp packet with `RESET` flag on was sent to the remote host, and
this ruins all our efforts.
But clearly, we didn't send it ourselves, so the obvious culprit is
the kernel.

> Essentially, the problem is that scapy runs in user space, and the
> linux kernel will receive the SYN-ACK first. The kernel will send a
> RST because it won't have a socket open on the port number in
> question, before you have a chance to do anything with scapy.

The above stackoverflow answer sums it up perfectly. We should tell
the kernel to hand of during our little experiment.

```
sudo iptables -A OUTPUT -p tcp --tcp-flags RST RST -s 10.0.2.15 -j DROP
```

Verify the iptables change with `sudo iptables -n -L -v`. Also don't
forget to flush this rule change at the end of the experiment with
`sudo iptables -F` (this flushes all rules).

However, setting the iptables rule still don't solve the problem for me.
This time I am getting a tcp reset from the server side.

```
$ sudo tcpdump -nnttttvv port 80
tcpdump: listening on enp0s3, link-type EN10MB (Ethernet), capture size 262144 bytes
2017-11-12 01:53:19.796344 IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto TCP (6), length 40)
    10.0.2.15.46928 > 172.217.11.174.80: Flags [S], cksum 0x0700 (correct), seq 326367544, win 8192, length 0
2017-11-12 01:53:19.805356 IP (tos 0x0, ttl 64, id 15419, offset 0, flags [none], proto TCP (6), length 44)
    172.217.11.174.80 > 10.0.2.15.46928: Flags [S.], cksum 0xed36 (correct), seq 133896705, ack 326367545, win 65535, options [mss 1460], length 0
2017-11-12 01:53:19.847819 IP (tos 0x0, ttl 64, id 1, offset 0, flags [none], proto TCP (6), length 76)
    10.0.2.15.51483 > 172.217.11.174.80: Flags [.], cksum 0x1049 (correct), seq 326367545:326367581, ack 133896706, win 8192, length 36: HTTP, length: 36
        GET / HTTP/1.1
        Host: google.com

2017-11-12 01:53:19.847905 IP (tos 0x0, ttl 255, id 15445, offset 0, flags [none], proto TCP (6), length 40)
    172.217.11.174.80 > 10.0.2.15.51483: Flags [R], cksum 0xffe1 (correct), seq 133896706, win 0, length 0

...
```

Initially, I wondered if my packet was in any way noncompliant, since
I combined ACK packet with my initial GET request. I also wondered if
the PSH flag needs to be set Or if Google is blocking my
request. However, this is unlikely since after the tcp reset, it tried
to reconnect by sending more `SYNACK` packets.

It turns out, the bug was a simple one. Our `ACK` packet was sent from
a different port than the original `SYN` packet, no wonder we get tcp
resets.

```
10.0.2.15.46928 > 172.217.11.174.80: Flags [S]
172.217.11.174.80 > 10.0.2.15.46928: Flags [S.]
10.0.2.15.51483 > 172.217.11.174.80: Flags [.]
172.217.11.174.80 > 10.0.2.15.51483: Flags [R]
```

Further debugging shows that the issue is in my misuse of `RandNum`
api, which generates a random number, when used for each request.  So
all I needed to do was to change `RandNum(1025, 65535)` to
`int(RandNum(1025, 65535))` for the above code, and we are good to go.

```python
from scapy.all import *

def http(payload, ip, dport=80):
    sport = int(RandNum(1025, 65535))
    seq = RandInt()
    # ip_pkt = IP(dst=ip, id=0)
    syn = IP(dst=ip) / TCP(dport=dport, sport=sport, flags='S', seq=seq)
    synack = sr1(syn)
    print(synack.summary())

    seq = synack[TCP].ack
    ack = synack[TCP].seq + 1

    request = IP(dst=ip) / TCP(dport=dport, sport=sport, flags='A', seq=seq, ack=ack) / Raw(ensure_bytes(payload))
    ans, unans = sr(request)
    ans.summary()
    return ans
```

However, the above code only gets the first packet from the server.
This normally only contains the `ACK` packet with no data.
To actually get the full http response, we need to use `sniff`
function from scapy, but that's beyond the scope of this post.

---
layout: revealjs
title:  Server From Scratch
date:   2017-04-08
categories: computer-science
theme: moon
---


<style>
code { background: #3f3f3f; }
</style>

<section data-markdown>
<script type="text/template">

# Server From Scratch

David Nguyen, Colin Yang

Linux User Group @ UCLA

2017-04-11

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP

</script>
</section>


<section data-markdown>
<script type="text/template">

## Network Models

![OSI model vs TCP/IP model](/res/network_models.png)

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP sits on top of TCP

 - TCP guarantees reliable and ordered transfer of data
 - reading from TCP stream is like reading from a file from local hard disk

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP: HyperText Transfer Protocol

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP Request and Response

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP Request

 - request line
 - request headers
 - an empty line
 - request body (optional)

```
POST /post HTTP/1.1
Accept: */*
Accept-Encoding: gzip, deflate
Connection: keep-alive
Content-Length: 11
Content-Type: application/x-www-form-urlencoded; charset=utf-8
Host: httpbin.org
User-Agent: HTTPie/0.9.2

hello=world
```

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP Response

 - status line
 - response headers
 - am empty line
 - response body (optional)

```
HTTP/1.1 200 OK
Access-Control-Allow-Credentials: true
Access-Control-Allow-Origin: *
Connection: keep-alive
Content-Type: application/json
Date: Wed, 12 Apr 2017 00:50:45 GMT
Server: gunicorn/19.7.1
Via: 1.1 vegur

{"user-agent": "HTTPie/0.9.2"}
```

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP Method

 - `GET`
 - `POST`
 - `HEAD`
 - `OPTIONS`
 - `PUT`
 - `DELETE`
 - and a few more

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP Headers

 - Both request and response have headers
 - `Host`: specifying the hostname
 - `User-Agent`: program for
 - `Location`: used for redirection
 - `Content-Type`: MIME type (ignore this term)
 - and A LOT more

</script>
</section>


<section data-markdown>
<script type="text/template">

## HTTP Status (Response Code)

 - a 3-digit number used to represent status
 - common status codes
   - `200`: ok
   - `301`, `302`: redirection
   - `404`: not found (client error)
   - `500`: internal server error

</script>
</section>


<section data-markdown>
<script type="text/template">

## Let's make raw HTTP requests by hand

 - login to your linode server, Ubuntu 16.04 LTS
   - `ssh root@<ip>` or `ssh <ip> -l root`
 - use `ncat` from `nmap` package
   - `sudo apt install nmap`

</script>
</section>


<section data-markdown>
<script type="text/template">

## Let's make raw HTTP requests by hand

```
$ ncat google.com 80
GET / HTTP/1.1
Host: google.com

HTTP/1.1 301 Moved Permanently
Location: http://www.google.com/
<... omitted>
```

```
$ ncat --ssl google.com 443  # --ssl for HTTPS
GET / HTTP/1.1
Host: www.google.com

HTTP/1.1 200 OK
<... omitted>
```

</script>
</section>


<section data-markdown>
<script type="text/template">

## Let's make raw HTTP requests by hand

 - slow and tedious
   - other command line tools for simplifying the task
   - `curl`: `sudo apt install curl`
   - `httpie`: `sudo apt install httpie`

</script>
</section>


<section data-markdown>
<script type="text/template">

## Chrome Developer Console

 - under the network tab

</script>
</section>


<section data-markdown>
<script type="text/template">

## Static website and Dynamic website

</script>
</section>


<section data-markdown>
<script type="text/template">

## Setting Up a Web Server ##

</script>
</section>

<section data-markdown>
<script type="text/template">

## Checking It Out ##

-  Log in to your machine
```
ssh -l root <ip-address>
```
-  We should also check the distro and version of our system
```
lsb_release -a
```
-  It should be Ubuntu 16.04 LTS (xenial)

</script>
</section>

<section data-markdown>
<script type="text/template">

## Installing Nginx ##
-  Nginx is an open source web server software
-  We'll add Nginx's repo so that we can get the lastest version.
```
echo "deb http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list
echo "deb-src http://nginx.org/packages/ubuntu/ xenial nginx" >> /etc/apt/sources.list
```
- Add Nginx's PGP key
```
wget http://nginx.org/keys/nginx_signing.key
apt-key add nginx_signing.key
apt update
```
- Installing Nginx
```
apt install nginx
```

</script>
</section>

<section data-markdown>
<script type="text/template">

## Basic Configuration For Nginx ##
- Open port 80 for HTTP
```
iptables -A INPUT tcp -m tcp --dport 80 -j ACCEPT
```
- Configration files will be in /etc/nginx/nginx.conf
  -  In the server block we will edit our server_name
  -  Look at the root location

- In the server root we will add an index page:
```
echo "Hello World!" > <server root>/index.html
```
</script>
</section>

<section data-markdown>¬
<script type="text/template">

## The HTTP Protocol In Action ##
```
curl -v <ip address>
```

</script>
</section>

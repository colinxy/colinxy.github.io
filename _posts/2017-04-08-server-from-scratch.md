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

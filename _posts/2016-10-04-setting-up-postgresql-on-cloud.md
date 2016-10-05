---
layout: post
title:  Setting up PostgreSQL on Cloud
Date:   2016-10-04
categories: devops
commentIssueId: 12
---


In this post, I will revisit the process of setting up a PostgreSQL
database server on digitalocean from scratch. It will be largely based
on this
[digitalocean guide](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-postgresql-on-ubuntu-16-04).
Also, special thanks to Fletcher Davis, for patiently asnwering my
endless questions.

In most cases, exposing database on a public ip is never a good
practice for production, where database servers are usually hiden
behind private networks, as a direct write to database without going
through the application layer is certainly dangerous. But I found it
useful for hackathons where teammates could work on the same page with
the same database. In this post, I will go over setting up PostgreSQL
and test the connection with `psql` client.

First, install postgres.

```
sudo apt-get update
sudo apt-get install postgresql postgresql-contrib
```

### Make Postgres Listen Publicly

Even though we have installed postgres, it is not listening publicly.
We can use `netstat` command to see active network connections.

```
# show all listening connections
netstat -ntlp
# -t : show tcp ports
# -n : show numberic host and port
# -l : show listening sockets
```

Here is an example output. It also contains sshd listening on port 22.

```
Active Internet connections (only servers)
Proto Recv-Q Send-Q Local Address           Foreign Address         State       PID/Program name
tcp        0      0 0.0.0.0:22              0.0.0.0:*               LISTEN      1352/sshd
tcp        0      0 127.0.0.1:5432          0.0.0.0:*               LISTEN      13379/postgres
tcp6       0      0 :::22                   :::*                    LISTEN      1352/sshd
```

In this example, postgres is only bound to `localhost` (`127.0.0.1`).
In order for it to listen publicly, we have to bind it to all
interface (`0.0.0.0`).


Now we edit the postgres config files, be sure to replace
`<postgres_version>` with the correct version on your machine.

This line in file
`/etc/postgresql/<postgres_version>/main/postgresql.conf`
is previously commented out with `listen_addresses`
set to `localhost`, now change it to the following.

```
listen_addresses = '*'		# what IP address(es) to listen on;
```

Then go to
`/etc/postgresql/<postgres_version>/main/pg_hba.conf` and edit
the line about IPv4 local connections as follows.

```
# IPv4 local connections:
hostssl    all             all             0.0.0.0/0            md5
```

Since we are making postgresql public, we should enforce ssl connection
with `hostssl`.

After changing the config files, restart postgres to reflect these
changes.

```
sudo service postgresql restart
```

Now rerun `netstat -ntlp` and you will see postgres listening on
`0.0.0.0:5432`.


### Create Database User for Postgres

The default superuser for postgres database should be `postgres`. it
uses `ident` as its authentication method, which is tied to the
corresponding unix account on the operating system.
Since we are connecting remotely, we should create a new user and a
new database for this purpose.

But we should first switch to user `postgres` to perform these actions.

```
sudo -i -u postgres
```

PostgreSQL offers us a convenient way of creating user and databse
through command line with `createuser` and `createdb`. But for this
purpose, I will create them through database client `psql`.

create user

```sql
/* create user */
CREATE USER '<username>' WITH PASSWORD '<password>';


/* the following are not used, just for reference */
/* change password */
ALTER USER '<username>' WITH PASSWORD '<new_password>';

/* rename user */
ALTER USER '<old_username>' RENAME TO '<new_username>';

/* remove user */
DROP USER '<username>';

/* select all users */
/* CAREFUL!!! It's usename, not username */
SELECT usename FROM pg_user;
```

create database

```sql
/* create a database <dbname> */
CREATE DATABASE '<dbname>';
```


Now we can connect to this database remotely on our local computer
with `psql` client. But make sure postgresql client is installed on
your system. On ubuntu, this would require
`sudo apt-get install postgresql-client-common`.

```
psql -h <ip_addr> -p 5432 -U <username> <dbname>
```

or connect with database url

```
psql postgresql://<username>@<ip_addr>:5432/<dbname>
```

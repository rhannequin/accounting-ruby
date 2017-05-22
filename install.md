# Install

## Ubuntu

### Create new user

```sh
$ adduser rhannequin
$ gpasswd -a rhannequin sudo
```

### Configure SSH

```sh
$ ssh-keygen -t rsa
```

From your local computer, add your SSH public key to your remove server:

```sh
$ ssh-copy-id rhannequin@my-server.com
```

* change SSH port (optional)
* Restrict root login
* Forbid password authentication (optional)
* Allow access only for some users

```sh
// vi /etc/ssh/sshd_config

Port 4444
PermitRootLogin no
PasswordAuthentication no
AllowUsers rhannequin
```

Restart SSH : `$ service ssh restart`


## [Fail2ban](http://doc.ubuntu-fr.org/fail2ban)

*fail2ban* scans log files and bans IPs with toomany password failures, seeking for exploits, etc.

```sh
$ sudo apt-get install fail2ban
```


## Firewall ([ufw](http://doc.ubuntu-fr.org/ufw))

*UFW*, or *Uncomplicated Firewall*, is a front-end to iptables. Its main goal is to make managing your firewall drop-dead simple and to provide an easy-to-use interface.

```sh
$ sudo ufw allow 22
$ sudo ufw allow 80
$ sudo ufw allow 443
$ sudo ufw enable
```


## Postfix

```sh
$ sudo apt-get install postfix
```


## [Logwatch](http://doc.ubuntu-fr.org/logwatch)

```sh
$ apt-get install logwatch
```

Then edit `/etc/cron.daily/00logwatch` file and add this line:

```sh
/usr/sbin/logwatch --output mail --mailto name@example.com --detail high
```


## Nginx

```sh
$ sudo apt-get install curl git-core nginx -y
```

Use `config/nginx.example.conf` to create a new file `/etc/nginx/sites-available/accounting`.

Then `$ ln -nfs /etc/nginx/sites-available/accounting /etc/nginx/sites-enabled/accounting`.


## PostgreSQL

### Install

```sh
$ sudo apt-get install postgresql postgresql-contrib
```

### Create project user and database

```sh
$ sudo -i -u postgres
$ psql
postgres=# CREATE USER app;
postgres=# CREATE DATABASE app_production OWNER app;
postgres=# ALTER USER app WITH ENCRYPTED PASSWORD 'xxx';
postgres=# \q
$ exit
```

### Do not allow remote connections

```sh
$ sudo vim /etc/postgresql/9.3/main/pg_hba.conf
```

Make sure these lines are uncommented:

```
local   all             postgres                                peer
local   all             all                                     peer
host    all             all             127.0.0.1/32            md5
host    all             all             ::1/128                 md5
```


## Ruby

### System dependencies

```sh
$ sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm3 libgdbm-dev g++ libsqlite3-dev libpq-dev
```

See [Ruby installation](https://github.com/rhannequin/upgrade-ubuntu#ruby).

```sh
$ gem install bundler
```


## Application

From local environment:

```sh
$ bundle exec cap production setup
$ bundle exec cap production puma:config
$ bundle exec cap production deploy
```

### Autoloaded `init.d` script

Create file `/etc/init.d/app` and fill it with [init.d.txt](https://github.com/rhannequin/funky-starter/blob/master/init.d.txt).

```bash
$ sudo chmod 0755 /etc/init.d/app
$ systemctl daemon-reload
$ sudo update-rc.d app defaults
```

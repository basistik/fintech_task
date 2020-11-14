#!/bin/bash
yum -y update
yum -y install docker
systemctl start docker
systemctl enable docker

yum -y install httpd
echo "<h1>Hello</h1> " > /var/www/html/index.html
systemctl start httpd

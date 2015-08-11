#!/bin/bash

#Author John Barnett
#Created 11/08/15 v0.1

#This script was created for use on ubuntu 14.04 LTS

#Script to be run as sudo

# credit - http://www.tecmint.com/install-phabricator-in-linux/


echo -e "Setting up prereqs...."
sudo apt-get install mysql-server apache2 git-core git php5 php5-mysql php5-gd php5-curl php-apc php5-cli -y

echo -e "Creating folder...."

sudo mkdir /var/www/phabricator

sudo mkdir -p '/var/repo/'

echo -e "chowning folder"

sudo chown -R john:www-data /var/www
sudo chown -R john:www-data /var/repo

echo -e "git cloning....."
cd /var/www/phabricator

git clone https://github.com/phacility/libphutil.git
git clone https://github.com/phacility/arcanist.git
git clone https://github.com/phacility/phabricator.git

sudo a2enmod rewrite && sudo a2enmod ssl && sudo /etc/init.d/apache2 restart

#sudo nano /etc/apache2/sites-available/phabricator.conf

sudo mv /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-available/000-default.conf.old

echo -e "Setting up apache2...."

# SET apache2 config
sudo echo "
<VirtualHost *:80>
        ServerAdmin root@phab.example.com
        ServerName phab.example.com
        DocumentRoot /var/www/phabricator/phabricator/webroot
        RewriteEngine on
        RewriteRule ^/rsrc/(.*)     -                       [L,QSA]
        RewriteRule ^/favicon.ico   -                       [L,QSA]
        RewriteRule ^(.*)$          /index.php?__path__=$1  [B,L,QSA]
<Directory "/var/www/phabricator/phabricator/webroot">
        Order allow,deny
        Allow from all
</Directory>
</VirtualHost>" > /etc/apache2/sites-available/000-default.conf

sudo a2ensite 000-default.conf

sudo service apache2 reload

cd /var/www/phabricator/phabricator/

./bin/config set mysql.host localhost && ./bin/config set mysql.user root && ./bin/config set mysql.pass cabbage

./bin/storage upgrade --user root --password cabbage


sudo service mysql restart

echo "yaY"
#start firefox to show Phabricator ui
firefox http://127.0.0.1:80
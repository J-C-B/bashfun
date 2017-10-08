#!/bin/bash -x
# source <ssinclude StackScriptID=1>
# <UDF name="mmurl" Label="URL to access it (e.g., mattermark.example.com)" />
# <UDF name="dbpass" Label="Postgres account user password" />
# <UDF name="userpass" Label="mattermost system user account password" />
 
# http://askubuntu.com/questions/146921/how-do-i-apt-get-y-dist-upgrade-without-a-grub-config-prompt
 
sudo apt-get -y update
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" dist-upgrade
sudo DEBIAN_FRONTEND=noninteractive apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" upgrade
#sudo apt-get -y upgrade
 
# for mkpasswd
sudo apt-get -y install whois
sudo apt-get -y install postgresql postgresql-contrib
 
sudo -H -u postgres bash -c 'psql -c "CREATE DATABASE mattermost;"'
 
su - postgres -c 'psql -c "CREATE DATABASE mattermost;"'
#su - postgres -c 'psql -c "CREATE USER mmuser WITH PASSWORD '\''$DBPASS'\'';"'
su - postgres -c "psql -c \"CREATE USER mmuser WITH PASSWORD '$DBPASS';\""
 
su - postgres -c 'psql -c "GRANT ALL PRIVILEGES ON DATABASE mattermost to mmuser;"'
 
useradd mattermost -s /bin/bash -p `mkpasswd $USERPASS` -m
 
su - mattermost -c "wget https://releases.mattermost.com/4.2.0/mattermost-4.2.0-linux-amd64.tar.gz"
cd ~mattermost
tar xvzf mattermost-team-3.2.0-linux-amd64.tar.gz


mv mattermost/* .
mkdir data
chown -R mattermost.mattermost *
 
sed -i 's/DriverName\": \"mysql\"/DriverName\": \"postgres\"/' config/config.json
sed -i "s/\"DataSource\": \"mmuser:mostest@tcp(dockerhost:3306)\/mattermost_test?charset=utf8mb4,utf8\"/\"DataSource\": \"postgres:\/\/mmuser:$DBPASS@127.0.0.1:5432\/mattermost?sslmode=disable\&connect_timeout=10\"/" config/config.json
 
sudo touch /etc/init/mattermost.conf
echo start on runlevel [2345] > /etc/init/mattermost.conf
echo stop on runlevel [016] >> /etc/init/mattermost.conf
echo respawn >> /etc/init/mattermost.conf
echo chdir /home/mattermost >> /etc/init/mattermost.conf
echo setuid mattermost >> /etc/init/mattermost.conf
echo exec bin/platform >> /etc/init/mattermost.conf
 
sudo start mattermost
 
sudo apt-get -y install nginx
sudo touch /etc/nginx/sites-available/mattermost
 
cat <<EOT >> /etc/nginx/sites-available/mattermost
server {
    server_name $MMURL;
    location / {
        client_max_body_size 50M;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$http_host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_set_header   X-Frame-Options   SAMEORIGIN;
        proxy_pass http://localhost:8065;
    }
}
EOT
 
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/mattermost /etc/nginx/sites-enabled/mattermost
sudo service nginx restart


####### gitlab

curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash

sudo apt-get install gitlab-ce

sudo dpkg --configure -a

sudo apt-get install gitlab-ce
    
sudo gitlab-ctl reconfigure

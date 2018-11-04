#!/bin/bash

## stop and remove container and image
docker stop postfix_postfix_1
docker rm postfix_postfix_1
docker rmi postfix_postfix

## remove permanent files
sudo rm -fvr /data/postfix

## copy permanent files
if [ ! -d /data/postfix ]; then
	sudo mkdir -p /data/postfix
	sudo mkdir -p /data/postfix/ssl
	sudo mkdir -p /data/postfix/etc
	sudo mkdir -p /data/postfix/log
	sudo mkdir -p /data/postfix/dovecot
	sudo touch /data/postfix/log/mail.log
	sudo cp ./ssl/* /data/postfix/ssl/
	sudo cp -r ./origine/postfix/* /data/postfix/etc/
	sudo cp ./etc/* /data/postfix/etc/
fi

if [ ! -d /data/mail ]; then
    sudo mkdir -p /data/mail
fi

sudo sed -i -e "s/##MYHOSTNAME##/$HOSTNAME/g" /data/postfix/etc/main.cf
sudo sed -i -e "s/##MYDOMAIN##/localdomain/g" /data/postfix/etc/main.cf
sudo sed -i -e "s/##VIRTUAL_ALIAS_DOMAINS##/omega3.me/g" /data/postfix/etc/main.cf

sudo cp -r ./dovecot/* /data/postfix/dovecot/
sudo chmod +r /data/postfix/dovecot/users

# rebuild postfix image and run container
docker-compose up -d --build postfix
docker exec -it postfix_postfix_1 postmap /etc/postfix/virtual
docker restart postfix_postfix_1
#!/bin/bash

## stop and remove container and image
docker stop postfix_postfix_1
docker rm postfix_postfix_1
docker rmi postfix_postfix

if [ ! -d /data/postfix/mail ]; then
    sudo mkdir -p /data/postfix/mail
    sudo chown 2222:2222 /data/postfix/mail
fi

# rebuild postfix image and run container
docker-compose up -d --build postfix

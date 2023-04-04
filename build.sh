#!/bin/bash
## Environnement definitions
# Persistent root path (to store certificates and openDKIM keys)
ROOT="/opt/postfix"
OPENDKIM="$ROOT/opendkim"
SSL="$ROOT/ssl"
COUNTRY="CH"
CITY="Froideville"
ORGANISATION="get-code.ch"

## stop and remove container and image
docker stop postfix_postfix_1
docker rm postfix_postfix_1

## Creating empty files if opendkim persistent folder doesn't exist
if [ ! -d $OPENDKIM/ ]; then
    sudo mkdir -p $OPENDKIM/
    ## creating 
    sudo touch $OPENDKIM/signing_table
    sudo touch $OPENDKIM/key_table
fi

## Creating folder for certificates with self-signed certificates
if [ ! -d $SSL/ ]; then 
    sudo mkdir -p $SSL/
    sudo chown -fvR $USER:$USER $SSL/
    # Generate self-signed certificate CA
    openssl req -x509  -sha256 -days 3650 \
             -nodes  -newkey rsa:2048 \
             -subj "/CN=$HOSTNAME/C=$COUNTRY/L=$CITY" \
             -keyout $SSL/ca.key -out $SSL/ca.crt
    # Generate server certificate
    openssl req -new -newkey rsa:4096 -nodes \
             -keyout $SSL/server.key -out $SSL/server.csr \
             -subj "/C=$COUNTRY/L=$CITY/O=$ORGANISATION/CN=$HOSTNAME"
    openssl x509 -req -sha256 -days 365 \
            -in $SSL/server.csr \
            -CA $SSL/ca.crt -CAkey $SSL/ca.key \
            -CAcreateserial -out $SSL/server.crt 
fi
## Copying certficates to project
cp $SSL/ca.crt ./ssl/
cp $SSL/server.crt ./ssl/
cp $SSL/server.key ./ssl/

if [ -f "${ROOT}/users" ]; then
  cp $ROOT/users ./dovecot/
fi

if [ -f "${ROOT}/network_table" ]; then
  cp $ROOT/network_table ./postfix/
fi

## creating DKIM key
if [[ "$1" == "genkey" ]]; then
    docker stop postfix_genkey_1
    docker rm postfix_genkey_1
    docker build --tag genkey:1.0 ./genkey/
    docker run --name postfix_genkey_1 \
            --mount type=bind,src=$OPENDKIM,dst=/data genkey:1.0
fi

## copying openDKIM files
cp $OPENDKIM/signing_table ./opendkim/etc/
cp $OPENDKIM/key_table ./opendkim/etc/
cp $OPENDKIM/*.key ./opendkim/etc/

# rebuild postfix image and run container
docker build --tag postfix:1.0 --build-arg HOSTNAME="${HOSTNAME}" .
docker run --detach --restart always --name postfix_postfix_1 \
        --publish 25:25 --publish 587:587 --publish 465:465 \
        postfix:1.0

## removing certificates from project
rm ./ssl/ca.crt
rm ./ssl/server.crt
rm ./ssl/server.key

## removing openDKIM files from project
rm ./opendkim/etc/signing_table
rm ./opendkim/etc/key_table
rm ./opendkim/etc/*.key

## if users file exist in "permanent" parameters folder remove them in building folder
if [ -f "${ROOT}/users" ]; then
  rm ./dovecot/users
fi

if [ -f "${ROOT}/network_table" ]; then
  rm ./postfix/network_table
fi

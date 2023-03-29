#! /bin/bash
## Script constant environment variable
SIGING_TABLE="/data/signing_table"
KEY_TABLE="/data/key_table_wrk"
KEY_OUTPUT="/data/"
KEYFILE_PATH="/etc/opendkim"

declare -a DOMAIN_ARRAY
N=0

## reading Domains on SIGNING_TABLE file (this file is used by opendkim and contain list of selector)
while read domain; do
    DOMAIN_ARRAY[((N++))]="$domain"
done < $SIGING_TABLE
if [ $N -le 0 ]; then
    echo "No domain in $SIGNING_TABLE"
    exit 1
fi

## creating key_table file
:> $KEY_TABLE

## generating DKIM key files and adding records in key_table file
for record in "${DOMAIN_ARRAY[@]}"; do
    ## building key_table record
    split=( $(grep -Eo '\S*' <<<"$record") )
    domain="${split[0]}"
    full_selector="${split[1]}"
    selector=( $(grep -Eo '[^.]*' <<<"$full_selector")[0] )
    filename_key="${domain//./_}_${selector}.key"
    filename_txt="${domain//./_}_${selector}.txt"

    ## generating key 
    opendkim-genkey -d $domain -b 2048 -a -r -s $selector -D $KEY_OUTPUT
    mv "${KEY_OUTPUT}/${selector}.private" "${KEY_OUTPUT}/${filename_key}"
    chmod +r "${KEY_OUTPUT}/${filename_key}"

    mv "${KEY_OUTPUT}/${selector}.txt" "${KEY_OUTPUT}/${filename_txt}"
    chmod +r "${KEY_OUTPUT}/${filename_txt}"

    ## saving record in file
    echo "${selector}._domainkey.${domain} ${domain}:${selector}:${KEYFILE_PATH}/${filename_key}" | tee -a $KEY_TABLE

    ## diplay DNS Record informations
    echo "------------------- ${selector} -------------------"
    cat "${KEY_OUTPUT}/${filename_txt}"
    echo "---------------------------------------------------"
done
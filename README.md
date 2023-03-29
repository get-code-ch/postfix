# Installation & configuration
## postfix configuration files
### main.cf
Ready to use, automatically updated by Dockerfile
### master.cf
Ready to use
### network_table
This file contains a list of authorised host to relay mail without authentication
### postfix-files
default postfix config
### vmail_alias
default postfix config
### vmail_domains
default postfix config
### vmail_mailbox
default postfix config
## dovecot configuration files
Except "users" file all files are ready to use.
### users
This files contains list of SMTP users/passwords
file format is:

`username:{scheme}encrypted password` 

Example:

`yahoo:{SHA-512}$6$q4OGgzqWvxMlj6Q8$4PhNDsySJokWsTtSsWBtvnj.Cf141V40SlEl8qLMR7SMRj/UFoutwd3UDh.qG.Tei8x/c.ThkUBZ74l1a7v7z/`

Password can be genrated with openssl

`openssl passwd -6`

[More informations](https://doc.dovecot.org/configuration_manual/authentication/password_schemes/)


## Server testing
### Testing with openssl
`openssl s_client -connect host.domain.com:587 -starttls smtp`

### Testing with swaks 
[Swaks github repository](https://github.com/jetmore/swaks)

`swaks --from test@localhost --to dest@domain.com --auth-user testuser --protocol ESMTPSA`

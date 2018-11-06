# postfix
## Testing with openssl
`openssl s_client -connect host.domain.com:587 -starttls smtp`

## Testing with swaks 
[jetmore.org/john/code/swaks/](http://jetmore.org/john/code/swaks/)

`swaks --from test@localhost --to dest@domain.com --auth-user claude --protocol ESMTPSA`

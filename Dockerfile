FROM alpine:latest
MAINTAINER Claude Debieux <claude@get-code.ch>

RUN apk add --no-cache --update supervisor rsyslog bash postfix ca-certificates openssl dovecot

# postfix conf
RUN mkdir -p /var/run/postfix
RUN postalias  hash:/etc/postfix/aliases

# dovecot conf
RUN chmod +r /etc/dovecot/users 

RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
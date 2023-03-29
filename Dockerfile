##
## Building postfix containter 
##
FROM debian:11-slim
LABEL maintainer="Claude Debieux <claude@get-code.ch>"

## 
## Getting arguments
##
ARG HOSTNAME

## Installing debian required packages
RUN apt -q update
RUN apt -q upgrade -y
RUN apt -q install -y supervisor rsyslog bash ca-certificates openssl
RUN echo  "postfix postfix/main_mailer_type string 'No configuration'" | debconf-set-selections
RUN apt -q install -y postfix
RUN apt -q install -y postfix-lmdb dovecot-core opendkim opendkim-tools

## system configuration
RUN cp /usr/share/zoneinfo/Europe/Zurich /etc/localtime
RUN echo "Europe/Zurich" > /etc/timezone

# postfix conf
RUN mkdir -p /var/run/postfix
COPY ./postfix /etc/postfix/

# setting hostname in postfix file
RUN echo "${HOSTNAME}"
RUN sed -i -e "s/##MYHOSTNAME##/$HOSTNAME/g" /etc/postfix/main.cf

RUN mkdir -p /var/log/postfix
RUN touch /var/log/postfix/mail.log

RUN postmap lmdb:/etc/postfix/vmail_domains
RUN postmap lmdb:/etc/postfix/vmail_mailbox
RUN postmap lmdb:/etc/postfix/vmail_alias
RUN postalias lmdb:/etc/postfix/aliases

# dovecot conf
COPY ./dovecot/ /etc/dovecot/
RUN chmod +r /etc/dovecot/users
RUN touch /var/log/dovecot

# certificate install
COPY ./ssl /etc/postfix/ssl/

# OpenDKIM install
COPY ./opendkim/opendkim.conf /etc/opendkim.conf
COPY ./opendkim/etc /etc/opendkim/
RUN chown opendkim:opendkim /etc/opendkim/*.key
RUN chmod og-r /etc/opendkim/*.key
RUN usermod -a -G opendkim postfix

# supervisor
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
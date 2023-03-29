##
## Building image to configure DKIM keys, key_table file and signing_table file
## 
FROM debian:11-slim
LABEL maintainer="Claude Debieux <claude@get-code.ch>"

RUN apt -q update
RUN apt -q upgrade -y
RUN apt -q install -y opendkim-tools openssl

COPY . .
RUN chmod +x ./genkey.sh
CMD ./genkey.sh

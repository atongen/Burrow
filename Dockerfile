FROM golang:alpine

MAINTAINER LinkedIn Burrow "https://github.com/linkedin/Burrow"

RUN apk update && \
    apk add bash curl git && \
    rm -rf /var/cache/apk/*

RUN wget https://raw.githubusercontent.com/pote/gpm/v1.4.0/bin/gpm && \
    chmod +x gpm && \
    mv gpm /usr/local/bin

ADD . $GOPATH/src/github.com/linkedin/burrow
RUN cd $GOPATH/src/github.com/linkedin/burrow && \
    gpm install && \
    go install

RUN mkdir -p /etc/burrow

ADD docker-config/logging.cfg /etc/burrow
ADD docker-config/write_config.sh /usr/local/bin
ADD docker-config/run.sh /usr/local/bin

WORKDIR /var/tmp/burrow

CMD ["/usr/local/bin/run.sh"]

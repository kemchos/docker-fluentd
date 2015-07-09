FROM alpine:latest


RUN apk add --update build-base ruby ruby-dev ruby-bundler \
    && gem install fluentd --no-rdoc --no-ri \
    && gem install fluent-plugin-elasticsearch --no-rdoc --no-ri \
    && gem install fluent-plugin-norikra --no-rdoc --no-ri \
    && mkdir -p /etc/fluent \
    && fluentd --setup /etc/fluent \
    && apk del build-base \
    && rm /var/cache/apk/*

EXPOSE 24224

ENTRYPOINT ["/usr/bin/fluentd", "-c", "/etc/fluent/fluent.conf"]
FROM ruby:2.3.4-alpine

RUN echo "@edge http://nl.alpinelinux.org/alpine/edge/main" >> /etc/apk/repositories && \
    apk update && \
    apk add alpine-sdk && \
    rm -rf /var/cache/apk/*

ADD ./ opcnt
WORKDIR opcnt
RUN bundle install --path vendor/bundle

ENTRYPOINT ["bundle", "exec", "ruby", "oppai_count.rb"]

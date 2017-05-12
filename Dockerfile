FROM ruby:2.3.4-alpine

ADD ./ opcnt
WORKDIR opcnt
RUN bundle install --path vendor/bundle

ENTRYPOINT ["bundle", "exec", "ruby", "oppai_count.rb"]

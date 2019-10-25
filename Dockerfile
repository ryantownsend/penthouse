ARG RUBY_VERSION=2.5
ARG RAILS_VERSION=5.1.4
ARG PG_VERSION=1.1.4

FROM ruby:$RUBY_VERSION-alpine

RUN apk add --update build-base postgresql-dev tzdata git
RUN gem install bundler -v '2.0.2'

ENV RUBY_VERSION=$RUBY_VERSION
ENV RAILS_VERSION=$RAILS_VERSION
ENV PG_VERSION=$PG_VERSION

WORKDIR /app
ADD ./ /app/

ENTRYPOINT ["bundle", "exec"]

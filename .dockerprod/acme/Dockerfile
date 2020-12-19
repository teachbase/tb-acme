FROM ruby:2.6.3-slim-buster
SHELL ["/bin/bash", "-c"]

ARG BUNDLER_VERSION=1.17.3
ARG NGINX_VERSION=1.17.7
ARG APP_DIR=/webapps/tb_acme

# Install dependencies
COPY ./Aptfile /tmp/Aptfile
RUN apt-get update -qq && DEBIAN_FRONTEND=noninteractive apt-get -yq dist-upgrade && \
    DEBIAN_FRONTEND=noninteractive apt-get install -yq --no-install-recommends \
    build-essential \
    cron \
    $(cat /tmp/Aptfile | xargs) && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    truncate -s 0 /var/log/*log

# Set locale
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8
RUN update-locale LANG=C.UTF-8 LC_ALL=C.UTF-8

# Configure bundler and PATH
ENV GEM_HOME=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
ENV BUNDLE_PATH $GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
    BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH $APP_DIR/bin:$BUNDLE_BIN:$PATH

# Upgrade RubyGems and install required Bundler version
RUN gem update --system && \
    gem install bundler:$BUNDLER_VERSION

# # Create a directory for the app code
RUN mkdir -p $APP_DIR
WORKDIR $APP_DIR

COPY . $APP_DIR

# Copy config files
COPY config/secrets.prod.yml $APP_DIR/config/secrets.yml
RUN mkdir -p $APP_DIR/tmp/sockets && \
    mkdir -p $APP_DIR/tmp/pids && \
    mkdir -p $APP_DIR/log/ && \
    mkdir -p $APP_DIR/private

# Install gems
RUN bundle config set deployment 'true' && \
    bundle config set without 'test development' && \
    bundle install

ENV RACK_ENV=production
ENV APP_ROLE=master

# Update crontab
RUN bundle exec whenever --update-crontab

EXPOSE 9292

CMD cron && bundle exec puma -C config/puma.docker.rb

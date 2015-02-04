#!/bin/sh

cd /app
bundle install && \
bundle exec rackup -p 8080 -o 0.0.0.0 /app/config.ru -s $APPSERVER

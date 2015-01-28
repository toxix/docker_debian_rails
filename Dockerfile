# Dockerfile that create a base image for installing and running Ruby on Rails applications
# includes support for postgres, vips and imagemagic
# this is an extention to support development/testing with PhantomJS

FROM toxix/debian_rails

ENV PHANTOM_JS phantomjs-1.9.7-linux-x86_64

# Running apt-get in noninteractive mode
ENV DEBIAN_FRONTEND noninteractive


# Install dependencys for PhantomJS
# git is only needed if bundled gemfile contains a git reposetory to be complete this is also installed
RUN    apt-get update \
    && apt-get install -qq build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev curl\
    && apt-get clean -qq \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Download and install PhantomJS
RUN curl -L "https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2" \
        | tar -xjC /usr/local/share/ \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/share/phantomjs \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/bin/phantomjs

# unset the apt-get environment
ENV DEBIAN_FRONTEND [""]

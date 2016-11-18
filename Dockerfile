# Dockerfile that create a base image for installing and running Ruby on Rails applications:
# includes support for postgres, mysql, vips and imagemagic


FROM debian:stable

ENV RUBY_MAJOR 2.3
ENV RUBY_VERSION 2.3.2

RUN echo 'gem: --no-document --no-rdoc --no-ri' > /etc/gemrc

# Install dependencys for ruby and bundler
# git is only needed if bundled gemfile contains a git reposetory to be complete this is also installed
RUN    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq build-essential curl libffi-dev libgdbm-dev libncurses-dev libreadline6-dev libssl-dev libyaml-dev zlib1g-dev git \
    && apt-get clean -qq \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Install Ruby
RUN    mkdir -p /tmp/ruby \
    && curl -L "http://cache.ruby-lang.org/pub/ruby/$RUBY_MAJOR/ruby-$RUBY_VERSION.tar.bz2" \
    | tar -xjC /tmp/ruby --strip-components=1 \
    && cd /tmp/ruby \
    && ./configure --disable-install-doc \
    && make \
    && make install \
    && gem update --system \
    && rm -r /tmp/ruby

# Install Bundler
RUN gem install --no-document --no-ri --no-rdoc bundler



# vips, imagemagic and their dependencys consumes ~500MB !? :( so compiling them.
# Install build dependencys for imagemagic and vips
RUN    apt-get update -qq \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq pkg-config libglib2.0-dev libxml2-dev libexif-dev libjpeg-dev libtiff5-dev libpng12-dev liblcms2-dev liborc-0.4-dev libfftw3-dev \
    && apt-get clean -qq \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/


# Install imagemagic
#  compiling from source because don't want the dependencys of x11 (alternative to apt-get install libmagickwand-dev)
#  there is also an bugreport to this dependencys: https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=470671
#  ldconfig is needed to not have: error while loading shared libraries: libMagickCore.so.4
#  apt-get install pkg-config libpng12-0 libtiff5 liblcms2-2 libjpeg8
RUN    mkdir /tmp/im -p \
    && curl -L http://www.imagemagick.org/download/ImageMagick.tar.gz | tar -xzC /tmp/im --strip-components=1 \
    && cd /tmp/im \
    && ./configure --disable-docs \
    && make \
    && make install \
    && rm -r /tmp/im \
    && ldconfig /usr/local/lib
#    && ln -s /usr/local/include/ImageMagick-6/magick /usr/local/include/magick \
#    && ln -s /usr/local/include/ImageMagick-6/wand /usr/local/include/wand

# Install VIPS
#  compiling from source because don't want the dependencys of x11 (alternative to apt-get install libvips-dev)
#  apt-get install libglib2.0-0 libxml2 libexif12 libjpeg8 libtiff5 libpng12-0 liblcms2-2 liborc-0.4-0 libfftw3-3
RUN    mkdir -p /tmp/vips \
    && curl -L http://www.vips.ecs.soton.ac.uk/supported/current/vips-8.4.4.tar.gz | tar -xzC /tmp/vips --strip-components=1  \
    && cd /tmp/vips \
    && ./configure --disable-docs \
    && make \
    && make install \
    && rm -r /tmp/vips


# install postgres and mysql libs
RUN    apt-get -qq update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq libpq-dev libmysqlclient-dev  \
    && apt-get clean -qq \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# RUN bundle config path /ruby_gems/
# docker run --name ruby_gems_2-1 --volume /ruby_gems scratch true

# Add startupscript for Rails include a run of bundler
COPY start_rails.sh /

CMD [ "irb" ]

# Publish port 80
# EXPOSE 80


#######################################
# Install Development / Testing tools #
#######################################

ENV PHANTOM_JS phantomjs-1.9.7-linux-x86_64

# Install dependencys for PhantomJS, sqlite3 and npm/bower
RUN    apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -qq build-essential chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev curl sqlite3 libsqlite3-dev nodejs npm\
    && apt-get clean -qq \
    && rm -rf /var/lib/{apt,dpkg,cache,log}/

# Download and install PhantomJS
RUN curl -L "https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_JS.tar.bz2" \
        | tar -xjC /usr/local/share/ \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/share/phantomjs \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/local/bin/phantomjs \
    && ln -sf /usr/local/share/$PHANTOM_JS/bin/phantomjs /usr/bin/phantomjs
    
# install bower
# First alias nodejs with node
RUN ln -s /usr/bin/nodejs /usr/bin/node
RUN npm install -g bower

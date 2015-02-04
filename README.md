# docker_debian_rails
Docker file for Ruby on Rails based on Debian. 
 
Including support for imagemagick and vips.
Postgres or mysql libs are installed as well.



## Using it for your rails application
Put this docker file in your rails root directory (or modify it to your needs):
```
# rails_root_dir/Docker

FROM toxix/rails_vips
# Define working directory.
WORKDIR /app

ADD Gemfile /app/
ADD Gemfile.lock /app/

ENV GEM_HOME /gems/
# todo: move bundle install into an startup script. This is usefull because gems can be in a seperate docker volume and change at runtime
RUN bundle install

ADD . /app

VOLUME ["/gems", "/app"]

# Define default command.
CMD /start_rails.sh

# Expose ports.
EXPOSE 8080
```

Compile yor docker image with ```docker build [rails_root_directory]``` where '[rails_root_directory]' is the path to your rails root directory. Run your fresh image with docker and have fun.


If you consider to use PhantomJs, check out the dev-branch.

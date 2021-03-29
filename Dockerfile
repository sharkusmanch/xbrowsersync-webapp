FROM ruby:2.5

COPY ./src /bookmarks
COPY ./docker/nginx_install.sh /tmp/nginx_install.sh
COPY ./docker/run.sh /tmp/run.sh

WORKDIR /bookmarks

RUN gem install bundler && \
    bundle install && \
    /bin/bash /tmp/nginx_install.sh && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /www/data && \
    chown -R www-data:www-data /www/data

COPY ./docker/bookmarks.conf /etc/nginx/conf.d/bookmarks.conf

CMD [ "/bin/bash", "/tmp/run.sh" ]

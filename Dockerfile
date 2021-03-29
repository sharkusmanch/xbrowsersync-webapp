FROM ruby:2.5-alpine

COPY ./src /bookmarks
COPY ./docker/nginx_install.sh /tmp/nginx_install.sh
COPY ./docker/run.sh /tmp/run.sh

WORKDIR /bookmarks

RUN /bin/ash /tmp/nginx_install.sh && \
    apk add --no-cache libcurl build-base && \
    gem install bundler && \
    bundle install && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /www/data && \
    mkdir /run/nginx

COPY ./docker/bookmarks.conf /etc/nginx/conf.d/bookmarks.conf

CMD [ "/bin/ash", "/tmp/run.sh" ]

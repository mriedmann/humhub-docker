ARG HUMHUB_VERSION=1.4.1

FROM composer:1.9.3 as builder-composer

FROM alpine:3.11.3 as builder

ARG HUMHUB_VERSION

RUN apk update
RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    wget

WORKDIR /usr/src/
RUN wget https://github.com/humhub/humhub/archive/v${HUMHUB_VERSION}.tar.gz -q -O humhub.tar.gz && \
    tar xzf humhub.tar.gz && \
    mv humhub-${HUMHUB_VERSION} humhub && \
    rm humhub.tar.gz
    
WORKDIR /usr/src/humhub

COPY --from=builder-composer /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

RUN apk add --no-cache \
    php7 \
    php7-gd \
    php7-ldap \
    php7-json \
    php7-phar \
    php7-iconv \
    php7-openssl \
    php7-curl \
    php7-ctype \
    php7-dom \
    php7-mbstring \
    php7-simplexml \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-zip \
    php7-fileinfo

RUN composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader && \
    chmod +x protected/yii && \
    chmod +x protected/yii.bat

RUN apk add --no-cache \
    nodejs \
    npm

RUN npm install grunt
RUN npm install -g grunt-cli

RUN apk add --no-cache \
    php7-pdo_mysql
RUN grunt build-assets

RUN rm -rf ./node_modules

FROM alpine:3.11.3

ARG HUMHUB_VERSION

RUN apk add --no-cache \
    curl \
    ca-certificates \
    tzdata \
    php7 \
    php7-fpm \
    php7-pdo_mysql \
    php7-gd \
    php7-ldap \
    php7-json \
    php7-phar \
    php7-iconv \
    php7-openssl \
    php7-curl \
    php7-ctype \
    php7-dom \
    php7-mbstring \
    php7-simplexml \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-zip \
    php7-sqlite3 \
    php7-intl \
    php7-apcu \
    php7-exif \
    php7-fileinfo \
    php7-session \
    supervisor \
    nginx \
    sqlite \
    && rm -rf /var/cache/apk/*

RUN BUILD_DEPS="gettext"  \
    RUNTIME_DEPS="libintl" && \
    set -x && \
    apk add --no-cache --update $RUNTIME_DEPS && \
    apk add --no-cache --virtual build_deps $BUILD_DEPS && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del build_deps

ENV PHP_POST_MAX_SIZE=16M
ENV PHP_UPLOAD_MAX_FILESIZE=10M
ENV PHP_MAX_EXECUTION_TIME=60
ENV PHP_MEMORY_LIMIT=1G

RUN chown -R nginx:nginx /var/lib/nginx/ && \
    touch /var/run/supervisor.sock && \
    chmod 777 /var/run/supervisor.sock

COPY --from=builder --chown=nginx:nginx /usr/src/humhub /var/www/localhost/htdocs/
COPY --chown=nginx:nginx humhub/ /var/www/localhost/htdocs/

RUN mkdir -p /usr/src/humhub/protected/config/ && \
    cp -R /var/www/localhost/htdocs/protected/config/* /usr/src/humhub/protected/config/ && \
    echo "v${HUMHUB_VERSION}" >  /usr/src/humhub/.version

COPY etc/ /etc/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 600 /etc/crontabs/nginx && \
    chmod +x /usr/local/bin/docker-entrypoint.sh

VOLUME /var/www/localhost/htdocs/uploads
VOLUME /var/www/localhost/htdocs/protected/config
VOLUME /var/www/localhost/htdocs/protected/modules

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]

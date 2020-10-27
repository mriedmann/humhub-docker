ARG HUMHUB_VERSION
ARG VCS_REF

FROM composer:1.10.13 as builder-composer

FROM alpine:3.12.1 as builder

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
    php7-tokenizer \
    php7-exif \
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

FROM alpine:3.12.1 as base

ARG HUMHUB_VERSION
LABEL name="HumHub" version=${HUMHUB_VERSION} variant="base" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="HumHub" \
      org.label-schema.description="HumHub is a feature rich and highly flexible OpenSource Social Network Kit written in PHP" \
      org.label-schema.url="https://www.humhub.com/" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url="https://github.com/mriedmann/humhub-docker" \
      org.label-schema.vendor="HumHub GmbH" \
      org.label-schema.version=${HUMHUB_VERSION} \
      org.label-schema.schema-version="1.0"

RUN apk add --no-cache \
    curl \
    ca-certificates \
    imagemagick \
    tzdata \
    php7 \
    php7-fpm \
    php7-pdo_mysql \
    php7-gd \
    php7-ldap \
    php7-json \
    php7-phar \
    php7-iconv \
    php7-pecl-imagick \
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
ENV PHP_TIMEZONE=UTC

RUN touch /var/run/supervisor.sock && \
    chmod 777 /var/run/supervisor.sock

# 100=nginx 101=nginx (group)
COPY --from=builder --chown=100:101 /usr/src/humhub /var/www/localhost/htdocs/
COPY --chown=100:101 humhub/ /var/www/localhost/htdocs/

RUN mkdir -p /usr/src/humhub/protected/config/ && \
    cp -R /var/www/localhost/htdocs/protected/config/* /usr/src/humhub/protected/config/ && \
    rm -f var/www/localhost/htdocs/protected/config/common.php /usr/src/humhub/protected/config/common.php && \
    echo "v${HUMHUB_VERSION}" >  /usr/src/humhub/.version

COPY base/ /
COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN chmod 600 /etc/crontabs/nginx && \
    chmod +x /docker-entrypoint.sh

VOLUME /var/www/localhost/htdocs/uploads
VOLUME /var/www/localhost/htdocs/protected/config
VOLUME /var/www/localhost/htdocs/protected/modules

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]

FROM base as humhub_phponly

LABEL variant="phponly"

RUN apk add --no-cache fcgi

COPY phponly/ /

RUN wget -O /usr/local/bin/php-fpm-healthcheck \
 https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck \
 && chmod +x /usr/local/bin/php-fpm-healthcheck \
 && addgroup -g 101 -S nginx \
 && adduser --uid 100 -g 101 -S nginx

EXPOSE 9000

FROM nginx:stable-alpine as humhub_nginx

LABEL variant="nginx"

ENV NGINX_CLIENT_MAX_BODY_SIZE=10m \
    NGINX_KEEPALIVE_TIMEOUT=65 \
    NGINX_UPSTREAM=humhub:9000

COPY nginx/ /
COPY --from=builder --chown=nginx:nginx /usr/src/humhub/ /var/www/localhost/htdocs/

FROM base as humhub_allinone

LABEL variant="allinone"

RUN apk add --no-cache nginx

RUN chown -R nginx:nginx /var/lib/nginx/

COPY nginx/ /

EXPOSE 80

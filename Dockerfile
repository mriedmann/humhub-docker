ARG BUILD_DEPS="\
    ca-certificates \
    nodejs \
    npm \
    php8 \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-fileinfo \
    php8-gd \
    php8-iconv \
    php8-intl \
    php8-json \
    php8-ldap \
    php8-mbstring \
    php8-openssl \
    php8-pdo_mysql \
    php8-phar \
    php8-simplexml \
    php8-tokenizer \
    php8-xml \
    php8-xmlreader \
    php8-xmlwriter \
    php8-zip \
    tzdata \
    "

ARG RUNTIME_DEPS="\
    ca-certificates \
    curl \
    imagemagick \
    libintl \
    php8 \
    php8-apcu \
    php8-ctype \
    php8-curl \
    php8-dom \
    php8-exif \
    php8-fileinfo \
    php8-fpm \
    php8-gd \
    php8-iconv \
    php8-intl \
    php8-json \
    php8-ldap \
    php8-mbstring \
    php8-openssl \
    php8-pdo_mysql \
    php8-pecl-imagick \
    php8-phar \
    php8-session \
    php8-simplexml \
    php8-sqlite3 \
    php8-xml \
    php8-xmlreader \
    php8-xmlwriter \
    php8-zip \
    sqlite \
    supervisor \
    tzdata \
    "

FROM composer:2.4.2 as builder-composer

FROM docker.io/library/alpine:3.16.2 as builder

ARG HUMHUB_VERSION
ARG BUILD_DEPS

RUN apk add --no-cache --update $BUILD_DEPS && \
    rm -rf /var/cache/apk/*

COPY --from=builder-composer /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

WORKDIR /usr/src/
ADD https://github.com/humhub/humhub/archive/v${HUMHUB_VERSION}.tar.gz /usr/src/
RUN tar xzf v${HUMHUB_VERSION}.tar.gz && \
    mv humhub-${HUMHUB_VERSION} humhub && \
    rm v${HUMHUB_VERSION}.tar.gz
    
WORKDIR /usr/src/humhub

RUN composer config --no-plugins allow-plugins.yiisoft/yii2-composer true && \
    composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader && \
    chmod +x protected/yii && \
    chmod +x protected/yii.bat && \
    npm install grunt && \
    npm install -g grunt-cli && \
    grunt build-assets && \
    rm -rf ./node_modules

FROM docker.io/library/alpine:3.16.2 as base

ARG HUMHUB_VERSION
ARG RUNTIME_DEPS
ARG VCS_REF
ARG BUILD_DATE
LABEL name="HumHub" version="${HUMHUB_VERSION}-git-${VCS_REF}" variant="base" \
      org.label-schema.build-date=${BUILD_DATE} \
      org.label-schema.name="HumHub" \
      org.label-schema.description="HumHub is a feature rich and highly flexible OpenSource Social Network Kit written in PHP" \
      org.label-schema.url="https://www.humhub.com/" \
      org.label-schema.vcs-ref=${VCS_REF} \
      org.label-schema.vcs-url="https://github.com/dantefromhell/humhub-docker" \
      org.label-schema.vendor="HumHub GmbH" \
      org.label-schema.version="${HUMHUB_VERSION}-git-${VCS_REF}" \
      org.label-schema.schema-version="1.0"

RUN apk add --no-cache --update $RUNTIME_DEPS && \
    apk add --no-cache --virtual temp_pkgs gettext && \
    cp /usr/bin/envsubst /usr/local/bin/envsubst && \
    apk del temp_pkgs && \
    rm -rf /var/cache/apk/*

ENV PHP_POST_MAX_SIZE=128M
ENV PHP_UPLOAD_MAX_FILESIZE=100M
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

ADD https://raw.githubusercontent.com/renatomefi/php-fpm-healthcheck/master/php-fpm-healthcheck /usr/local/bin/php-fpm-healthcheck
RUN chmod +x /usr/local/bin/php-fpm-healthcheck \
 && addgroup -g 101 -S nginx \
 && adduser --uid 100 -g 101 -S nginx

EXPOSE 9000

FROM docker.io/library/nginx:1.23.1-alpine as humhub_nginx

LABEL variant="nginx"

ENV NGINX_CLIENT_MAX_BODY_SIZE=128m \
    NGINX_KEEPALIVE_TIMEOUT=65 \
    NGINX_UPSTREAM=humhub:9000

COPY nginx/ /
COPY --from=builder --chown=nginx:nginx /usr/src/humhub/ /var/www/localhost/htdocs/

FROM base as humhub_allinone

LABEL variant="allinone"

RUN apk add --no-cache nginx && \
    chown -R nginx:nginx /var/lib/nginx/

COPY nginx/ /

EXPOSE 80

FROM alpine:3.8 as builder

ENV HUMHUB_VERSION=v1.3.8

RUN apk update
RUN apk add \
    ca-certificates \
    tzdata \
    git

RUN mkdir /usr/src && cd /usr/src/ && \
    git clone --progress --verbose --branch $HUMHUB_VERSION https://github.com/humhub/humhub.git humhub
    
WORKDIR /usr/src/humhub

RUN rm -rf ./.git

COPY --from=composer:1.7 /usr/bin/composer /usr/bin/composer
RUN chmod +x /usr/bin/composer

RUN apk add \
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
    ;
RUN composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader && \
    chmod +x protected/yii && \
    chmod +x protected/yii.bat

RUN apk add nodejs npm
RUN npm install grunt
RUN npm install -g grunt-cli

RUN apk add php7-pdo_mysql
RUN grunt build-assets

RUN rm -rf ./node_modules


FROM alpine:3.8

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

RUN chown -R nginx:nginx /var/lib/nginx/ && \
    touch /var/run/supervisor.sock && \
    chmod 777 /var/run/supervisor.sock

COPY --from=builder --chown=nginx:nginx /usr/src/humhub /var/www/localhost/htdocs/
COPY --chown=nginx:nginx humhub/ /var/www/localhost/htdocs/

RUN mkdir -p /usr/src/humhub/protected/config/ && \
    cp -R /var/www/localhost/htdocs/protected/config/* /usr/src/humhub/protected/config/ && \
    echo "$HUMHUB_VERSION" >  /usr/src/humhub/.version

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

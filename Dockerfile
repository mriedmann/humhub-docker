FROM alpine:3.7

ENV HUMHUB_VERSION=v1.2.5

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    php7 \
    php7-fpm \
    php7-curl \
    php7-pdo_mysql \
    php7-zip \
    php7-exif \
    php7-intl \
    imagemagick \
    php7-ldap \
    php7-apcu \
    php7-memcached \
    php7-gd \
    php7-cli \
    php7-openssl \
    php7-phar \
    php7-json \
    php7-ctype \
    php7-iconv \
    php7-sqlite3 \
    php7-xml \
    supervisor \
    nginx \
    sqlite \
    git wget unzip \
    php7-zlib \
    php7-dom \
    php7-simplexml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-tokenizer \
    && rm -rf /var/cache/apk/*

RUN EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    wget -O composer-setup.php https://getcomposer.org/installer && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$EXPECTED_SIGNATURE') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

COPY composer/* /root/.composer/

RUN chown -R nginx:nginx /var/lib/nginx/ && \
    touch /var/run/supervisor.sock && \
    chmod 777 /var/run/supervisor.sock

RUN mkdir /usr/src && cd /usr/src/ && \
    git clone --branch $HUMHUB_VERSION https://github.com/humhub/humhub.git humhub && \
    cd humhub && \
    sed -i '/YII_DEBUG/s/^/\/\//' index.php && \
    sed -i '/YII_ENV/s/^/\/\//' index.php

COPY composer.lock /usr/src/humhub/

RUN cd /usr/src/humhub && \
    composer global require hirak/prestissimo && \
    composer global require "fxp/composer-asset-plugin:~1.4.2" && \
    composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader && \
    chmod +x protected/yii && \
    chmod +x protected/yii.bat

COPY config/ /usr/src/humhub/protected/config/
	
RUN cp -R /usr/src/humhub/* /var/www/localhost/htdocs/ && \
    chown -R nginx:nginx /var/www/localhost/htdocs/

COPY etc/ /etc/
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN chmod 600 /etc/crontabs/nginx && \
    chmod +x /usr/local/bin/docker-entrypoint.sh && \
    echo "$HUMHUB_VERSION" > /usr/src/humhub/.version

VOLUME /var/www/localhost/htdocs/uploads
VOLUME /var/www/localhost/htdocs/protected/config
VOLUME /var/www/localhost/htdocs/protected/modules

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["supervisord", "-n", "-c", "/etc/supervisord.conf"]

FROM alpine:3.3

ENV HUMHUB_VERSION=v1.2.3

RUN apk add --no-cache \
    ca-certificates \
    tzdata \
    php \
    php-fpm \
    php-curl \
    php-pdo_mysql \
    php-zip \
    php-exif \
    php-intl \
    imagemagick \
    php-ldap \
    php-apcu \
    php-memcache \
    php-gd \
    php-cli \
    php-openssl \
    php-phar \
    php-json \
    php-ctype \
    php-iconv \
    php-sqlite3 \
    php-xml \
    supervisor \
    nginx \
    sqlite \
    git wget unzip \
    php-zlib \
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

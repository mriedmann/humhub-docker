FROM alpine:3.3

ENV HUMHUB_VERSION=v1.2.2

RUN apk add --no-cache \
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
    && rm -rf /var/cache/apk/*

RUN EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" &&\
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '$EXPECTED_SIGNATURE') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

RUN mkdir /app && \
    cd /app && \
    git clone https://github.com/humhub/humhub.git humhub && \
    cd humhub && \
    git checkout $HUMHUB_VERSION && \
    sed -i '/YII_DEBUG/s/^/\/\//' index.php && \
    sed -i '/YII_ENV/s/^/\/\//' index.php

WORKDIR /app/humhub

COPY config.json /root/.composer/config.json
COPY auth.json /root/.composer/auth.json

RUN composer global require "fxp/composer-asset-plugin:~1.3" && \
    composer update --no-dev

RUN chmod +x protected/yii && \
    chmod +x protected/yii.bat && \
    chown -R nginx:nginx /app/humhub && \
	chown -R nginx:nginx /var/lib/nginx/ && \
	touch /var/run/supervisor.sock && \
	chmod 777 /var/run/supervisor.sock

COPY crontab /etc/crontabs/nginx
RUN chmod 600 /etc/crontabs/nginx

COPY pool.conf /etc/php-fpm.d/pool.conf
COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisord.conf	

VOLUME /app/humhub/uploads
VOLUME /app/humhub/protected/config
VOLUME /app/humhub/protected/modules

EXPOSE 80

CMD supervisord





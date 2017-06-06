FROM alpine:3.3

ENV HUMHUB_VERSION=v1.2.0

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
	supervisor \
	nginx \
	sqlite \
	git wget unzip \
    && rm -rf /var/cache/apk/*

ENV COMPOSER_HASH=669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410
	
RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '$COMPOSER_HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

RUN mkdir /app && \
    cd /app && \
    git clone https://github.com/humhub/humhub.git humhub && \
    cd humhub && \
    git checkout $HUMHUB_VERSION

WORKDIR /app/humhub

COPY config.json /root/.composer/config.json
COPY auth.json /root/.composer/auth.json

RUN composer global require "fxp/composer-asset-plugin:~1.1.0" && \
    composer update --no-dev

RUN chmod +x protected/yii && \
    chmod +x protected/yii.bat && \
    chown -R nginx:nginx /app/humhub && \
	chown -R nginx:nginx /var/lib/nginx/ && \
	touch /var/run/supervisor.sock && \
	chmod 777 /var/run/supervisor.sock

COPY pool.conf /etc/php-fpm.d/pool.conf
COPY nginx.conf /etc/nginx/nginx.conf
copy supervisord.conf /etc/supervisord.conf	

VOLUME /app/humhub/uploads
VOLUME /app/humhub/assets
VOLUME /app/humhub/protected/runtime
VOLUME /app/humhub/protected/config
VOLUME /app/humhub/protected/modules

EXPOSE 80

CMD supervisord





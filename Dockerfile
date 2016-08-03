FROM alpine

ENV HUMHUB_VERSION=v1.2.dev

RUN apk add --update \
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
	git wget unzip \
    && rm -rf /var/cache/apk/*

RUN php -r "readfile('https://getcomposer.org/installer');" > composer-setup.php && \
    php -r "if (hash('SHA384', file_get_contents('composer-setup.php')) === '7228c001f88bee97506740ef0888240bd8a760b046ee16db8f4095c0d8d525f2367663f22a46b48d072c816e7fe19959') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
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





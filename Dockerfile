FROM alpine:3.7

ENV HUMHUB_VERSION=1.3.2

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
    wget unzip \
    php7-zlib \
    php7-dom \
    php7-simplexml \
    php7-xmlreader \
    php7-xmlwriter \
    php7-tokenizer \
    php7-fileinfo \
    && rm -rf /var/cache/apk/*

RUN chown -R nginx:nginx /var/lib/nginx/ && \
    touch /var/run/supervisor.sock && \
    chmod 777 /var/run/supervisor.sock

RUN mkdir /usr/src && cd /usr/src/ && \
    wget -nv -O humhub.tgz "https://www.humhub.org/de/download/start?version=${HUMHUB_VERSION}&type=tar.gz" && \
    tar xzf humhub.tgz && \
    mv humhub-${HUMHUB_VERSION} humhub && \
    cd humhub && \
    sed -i '/YII_DEBUG/s/^/\/\//' index.php && \
    sed -i '/YII_ENV/s/^/\/\//' index.php && \
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

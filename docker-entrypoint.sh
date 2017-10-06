#!/bin/sh

if [ -z "$(ls -A /var/www/localhost/htdocs/uploads)" ]; then
   cp -rv /usr/src/humhub/uploads/* /var/www/localhost/htdocs/uploads/
fi

if [ -z "$(ls -A /var/www/localhost/htdocs/protected/config)" ]; then
   cp -rv /usr/src/humhub/protected/config/* /var/www/localhost/htdocs/protected/config/
fi

exec "$@"
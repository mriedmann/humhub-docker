#!/bin/sh

echo "=="
if [ -f "/var/www/localhost/htdocs/protected/config/.version" ]; then
  echo "installation found"
  INSTALL_VERSION=`cat /var/www/localhost/htdocs/protected/config/.version`
  SOURCE_VERSION=`cat /usr/src/humhub/.version`
  if [[ $INSTALL_VERSION != $SOURCE_VERSION ]]; then
    echo "updating from version $INSTALL_VERSION to $SOURCE_VERSION"
    cd /var/www/localhost/htdocs/protected/
    php yii migrate/up --includeModuleMigrations=1 --interactive=0
    php yii search/rebuild
    cp -v /usr/src/humhub/.version /var/www/localhost/htdocs/protected/config/.version
  fi
else
  echo "installing source files"
  cp -rv /usr/src/humhub/uploads/* /var/www/localhost/htdocs/uploads/
  cp -rv /usr/src/humhub/protected/config/* /var/www/localhost/htdocs/protected/config/
  cp -v /usr/src/humhub/.version /var/www/localhost/htdocs/protected/config/.version

  chown -R nginx:nginx /var/www/localhost/htdocs/uploads
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/modules
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/config
fi
echo "=="

exec "$@"

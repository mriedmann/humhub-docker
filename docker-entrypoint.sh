#!/bin/sh

wait_for_db () {
  until nc -z -v -w30 db 3306
  do
    echo "Waiting for database connection..."
    # wait for 5 seconds before check again
    sleep 5
  done
}

echo "=="
if [ -f "/var/www/localhost/htdocs/protected/config/dynamic.php" ]; then
  echo "Existing installation found!"
  
  wait_for_db
  
  INSTALL_VERSION=`cat /var/www/localhost/htdocs/protected/config/.version`
  SOURCE_VERSION=`cat /usr/src/humhub/.version`
  cd /var/www/localhost/htdocs/protected/
  if [[ $INSTALL_VERSION != $SOURCE_VERSION ]]; then
    echo "Updating from version $INSTALL_VERSION to $SOURCE_VERSION"
    php yii migrate/up --includeModuleMigrations=1 --interactive=0
    cp -v /usr/src/humhub/.version /var/www/localhost/htdocs/protected/config/.version
  fi
  
  php ./yii integrity/run
  if [ $? -ne 0 ]; then
    echo "validation failed!"
	exit 1
  fi
else
  echo "No existing installation found!"
  echo "Installing source files..."
  cp -rv /usr/src/humhub/uploads/* /var/www/localhost/htdocs/uploads/
  cp -rv /usr/src/humhub/protected/config/* /var/www/localhost/htdocs/protected/config/
  cp -v /usr/src/humhub/.version /var/www/localhost/htdocs/protected/config/.version

  echo "Writing config file..."
  sed -e "s/%%HUMHUB_DB_USER%%/$HUMHUB_DB_USER/g" \
      -e "s/%%HUMHUB_DB_PASSWORD%%/$HUMHUB_DB_PASSWORD/g" \
    /usr/src/humhub/protected/config/dynamic.php.tpl > /var/www/localhost/htdocs/protected/config/dynamic.php
  
  echo "Setting permissions..."
  chown -R nginx:nginx /var/www/localhost/htdocs/uploads
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/modules
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/config
  
  wait_for_db
  
  echo "Creating database..."
  cd /var/www/localhost/htdocs/protected/
  php yii migrate/up --includeModuleMigrations=1 --interactive=0
fi
echo "=="

exec "$@"

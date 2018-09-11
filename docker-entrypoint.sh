#!/bin/sh

INTEGRITY_CHECK=${HUMHUB_INTEGRITY_CHECK:-1}
WAIT_FOR_DB=${HUMHUB_WAIT_FOR_DB:-1}
SET_PJAX=${HUMHUB_SET_PJAX:-1}
AUTOINSTALL=${HUMHUB_AUTO_INSTALL:-"false"}

HUMHUB_DB_NAME=${HUMHUB_DB_NAME:-"humhub"}
HUMHUB_DB_HOST=${HUMHUB_DB_HOST:-"db"}
HUMHUB_NAME=${HUMHUB_NAME:-"HumHub"}
HUMHUB_LANG=${HUMHUB_NAME:-"en"}

wait_for_db () {
  if [ "$WAIT_FOR_DB" == "false" ]; then
    return 0
  fi

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
    php yii search/rebuild
    cp -v /usr/src/humhub/.version /var/www/localhost/htdocs/protected/config/.version
  fi

  echo "Setting permissions..."
  chown -R nginx:nginx /var/www/localhost/htdocs/uploads
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/modules
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/config
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/runtime

else
  echo "No existing installation found!"
  echo "Installing source files..."
  cp -rv /usr/src/humhub/uploads/* /var/www/localhost/htdocs/uploads/
  cp -rv /usr/src/humhub/protected/config/* /var/www/localhost/htdocs/protected/config/
  cp -v /usr/src/humhub/.version /var/www/localhost/htdocs/protected/config/.version
  
  echo "Setting permissions..."
  chown -R nginx:nginx /var/www/localhost/htdocs/uploads
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/modules
  chown -R nginx:nginx /var/www/localhost/htdocs/protected/config
  
  wait_for_db
  
  echo "Creating database..."
  cd /var/www/localhost/htdocs/protected/
  if [ -z "$HUMHUB_DB_USER" ]; then
    AUTOINSTALL="false"
  else
    echo "Writing config file..."
    sed -e "s/%%HUMHUB_DB_USER%%/$HUMHUB_DB_USER/g" \
      -e "s/%%HUMHUB_DB_PASSWORD%%/$HUMHUB_DB_PASSWORD/g" \
      -e "s/%%HUMHUB_DB_HOST%%/$HUMHUB_DB_HOST/g" \
      -e "s/%%HUMHUB_DB_NAME%%/$HUMHUB_DB_NAME/g" \
      -e "s/%%HUMHUB_NAME%%/$HUMHUB_NAME/g" \
      -e "s/%%HUMHUB_LANG%%/$HUMHUB_LANG/g" \
      /usr/src/humhub/protected/config/dynamic.php.tpl > /var/www/localhost/htdocs/protected/config/dynamic.php
	chown nginx:nginx /var/www/localhost/htdocs/protected/config/dynamic.php
    php yii migrate/up --includeModuleMigrations=1 --interactive=0
  fi

  if [ "$AUTOINSTALL" != "false" ]; then
    echo "Installing..."
    php yii installer/auto
    chown -R nginx:nginx /var/www/localhost/htdocs/protected/runtime
  fi
fi

if [ ! -f "/var/www/localhost/htdocs/protected/config/.installed" ]; then
  echo "Config preprocessing ..."
  
  if test -e /var/www/localhost/htdocs/protected/config/dynamic.php && \
  grep "'installed' => true" /var/www/localhost/htdocs/protected/config/dynamic.php -q; then
    echo "installation active"
	
	  if [ $SET_PJAX != "false" ]; then
      sed -i -e "s/'enablePjax' => false/'enablePjax' => true/g" /var/www/localhost/htdocs/protected/config/common.php
	  fi
	
	  touch /var/www/localhost/htdocs/protected/config/.installed
  else
    echo "no installation config found or not installed"
	INTEGRITY_CHECK="false"
  fi
fi

if [ "$INTEGRITY_CHECK" != "false" ]; then
  echo "validating ..."
  php ./yii integrity/run
  if [ $? -ne 0 ]; then
    echo "validation failed!"
  exit 1
  fi
else
  echo "validation skipped"
fi

echo "=="

exec "$@"

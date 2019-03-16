#!/bin/sh

INTEGRITY_CHECK="${HUMHUB_INTEGRITY_CHECK:-1}"
WAIT_FOR_DB="${HUMHUB_WAIT_FOR_DB:-1}"
SET_PJAX="${HUMHUB_SET_PJAX:-1}"
AUTOINSTALL="${HUMHUB_AUTO_INSTALL:-false}"

HUMHUB_HOST="${HUMHUB_HOST:-localhost}"
HUMHUB_PROTO="${HUMHUB_PROTO:-http}"
export HUMHUB_WEB_ROOT="${HUMHUB_WEB_ROOT:-/var/www/localhost/htdocs}"
export HUMHUB_SUB_DIR="${HUMHUB_SUB_DIR:-}"

HUMHUB_DB_NAME="${HUMHUB_DB_NAME:-humhub}"
HUMHUB_DB_HOST="${HUMHUB_DB_HOST:-db}"

HUMHUB_NAME="${HUMHUB_NAME:-HumHub}"
HUMHUB_EMAIL="${HUMHUB_EMAIL:-humhub@example.com}"
HUMHUB_LANG="${HUMHUB_LANG:-en-US}"

HUMHUB_DEBUG="${HUMHUB_DEBUG:-false}"
HUMHUB_CONFIG_TIMESTAMP="$(echo '<?php echo(time());' | php)"

wait_for_db () {
  if [ "$WAIT_FOR_DB" == "false" ]; then
    echo "Not waiting for database connection..."
    return 0
  fi

  until nc -z -v -w60 db 3306
  do
    echo "Waiting for database connection..."
    # wait for 5 seconds before checking again
    sleep 5
  done
}

echo "=="
if [ -f "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/dynamic.php" ]; then
  echo "Existing installation found!"

  wait_for_db

  INSTALL_VERSION="$(cat ${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/.version)"
  SOURCE_VERSION="$(cat /usr/src/humhub/.version)"
  cd "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}"
  if [[ $INSTALL_VERSION != $SOURCE_VERSION ]]; then
    echo "Updating from version $INSTALL_VERSION to $SOURCE_VERSION"
    php yii migrate/up --includeModuleMigrations=1 --interactive=0
    php yii search/rebuild
    cp -v /usr/src/humhub/.version "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/.version"
  fi
else
  echo "No existing installation found!"
  echo "Installing source files..."
  mv /tmp/humhub "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}"
  cp -rv /usr/src/humhub/protected/config/* "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/"
  cp -v /usr/src/humhub/.version "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/.version"

  wait_for_db

  echo "Creating database..."
  cd "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/"
  if [ -z "$HUMHUB_DB_USER" ]; then
    AUTOINSTALL="false"
  fi

  if [ "$AUTOINSTALL" != "false" ]; then
    echo "Installing..."
    php yii installer/write-db-config "$HUMHUB_DB_HOST" "$HUMHUB_DB_NAME" "$HUMHUB_DB_USER" "$HUMHUB_DB_PASSWORD"
    php yii installer/install-db
    php yii installer/write-site-config "$HUMHUB_NAME" "$HUMHUB_EMAIL"

    # Set baseUrl if provided
    if [ -n "$HUMHUB_PROTO" ] && [ -n "$HUMHUB_HOST" ]; then
      HUMHUB_BASE_URL="${HUMHUB_PROTO}://${HUMHUB_HOST}${HUMHUB_SUB_DIR}/"
      echo "Setting base url to: $HUMHUB_BASE_URL"
      php yii installer/set-base-url "${HUMHUB_BASE_URL}"
    php yii installer/create-admin-account "$HUMHUB_ADMIN_USER" "$HUMHUB_ADMIN_EMAIL" "$HUMHUB_ADMIN_PASSWORD"
    chown -R nginx:nginx "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/runtime"
  fi
fi

echo "Config preprocessing ..."

if test -e "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/dynamic.php" && \
  grep "'installed' => true" "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/dynamic.php" -q; then
  echo "installation active"

  if [ $SET_PJAX != "false" ]; then
    sed -i -e "s/'enablePjax' => false/'enablePjax' => true/g" "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/protected/config/common.php"
  fi
else
  echo "no installation config found or not installed"
  INTEGRITY_CHECK="false"
fi

if [ "$HUMHUB_DEBUG" == "false" ]; then
  sed -i '/YII_DEBUG/s/^\/*/\/\//' "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/index.php"
  sed -i '/YII_ENV/s/^\/*/\/\//' "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/index.php"
  echo "debug disabled"
else
  sed -i '/YII_DEBUG/s/^\/*//' "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/index.php"
  sed -i '/YII_ENV/s/^\/*//' "${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/index.php"
  echo "debug enabled"
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

$@

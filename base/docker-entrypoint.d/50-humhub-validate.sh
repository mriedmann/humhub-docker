#!/bin/sh

HUMHUB_INTEGRITY_CHECK=${HUMHUB_INTEGRITY_CHECK:-1}

if [ "$HUMHUB_INTEGRITY_CHECK" != "false" ]; then
	echo "validating ..."
	if ! php ./yii integrity/run; then
		echo "validation failed!"
		exit 1
	fi
else
	echo "validation skipped"
fi

echo >&3 "$0: Fixing file cache permissions after integrity check"
chown -R nginx:nginx /var/www/localhost/htdocs/protected/runtime

#!/bin/sh

HUMHUB_INTEGRITY_CHECK=${HUMHUB_INTEGRITY_CHECK:-1}

# TODO: Remove when debugging successful finished
echo >&3 "$0: Cache folder before integrity check"
date
ls -laR /var/www/localhost/htdocs/protected/runtime

if [ "$HUMHUB_INTEGRITY_CHECK" != "false" ]; then
	echo "validating ..."
	if ! php ./yii integrity/run; then
		echo "validation failed!"
		exit 1
	fi
else
	echo "validation skipped"
fi

# TODO: Remove when debugging successful finished
echo >&3 "$0: Cache folder after integrity check"
date
ls -laR /var/www/localhost/htdocs/protected/runtime

#!/bin/sh

HUMHUB_INTEGRITY_CHECK=${HUMHUB_INTEGRITY_CHECK:-1}

if [ "$HUMHUB_INTEGRITY_CHECK" != "false" ]; then
	echo "validating ..."
	if ! php ./yii integrity/run --interactive 0; then
		echo "validation failed!"
		exit 1
	fi
else
	echo "validation skipped"
fi

#!/bin/sh
# This script executes a ConfigController that parses all PHP files in @app/config/common.d/*.php
# into @app/config/common.php

# Stop script execution on weird shell conditions.
set -o errexit -o nounset

# Allow debugging this shell script by setting a shell variable called
# "TRACE" to value "1".
if [ "${TRACE:-0}" = "1" ]; then
  set -o xtrace
fi

echo "START === Configuring HumHub options"
su -s /bin/sh nginx -c "php /var/www/localhost/htdocs/protected/yii humhub/cfg-gen-common --interactive=0"
echo "END === DONE configuring HumHub"

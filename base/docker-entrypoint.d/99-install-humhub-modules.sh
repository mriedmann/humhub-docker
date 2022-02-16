#!/bin/sh

# TODO: Remove after this script has matured.
set -x

# Space seperated list of modules names to install, as displayed in the
# 'ID' column of `php yii module/list-online` command.
HUMHUB_MODULES="calendar spotify"


echo "Installing HumHub modules"
for module in ${HUMHUB_MODULES}
do
    echo "... Installing ${module}"
    su -s /bin/sh nginx -c "php yii module/install ${module}"
done

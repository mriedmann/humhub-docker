#!/bin/sh

# TODO: Remove after this script has matured more more.
set -x

# Space seperated list of modules names to install, as displayed in the
# 'ID' column of `php yii module/list-online` command.
HUMHUB_MODULES="calendar cfiles content-bookmarks gallery newmembers polls scrollup spotify tasks wiki"


echo "Installing HumHub modules"
for module in ${HUMHUB_MODULES}
do
    echo "... Installing ${module}"
    su -s /bin/sh nginx -c "php yii module/install ${module}"

    echo "... Enabling ${module}"
    su -s /bin/sh nginx -c "php yii module/enable ${module}"
done

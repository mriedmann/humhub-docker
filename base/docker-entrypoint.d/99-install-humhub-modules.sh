#!/bin/sh

# Space seperated list of modules names to install, as displayed in the
# 'ID' column of `php yii module/list-online` command.
HUMHUB_MODULES_ENABLED="calendar cfiles content-bookmarks gallery newmembers polls scrollup spotify tasks wiki"

echo "Installing HumHub modules"
for module in ${HUMHUB_MODULES_ENABLED}
do
    echo "... Installing module ${module}"
    su -s /bin/sh nginx -c "php yii module/install ${module}"

    echo "... Enabling module ${module}"
    su -s /bin/sh nginx -c "php yii module/enable ${module}"
done
echo "Module installation finished."


# Space separated list of modules name to disable, as displayed in the
# 'ID' column of `php yii module/list-online` command.
HUMHUB_MODULES_DISABLED=''

echo "Disabling HumHub modules"
for module in ${HUMHUB_MODULES_DISABLED}
do
    echo "... Disabling module ${module}"
    su -s /bin/sh nginx -c "php yii module/disable ${module}"
done
echo "Disabling modules finished."

#!/bin/sh

# Space seperated list of modules enabled per default, as displayed in the
# 'ID' column of `php yii module/list-online` command.
ENABLED_MODULES="calendar cfiles content-bookmarks external_calendar gallery newmembers polls scrollup spotify tasks wiki"

echo "Modules enabled by docker env: ${HUMHUB_ENABLE_MODULES}"
echo "Modules disabled by docker env: ${HUMHUB_DISABLE_MODULES}"


echo "Installing HumHub modules"
for module in ${ENABLED_MODULES}
do
    echo "... Installing module ${module}"
    su -s /bin/sh nginx -c "php yii module/install ${module}"

    echo "... Enabling module ${module}"
    su -s /bin/sh nginx -c "php yii module/enable ${module}"
done
echo "Module installation finished."


# Space separated list of modules name disabled per default, as displayed in the
# 'ID' column of `php yii module/list-online` command.
DISABLED_MODULES=''

echo "Disabling HumHub modules"
for module in ${DISABLED_MODULES}
do
    echo "... Disabling module ${module}"
    su -s /bin/sh nginx -c "php yii module/disable ${module}"
done
echo "Disabling modules finished."

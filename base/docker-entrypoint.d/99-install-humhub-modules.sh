#!/bin/sh

# All module names refer to the official name from the store, a complete listing can be
# obtained via the `php yii module/list-online` command.

# Per default enabled modules in all installations.
ENABLED_MODULES="calendar cfiles content-bookmarks external_calendar gallery newmembers polls scrollup tasks wiki"


echo "Installing HumHub modules"
echo "Modules enabled by docker env: ${HUMHUB_ENABLE_MODULES}"
for module in ${ENABLED_MODULES} ${HUMHUB_ENABLE_MODULES}
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
echo "Modules disabled by docker env: ${HUMHUB_DISABLE_MODULES}"
for module in ${DISABLED_MODULES} ${HUMHUB_DISABLE_MODULES}
do
    echo "... Disabling module ${module}"
    su -s /bin/sh nginx -c "php yii module/disable ${module}"
done
echo "Disabling modules finished."

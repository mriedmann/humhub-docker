#!/bin/sh

# All module names refer to the official name from the store, a complete listing can be
# obtained via the `php yii module/list-online` command.

echo "Installing HumHub modules"
echo "Modules enabled by docker env: ${HUMHUB_ENABLE_MODULES}"
for module in ${HUMHUB_ENABLE_MODULES}
do
    echo "... Installing module ${module}"
    su -s /bin/sh nginx -c "php yii module/install ${module} --interactive=0"

    echo "... Enabling module ${module}"
    su -s /bin/sh nginx -c "php yii module/enable ${module} --interactive=0"
done
echo "Module installation finished."


# Per default disabled modules in all installations.
DISABLED_MODULES=''

echo "Disabling HumHub modules"
echo "Modules disabled by docker env: ${HUMHUB_DISABLE_MODULES}"
for module in ${DISABLED_MODULES} ${HUMHUB_DISABLE_MODULES}
do
    echo "... Disabling module ${module}"
    su -s /bin/sh nginx -c "php yii module/disable ${module} --interactive=0"
done
echo "Disabling modules finished."

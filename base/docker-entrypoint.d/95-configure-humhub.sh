#!/bin/sh
# This script reads configuration options for a file provided via environment variable
# HUMHUB_CONFIG_FILE and applies the settings sequentially to this container during startup.

#TODO: Disable when mature
set -x

echo "START === Configuring HumHub options"
CONFIG_FILE="${HUMHUB_CONFIG_FILE:-none}"

# Stop if nothing needs to be done.
if [ "${CONFIG_FILE}" = "none" ]; then
  echo "No config file (or name none) provided, aborting..."
  exit 0
fi

# Check the file actually exists and is readable and has content.
if [ ! -r "${CONFIG_FILE}" ]; then
  echo "Config file ${CONFIG_FILE} either does not exist or is not readable."
fi
if [ ! -s "${CONFIG_FILE}" ]; then
  echo "Config file ${CONFIG_FILE} seems to be empty."
fi

# Actually do the stuff.
grep -v '^#' "${CONFIG_FILE}" | while read -r LINE; do 
  # su -s /bin/sh nginx -c "php yii settings/set "${moduleId}" "${name}" "${value}" --interactive=0"
  # su -s /bin/sh nginx -c "php yii settings/set ${LINE} --interactive=0"
  echo "Found config line: ${LINE}"
done

echo "END === DONE configuring HumHub"

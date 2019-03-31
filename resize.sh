#!/bin/ash

echo "$(date) - running resize loop..."
for file in $(find ${HUMHUB_WEB_ROOT}${HUMHUB_SUB_DIR}/uploads/file/ -name file); do
    echo "Checking $file"
    res="$(identify "$file")"
    if [ "$?" -eq "0" ]; then
        echo "$file is an image"
        convert "$file" -resize 1920x1920 "$file"
    fi
done

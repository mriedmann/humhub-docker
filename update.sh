#!/bin/bash

set -eo pipefail

CUR_VERSION=$(grep 'ARG HUMHUB_VERSION=' Dockerfile | tr "=" "\n" | tail -n 1)
NEW_VERSION=${NEW_VERSION:-$(curl -s https://api.github.com/repos/humhub/humhub/releases | jq -r '.[0] | .name')}
GIT_BRANCH="update-$NEW_VERSION"

export CUR_VERSION
export NEW_VERSION
export GIT_BRANCH

if [ "$CUR_VERSION" == "$NEW_VERSION" ]; then
    echo "no update needed"
    exit 1
else
    echo "updating from $CUR_VERSION to $NEW_VERSION"
fi



git branch "$GIT_BRANCH" || true
git checkout "$GIT_BRANCH"

sed -i -e "s/ARG HUMHUB_VERSION=[0-9\.]*/ARG HUMHUB_VERSION=$NEW_VERSION/" Dockerfile

sed -i -e "s/humhub:$CUR_VERSION/humhub:$NEW_VERSION/g" README.md
sed -i -e "s/\`$CUR_VERSION\`/\`$NEW_VERSION\`/g" README.md

git add README.md Dockerfile
git commit -m "update from $CUR_VERSION to $NEW_VERSION"

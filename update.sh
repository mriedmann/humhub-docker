#!/bin/bash

set -xeo pipefail

UPDATE_NEEDED=false
CUR_VERSION=""
NEW_VERSION=""
GIT_BRANCH=""

upstream_versions=$(curl -s https://api.github.com/repos/humhub/humhub/releases | jq -r '.[] | select(.prerelease==false) | .name' | sort --version-sort)

HUMHUB_VERSION=$(cat versions.txt)
MAJOR_VERSION=$(echo "$HUMHUB_VERSION" | cut -d'.' -f1)
MINOR_VERSION=$(echo "$HUMHUB_VERSION" | cut -d'.' -f2)
HUMHUB_MACRO_VERSION=${MAJOR_VERSION}.${MINOR_VERSION}

local_version=$HUMHUB_VERSION
local_version_prefix=$HUMHUB_MACRO_VERSION

latest_upstream_version=$(echo "$upstream_versions" | grep "$local_version_prefix" | tail -n1)
if [ "$local_version" != "$latest_upstream_version" ]; then
    echo "$local_version_prefix: UPDATE NEEDED! ($local_version != $latest_upstream_version)"
    echo "$latest_upstream_version" > versions.txt
    CUR_VERSION="$local_version"
    NEW_VERSION="$latest_upstream_version"
    UPDATE_NEEDED=true
    export CUR_VERSION
    export NEW_VERSION
    export UPDATE_NEEDED
else
    echo "$local_version_prefix: no update needed ($local_version == $latest_upstream_version)"
fi

if [ $UPDATE_NEEDED == true ]; then
    GIT_BRANCH="update-$NEW_VERSION"
    export GIT_BRANCH

    git branch "$GIT_BRANCH" || true
    git checkout "$GIT_BRANCH"

    git add versions.txt
    git commit -m "update from $CUR_VERSION to $NEW_VERSION"
fi

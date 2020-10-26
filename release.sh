#!/bin/bash

set -eo pipefail

src_image="ghcr.io/mriedmann/humhub"
dst_image="${1:-docker.io/mriedmann/humhub}"
variants=("allinone" "nginx" "phponly")

function publish_image() {
    src_version="$1"

    for variant in "${variants[@]}"; do
        if [ "$variant" == "allinone" ]; then
            postfix=""
        else
            postfix="-$variant"
        fi

        src_tag="master-${src_version}-$variant"
        for version in "$@"; do
            dst_tag="${version}$postfix"    
            echo "copy $src_image:$src_tag => $dst_image:$dst_tag"
            skopeo copy "docker://$src_image:$src_tag" "docker://$dst_image:$dst_tag"
        done
    done
}

publish_image 1.6.3 1.6 stable
publish_image 1.5.4 1.5
publish_image 1.4.5 1.4
 
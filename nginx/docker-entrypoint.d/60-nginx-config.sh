#!/bin/sh

set -e

# shellcheck disable=SC2046
defined_envs=$(printf "\${%s} " $(env | grep -E "^NGINX_.*" | cut -d= -f1))
envsubst "$defined_envs" </etc/nginx/nginx.conf >/tmp/nginx.conf
cat /tmp/nginx.conf >/etc/nginx/nginx.conf
rm /tmp/nginx.conf

exit 0

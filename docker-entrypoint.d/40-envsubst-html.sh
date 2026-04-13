#!/bin/sh
envsubst '${PH_HOSTS} ${PH_PASSWORD}' \
    < /usr/share/nginx/html/index.html.template \
    > /usr/share/nginx/html/index.html

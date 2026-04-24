#!/bin/sh
envsubst '${PH_HOSTS} ${PH_PASSWORD} ${APP_VERSION}' \
    < /usr/share/nginx/html/index.html.template \
    > /usr/share/nginx/html/index.html

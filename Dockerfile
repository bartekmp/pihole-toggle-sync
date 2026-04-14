FROM nginx:alpine

COPY www/index.html /usr/share/nginx/html/index.html.template
COPY www/favicon.svg /usr/share/nginx/html/favicon.svg
COPY www/manifest.json /usr/share/nginx/html/manifest.json
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY docker-entrypoint.d/40-envsubst-html.sh /docker-entrypoint.d/40-envsubst-html.sh
RUN chmod +x /docker-entrypoint.d/40-envsubst-html.sh

EXPOSE 80

LABEL org.opencontainers.image.title="pihole-toggle-sync"
LABEL org.opencontainers.image.description="Material Design 3 web UI for toggling Pi-hole blocking across multiple instances"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/bartekmp/pihole-toggle-sync"

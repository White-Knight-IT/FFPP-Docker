#!/bin/bash

# Get a skeleton nginx config in place simply for obtaining LE TLS certificate, envsubst will copy in the FFPP domain
envsubst '${ARG_FFPP_DOMAIN} ${ARG_NGINX_HTTP_PORT}' < /root/config/templates/nginx-cert-bootstrap.template > /etc/nginx/sites-available/$ARG_FFPP_DOMAIN

# Symlink our skeleton config into enabled nginx sites
ln -s /etc/nginx/sites-available/$ARG_FFPP_DOMAIN /etc/nginx/sites-enabled/$ARG_FFPP_DOMAIN

# Start nginx
nginx

# Get TLS certificate for FFPP
certbot --nginx -d $ARG_FFPP_DOMAIN --non-interactive --agree-tos -m "faux@ffpp.wow"

sleep 5

# Now if we were successful with cert lets put an actual config inplace that handles http redirect etc
if test -e "/etc/letsencrypt/live/$ARG_FFPP_DOMAIN/privkey.pem"; then
    envsubst '${ARG_FFPP_DOMAIN} ${ARG_NGINX_HTTP_PORT} ${ARG_NGINX_HTTPS_PORT}' < /root/config/templates/nginx-final.template > /etc/nginx/sites-available/$ARG_FFPP_DOMAIN
fi

# Kill nginx
kill $(cat /var/run/nginx.pid)

sleep 5

# Start nginx
nginx

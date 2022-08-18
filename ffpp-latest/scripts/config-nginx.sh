#!/bin/bash

# Get a skeleton nginx config in place simply for obtaining LE TLS certificate, envsubst will copy in the FFPP domain
envsubst '${FFPP_DOMAIN} ${NGINX_HTTP_PORT}' < /root/config/templates/nginx-cert-bootstrap.template > /etc/nginx/sites-available/$FFPP_DOMAIN

# Symlink our skeleton config into enabled nginx sites
ln -s /etc/nginx/sites-available/$FFPP_DOMAIN /etc/nginx/sites-enabled/$FFPP_DOMAIN

# Start nginx
nginx

# Get TLS certificate for FFPP
certbot --nginx -d $FFPP_DOMAIN --non-interactive --agree-tos -m "faux@ffpp.wow"

sleep 5

# Now if we were successful with cert lets put an actual config inplace that handles http redirect etc
if test -e "/etc/letsencrypt/live/$FFPP_DOMAIN/privkey.pem"; then
    envsubst '${FFPP_DOMAIN} ${NGINX_HTTP_PORT} ${NGINX_HTTPS_PORT}' < /root/config/templates/nginx-final.template > /etc/nginx/sites-available/$FFPP_DOMAIN
fi

# Kill nginx
kill $(cat /var/run/nginx.pid)

# Start nginx
nginx

# write 0 to stderr so docker is happy it succeeded (Even if it did not, so the container build can still proceed),
# is this necessary? Dunno, but seems like a good idea lol.
>&2 echo 0

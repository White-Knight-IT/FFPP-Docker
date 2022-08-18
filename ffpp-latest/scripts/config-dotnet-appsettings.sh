#!/bin/bash

if [ "$SHOW_DEV_ENDPOINTS" = "'false'"]
then
  export SHOW_DEV_ENDPOINTS=false
else
  export SHOW_DEV_ENDPOINTS=true
fi

envsubst '${FFPP_DOMAIN} ${MARIADB_USER} ${MARIADB_PASSWORD} ${MARIADB_SERVER} ${MARIADB_PORT} ${SHOW_DEV_ENDPOINTS} ${DNS_PROVIDER}' < /root/config/templates/appsettings.template > /root/ffpp/built/appsettings.json

cp /root/ffpp/built/appsettings.json /root/ffpp/src/FFPP/appsettings.json

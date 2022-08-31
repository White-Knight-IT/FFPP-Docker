FROM mariadb:jammy

ARG ARG_TIMEZONE

ARG ARG_MARIADB_USER

ARG ARG_MARIADB_PASSWORD

ARG ARG_MARIADB_PORT

ARG ARG_MARIADB_ROOT_PASSWORD

ENV TIMEZONE=$ARG_TIMEZONE

ENV MARIADB_USER=$ARG_MARIADB_USER

ENV MARIADB_PASSWORD=$ARG_MARIADB_PASSWORD

ENV MARIADB_PORT=$ARG_MARIADB_PORT

ENV MARIADB_ROOT_PASSWORD=$ARG_MARIADB_ROOT_PASSWORD

ENV MARIADB_ROOT_HOST=localhost

COPY config /root/config

COPY scripts /root/scripts

WORKDIR /root/scripts

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -yq

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install tzdata openssl ca-certificates nano dnsutils net-tools gettext-base

RUN . /root/scripts/config-mariadb.sh

# COPY ./sql-scripts/ /docker-entrypoint-initdb.d/

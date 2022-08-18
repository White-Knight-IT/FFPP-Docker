FROM mariadb:jammy

ARG TIMEZONE

ARG MARIADB_USER

ARG MARIADB_PASSWORD

ARG MARIADB_PORT

COPY config /root/config

COPY scripts /root/scripts

WORKDIR /root/scripts

RUN . /root/scripts/config-mariadb.sh

ENV MARIADB_RANDOM_ROOT_PASSWORD yes

ENV MARIADB_ROOT_HOST localhost

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -yq

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install tzdata openssl ca-certificates nano net-tools gettext-base

# COPY ./sql-scripts/ /docker-entrypoint-initdb.d/
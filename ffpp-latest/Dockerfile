
FROM mcr.microsoft.com/dotnet/sdk:6.0-jammy

ARG TIMEZONE

ARG FFPP_DOMAIN

ARG NGINX_HTTP_PORT

ARG NGINX_HTTPS_PORT

ARG MARIADB_USER

ARG MARIADB_PASSWORD

ARG MARIADB_SERVER

ARG MARIADB_PORT

ARG SHOW_DEV_ENDPOINTS

ARG DNS_PROVIDER

ENV PATH=${PATH}:/root/.dotnet/tools

ENV DOTNET_GENERATE_ASPNET_CERTIFICATE=true

ENV DOTNET_NUGET_SIGNATURE_VERIFICATION=true

RUN ln -snf /usr/share/zoneinfo/$TIMEZONE /etc/localtime && echo $TIMEZONE > /etc/timezone

RUN DEBIAN_FRONTEND=noninteractive apt-get update && apt-get upgrade -yq

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install tzdata openssl ca-certificates wget git mariadb-client nginx certbot python3-certbot-nginx nano net-tools gettext-base dnsutils

RUN dotnet tool install --global dotnet-ef

RUN mkdir /root/ffpp

RUN mkdir /root/ffpp/persistent

RUN mkdir /root/ffpp/persistent/nginx_logs

RUN mkdir /root/ffpp/persistent/nginx_logs/access

RUN mkdir /root/ffpp/persistent/nginx_logs/error

RUN mkdir /root/ffpp/built

RUN mkdir /root/ffpp/src

RUN mkdir /var/www/ffpp-webfront

WORKDIR /root/scripts

COPY scripts /root/scripts

COPY config /root/config

RUN cp  /root/config/moz-dhparam /etc/nginx/moz-dhparam

RUN cp /root/config/nginx.conf /etc/nginx/nginx.conf

RUN . /root/scripts/config-nginx.sh

RUN git clone https://github.com/White-Knight-IT/FFPP.git /root/ffpp/src

RUN . /root/scripts/config-dotnet-appsettings.sh

RUN dotnet build --configuration Release /root/ffpp/src/FFPP.sln

RUN rm /root/ffpp/src/FFPP/appsettings.Development.json

RUN cp -R /root/ffpp/src/FFPP/bin/Release/net6.0/wwwroot/* /var/www/ffpp-webfront

RUN mv /root/ffpp/src/FFPP/bin/Release/net6.0/* /root/ffpp/built

WORKDIR /var/www/

RUN find . -type f -exec chmod 0644 {} \;

RUN find . -type d -exec chmod 0755 {} \;

RUN chown www-data:www-data * -R

WORKDIR /root/ffpp/built

RUN chmod 555 /root/scripts/start.sh

CMD /root/scripts/start.sh

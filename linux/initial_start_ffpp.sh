#!/bin/bash

# **************************************************************************************************
# Configuration Options ******************* EDIT THESE OPTIONS TO YOUR REQUIREMENTS ****************
# **************************************************************************************************

# Enables Uncomplicated Firewall (UFW)
export CONF_ENABLE_UFW=true

# Checks DNS record for FFPP domain is pointing to this server. Do not change unless you have a good reason
export CONF_CHECK_DNS=true

# Forces the --build condition with docker compose which rebuilds the containers every time they are started
# not super useful for every day use
export CONF_ALWAYS_FORCE_CONTAINER_REBUILD=false

# If nginx, apache, mini-httpd or other web servers are running on the host we uninstall them because they
# will conflict with nginx hosted inside the ffpp docker container
export CONF_REMOVE_HOST_WEB_SERVERS=true

# **************************************************************************************************
# Environment variables ******************* EDIT THESE TO YOUR VALUES ******************************
# **************************************************************************************************

# You can find your timezone here: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
export ENV_TIMEZONE="Australia/Sydney"

# Enter the domain name you want to access your FFPP on, for e.g. ffpp.yourdomainhere.com
export ENV_FFPP_DOMAIN="ffpp.yourdomainhere.com"

# You really should not change this unless your host is already running nginx on 80
# You will need to reverse proxy to FFPP from the host nginx if you change this port
export ENV_NGINX_HTTP_PORT=80

# You really should not change this unless your host is already running nginx on 443
# You will need to reverse proxy to FFPP from the host nginx if you change this port
export ENV_NGINX_HTTPS_PORT=443

# DB user used by FFPP to access FFPP database in mariaDB, you can change it if you want
export ENV_MARIADB_USER="ffppapiservice"

# Password for above DB user, you can change it if you want
export ENV_MARIADB_PASSWORD="wellknownpassword"

# Password for root DB user, you can change it if you want
export ENV_MARIADB_ROOT_PASSWORD="wellknownpassword"

# Hostname or IP of mariaDB instance to use, probably you won't change this
export ENV_MARIADB_SERVER="127.0.0.1"

# Deliberately not the default 3306 in case your host already is running mariaDB/MySQL,
# you can change it if you want
export ENV_MARIADB_PORT=7704

# Expose development API endpoints for testing, you likely don't want this "'true'"/"'false'"
export ENV_SHOW_DEV_ENDPOINTS="'false'"

# Options are quad9, google, cloudflare
export ENV_DNS_PROVIDER="quad9"

# The port that this host (server) is using for SSH, default is always 22/tcp for SSH, only change this
# if you changed your SSH port else you will be locked out when Uncomplicated Firewall is enabled
# ********** WARNING *********** IF YOU FAF THIS YOU WILL BE LOCKED OUT FROM SSH TO THE HOST (SERVER)
export ENV_HOST_SSH_PORT="22/tcp"

# **************************************************************************************************
# ********************************** DO NOT EDIT BELOW THIS LINE ***********************************
# **************************************************************************************************














































































echo " "
echo "Start creation of FFPP accessable via: "$ENV_FFPP_DOMAIN

if [ "$ENV_FFPP_DOMAIN" = "ffpp.yourdomainhere.com" ]
then
  echo " "
  echo "** YOU MUST EDIT THE VARIABLES IN THIS SCRIPT BEFORE RUNING IT (e.g. run \"nano start_ffpp.sh\") ** - Exiting..."
  exit 1
fi
echo " "
echo "Installing Microsoft repository for powershell..."
echo " "

# Get Microsoft repository
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"

# Register the Microsoft repository
sudo dpkg -i packages-microsoft-prod.deb

# Remove the repository package now it is registered
sudo rm -rf packages-microsoft-prod.deb

# Update repo cache and upgrade any tools that need upgrading
sudo apt update && sudo apt upgrade -yq

# Uninstall any web servers on the host
if $CONF_REMOVE_HOST_WEB_SERVERS
then
  echo " "
  echo "**** UNINSTALLING ANY EXISTING WEB SERVERS ON HOST ****"
  echo " "
  sudo apt remove -yq nginx apache2 mini-httpd micro-httpd lighttpd caddy openlitespeed
fi

echo " "
echo "Installing tools on host..."
echo " "
# Install needed and useful tools on the host
sudo apt install -yq dnsutils docker.io docker-compose mariadb-client ufw ca-certificates apt-transport-https software-properties-common powershell curl gnupg2 lsb-release ubuntu-keyring

# Create our docker compose file from variables
envsubst '${ENV_TIMEZONE} ${ENV_FFPP_DOMAIN} ${ENV_NGINX_HTTP_PORT} ${ENV_NGINX_HTTPS_PORT} ${ENV_MARIADB_USER} ${ENV_MARIADB_PASSWORD} ${ENV_MARIADB_ROOT_PASSWORD} ${ENV_MARIADB_SERVER} ${ENV_MARIADB_PORT} ${ENV_SHOW_DEV_ENDPOINTS} ${ENV_DNS_PROVIDER}' < ./templates/compose.template > ./compose.yml

if $CONF_CHECK_DNS
then
  # Ensure that the FFPP domain name is pointing to this servers IP address (necessary for LE cert)
  export ENV_MY_IP="$(dig +short myip.opendns.com @resolver1.opendns.com)"
  export ENV_DOMAIN_FOUND_IP="$(dig +short ${ENV_FFPP_DOMAIN})"
  echo " "
  echo "This server IP address: "$ENV_MY_IP
  echo "The IP found in dns lookup for domain: "$ENV_FFPP_DOMAIN" is: "$ENV_DOMAIN_FOUND_IP
  echo " "

  if [ "$ENV_MY_IP" = "$ENV_DOMAIN_FOUND_IP" ]
  then
    echo "Great, FFPP domain is pointing to this server"
    echo " "
  else
    echo " "
    echo "ERROR: Server IP and Domain Lookup IP DO NOT MATCH!!!!! - Exiting..."
    echo " "
    exit 1
  fi
fi

if $CONF_ENABLE_UFW
then
  # UFW allow our ports
  sudo ufw allow $ENV_HOST_SSH_PORT
  sudo ufw allow $ENV_NGINX_HTTP_PORT"/tcp"
  sudo ufw allow $ENV_NGINX_HTTPS_PORT"/tcp"
  # Enable Uncomplicated Firewall this will block all inbound traffic except on the above ports
  sudo ufw --force enable
  echo " "
  echo "Enabled uncomplicated firewall (ufw)"
  echo " "
  # Show UFW status
  sudo ufw status numbered
fi

echo " "
echo "Start bootstrap app creation powershell script"
echo " "
# Run Powershell script to generate the bootstrap app used to get the FFPP API up and running
pwsh scripts/bootstrap.ps1

if $CONF_ALWAYS_FORCE_CONTAINER_REBUILD
then
  # Run our docker containers - they will always build
  echo " "
  echo "Rebuild the containers"
  echo " "
  sudo docker-compose up -d --build
else
  # Run our docker containers - they only build if they are not already built
  sudo docker-compose up -d
fi

echo " "
# Show running docker containers, hopefully both our containers are running
sudo docker ps

echo " "
echo "Waiting for 180 seconds..."
sleep 180
echo " "
echo " "
echo "Done! Access your FFPP instance to finalise setup at: https://"$ENV_FFPP_DOMAIN

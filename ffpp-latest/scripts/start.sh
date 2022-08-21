#!/bin/bash

# Kill nginx if it's running
kill $(cat /var/run/nginx.pid)

# Start nginx
nginx

# Start the FFPP API
dotnet /root/ffpp/built/ffpp.dll

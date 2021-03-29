#! /bin/bash

set -e

apt update
apt install curl ca-certificates lsb-release -y && \
echo "deb http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" | sudo tee /etc/apt/sources.list.d/nginx.list && \
apt update
apt install nginx -y 
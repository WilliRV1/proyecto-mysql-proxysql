#!/bin/bash
echo "🔧 Instalando ProxySQL..."

sudo apt update
sudo apt install -y wget lsb-release

wget https://github.com/sysown/proxysql/releases/download/v2.4.4/proxysql_2.4.4-ubuntu20_amd64.deb -O proxysql.deb
sudo dpkg -i proxysql.deb || sudo apt-get install -f -y

sudo systemctl start proxysql
sudo systemctl enable proxysql

echo "✅ ProxySQL instalado correctamente"

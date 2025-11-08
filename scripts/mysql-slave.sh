#!/bin/bash
echo "🗄️ Instalando MySQL Slave..."

# CONFIGURAR DNS PRIMERO
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Ahora instalar
sudo apt update
sudo apt install -y mysql-server

# Configurar MySQL
sudo sed -i 's/bind-address.*=.*127.0.0.1/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
sudo systemctl restart mysql
sudo systemctl enable mysql

echo "✅ MySQL Slave instalado en 192.168.50.20"
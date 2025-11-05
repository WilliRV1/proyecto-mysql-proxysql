#!/bin/bash
echo "🗄️ Instalando MySQL Slave..."

sudo apt update
sudo apt install -y mysql-server

sudo sed -i 's/bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf

sudo systemctl restart mysql
sudo systemctl enable mysql

echo "✅ MySQL Slave instalado en 192.168.50.20"

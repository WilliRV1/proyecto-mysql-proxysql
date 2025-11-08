#!/bin/bash
echo "🔧 Aplicando permisos en Master y Slave para ProxySQL..."

PROXY_IP="192.168.50.30"
MYSQL_USER="root"
# Esta es la contraseña que proxysql-config.sh
# le dice a ProxySQL que use para conectar al backend.
MYSQL_PASS="root" 

# 1. Configurar MASTER
echo "🧩 Configurando Master (192.168.50.10)..."
vagrant ssh mysql-master -c "sudo mysql -u root -e \"
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'$PROXY_IP' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASS';
  GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'$PROXY_IP' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
\""

# 2. Configurar SLAVE
echo "🧩 Configurando Slave (192.168.50.20)..."
vagrant ssh mysql-slave -c "sudo mysql -u root -e \"
  CREATE USER IF NOT EXISTS '$MYSQL_USER'@'$PROXY_IP' IDENTIFIED WITH mysql_native_password BY '$MYSQL_PASS';
  GRANT ALL PRIVILEGES ON *.* TO '$MYSQL_USER'@'$PROXY_IP' WITH GRANT OPTION;
  FLUSH PRIVILEGES;
\""

echo "✅ Permisos aplicados. ProxySQL ahora puede conectarse."
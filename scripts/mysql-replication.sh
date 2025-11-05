#!/bin/bash
echo "🔄 Configurando replicación MySQL Master-Slave..."

MASTER_IP="192.168.50.10"
SLAVE_IP="192.168.50.20"
REPL_USER="replicator"
REPL_PASS="replica123"
DB_NAME="mydb"

# 1️⃣ Configurar MASTER
echo "🧩 Configurando Master..."
vagrant ssh mysql-master -c "
  sudo cp /vagrant/configs/my-master.cnf /etc/mysql/mysql.conf.d/
  sudo systemctl restart mysql
  mysql -u root -e \"
    CREATE DATABASE IF NOT EXISTS $DB_NAME;
    CREATE USER IF NOT EXISTS '$REPL_USER'@'%' IDENTIFIED BY '$REPL_PASS';
    GRANT REPLICATION SLAVE ON *.* TO '$REPL_USER'@'%';
    FLUSH PRIVILEGES;
    FLUSH TABLES WITH READ LOCK;
    SHOW MASTER STATUS;
  \"
"

echo "✅ Master configurado."

# 2️⃣ Obtener posición del binlog
MASTER_STATUS=$(vagrant ssh mysql-master -c "mysql -u root -e 'SHOW MASTER STATUS\G'" | grep 'File\|Position')
MASTER_LOG_FILE=$(echo "$MASTER_STATUS" | grep 'File:' | awk '{print $2}')
MASTER_LOG_POS=$(echo "$MASTER_STATUS" | grep 'Position:' | awk '{print $2}')

# 3️⃣ Configurar SLAVE
echo "🧩 Configurando Slave..."
vagrant ssh mysql-slave -c "
  sudo cp /vagrant/configs/my-slave.cnf /etc/mysql/mysql.conf.d/
  sudo systemctl restart mysql
  mysql -u root -e \"
    STOP SLAVE;
    CHANGE MASTER TO
      MASTER_HOST='$MASTER_IP',
      MASTER_USER='$REPL_USER',
      MASTER_PASSWORD='$REPL_PASS',
      MASTER_LOG_FILE='$MASTER_LOG_FILE',
      MASTER_LOG_POS=$MASTER_LOG_POS;
    START SLAVE;
    SHOW SLAVE STATUS\G;
  \"
"

echo "✅ Replicación configurada correctamente."

#!/bin/bash
echo "🧪 Ejecutando pruebas de integración..."

# USAR 'mydb' EN LUGAR DE 'test_db'
DB="mydb"

# 1. Probar replicación
echo "1. Probando replicación MySQL..."
vagrant ssh mysql-master -c "sudo mysql -u root -e 'CREATE DATABASE IF NOT EXISTS $DB; USE $DB; CREATE TABLE IF NOT EXISTS test_table (id INT, data VARCHAR(100)); INSERT INTO $DB.test_table VALUES (1, \"test_master\");'"

sleep 5 # Dar tiempo a que replique

vagrant ssh mysql-slave -c "sudo mysql -u root -e 'USE $DB; SELECT * FROM test_table;'"

# 2. Probar ProxySQL
echo "2. Probando ProxySQL..."
# AÑADIR CONTRASEÑA '-proot'
vagrant ssh proxysql -c "mysql -u root -proot -h 127.0.0.1 -P6033 -e 'SELECT 1;'"

# 3. Probar enrutamiento
echo "3. Probando enrutamiento..."
# AÑADIR CONTRASEÑA '-proot' Y USAR '$DB'
vagrant ssh proxysql -c "mysql -u root -proot -h 127.0.0.1 -P6033 -e 'INSERT INTO $DB.test_table VALUES (2, \"via_proxysql\");'"
vagrant ssh proxysql -c "mysql -u root -proot -h 127.0.0.1 -P6033 -e 'SELECT * FROM $DB.test_table;'"

echo "✅ Pruebas completadas"
echo "Configurando ProxySQL..."

# Esperar un poco por si el servicio aún no está listo
sleep 5

# Instalar cliente MySQL si no está
sudo apt install -y mysql-client-core-8.0

# Ejecutar comandos SQL en ProxySQL
mysql -u admin -padmin -h 127.0.0.1 -P6032 <<EOF

-- Limpiar configuraciones previas
DELETE FROM mysql_servers;
DELETE FROM mysql_users;

-- Agregar servidores MySQL
INSERT INTO mysql_servers (hostgroup_id, hostname, port, status)
VALUES
(10, '192.168.50.10', 3306, 'ONLINE'),  -- Master
(20, '192.168.50.20', 3306, 'ONLINE');  -- Slave

-- Agregar usuario root para acceso
INSERT INTO mysql_users (username, password, default_hostgroup, transaction_persistent)
VALUES ('root', 'root', 10, 1);

-- Aplicar y guardar configuración
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
EOF

echo "ProxySQL configurado correctamente"
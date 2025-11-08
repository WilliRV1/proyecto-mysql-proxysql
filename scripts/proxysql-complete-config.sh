#!/bin/bash
echo "🎯 Completando configuración de ProxySQL..."

sleep 10  # Esperar que ProxySQL esté listo

mysql -u admin -padmin -h 127.0.0.1 -P6032 <<EOF

-- 1. Configurar reglas de enrutamiento
DELETE FROM mysql_query_rules;

INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup, apply) 
VALUES 
(1, 1, '^SELECT', 20, 1),     -- Lecturas al Slave
(2, 1, '^INSERT', 10, 1),     -- Escrituras al Master
(3, 1, '^UPDATE', 10, 1),
(4, 1, '^DELETE', 10, 1),
(5, 1, '^CREATE', 10, 1),
(6, 1, '^ALTER', 10, 1);

-- 2. Configurar monitoreo
UPDATE global_variables SET variable_value='2000' WHERE variable_name='mysql-monitor_connect_interval';
UPDATE global_variables SET variable_value='2000' WHERE variable_name='mysql-monitor_ping_interval';
UPDATE global_variables SET variable_value='1000' WHERE variable_name='mysql-monitor_read_only_interval';

-- 3. Aplicar configuración
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;

LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;

EOF

echo "✅ Configuración ProxySQL completada"
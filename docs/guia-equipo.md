# 🎯 Guía para el Equipo - Proyecto MySQL + ProxySQL

## 📋 División de Roles y Responsabilidades

### 👥 Integrantes:
- **🧑‍💻 Persona 1 (William)**: Infraestructura & Documentación - ✅ COMPLETADO
- **🗄️ Persona 2**: MySQL & Replicación
- **🚦 Persona 3**: ProxySQL & Balanceo  
- **📝 Persona 4**: Pruebas & Coordinación

---

## 🗄️ PERSONA 2: MySQL & REPLICACIÓN

### 🎯 Objetivo Principal:
Configurar la replicación Master-Slave entre los servidores MySQL

### 📁 Archivos de tu Responsabilidad:
configs/
├── my-master.cnf (CREAR - configuración Master)
└── my-slave.cnf (CREAR - configuración Slave)

scripts/
└── mysql-replicacion.sh (CREAR - script configuración)

docs/
└── mysql-setup.md (CREAR - documentación proceso)

text

### 🔧 Pasos a Seguir:

#### 1. **Configurar MySQL Master (192.168.50.10)**
```bash
# Conectarse al Master
vagrant ssh mysql-master

# Editar configuración
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Agregar estas líneas:
[mysqld]
server-id = 1
log_bin = /var/log/mysql/mysql-bin.log
binlog_do_db = proyecto_balanceo
bind-address = 0.0.0.0
2. Crear Usuario de Replicación
sql
-- En MySQL Master
CREATE USER 'replicador'@'192.168.50.20' IDENTIFIED BY 'password123';
GRANT REPLICATION SLAVE ON *.* TO 'replicador'@'192.168.50.20';
FLUSH PRIVILEGES;

-- Verificar estado
SHOW MASTER STATUS;
-- Anotar File y Position para el Slave
3. Configurar MySQL Slave (192.168.50.20)

# Conectarse al Slave
vagrant ssh mysql-slave

# Editar configuración
sudo nano /etc/mysql/mysql.conf.d/mysqld.cnf

# Agregar:
[mysqld]
server-id = 2
relay-log = /var/log/mysql/mysql-relay-bin.log
binlog_do_db = proyecto_balanceo
bind-address = 0.0.0.0
4. Iniciar Replicación
sql
-- En MySQL Slave
STOP SLAVE;

CHANGE MASTER TO 
MASTER_HOST='192.168.50.10',
MASTER_USER='replicador',
MASTER_PASSWORD='password123',
MASTER_LOG_FILE='mysql-bin.000001',  -- Usar el FILE del SHOW MASTER STATUS
MASTER_LOG_POS= 123;                 -- Usar el POSITION del SHOW MASTER STATUS

START SLAVE;

-- Verificar replicación
SHOW SLAVE STATUS\G
-- Buscar: Slave_IO_Running: Yes, Slave_SQL_Running: Yes
✅ Criterios de Éxito:
Replicación activa (SHOW SLAVE STATUS muestra ambos procesos corriendo)

Datos se replican del Master al Slave

Configuraciones guardadas en archivos del repositorio

🚦 PERSONA 3: PROXYSQL & BALANCEO
🎯 Objetivo Principal:
Configurar ProxySQL para balancear carga entre Master y Slave

📁 Archivos de tu Responsabilidad:
text
configs/
└── proxysql.cnf            (CREAR - configuración completa)

scripts/
└── proxysql-config.sh      (CREAR - script configuración)

pruebas/
└── proxysql-rules.sql      (CREAR - reglas SQL)

docs/
└── proxysql-setup.md       (CREAR - documentación proceso)
🔧 Pasos a Seguir:
1. Conectar a ProxySQL Admin

# Conectarse a ProxySQL
vagrant ssh proxysql

# Acceder a interfaz administrativa
mysql -u admin -padmin -h 127.0.0.1 -P 6032
2. Configurar Backends (Servidores MySQL)
sql
-- En ProxySQL Admin interface
INSERT INTO mysql_servers(hostgroup_id, hostname, port) 
VALUES 
(0, '192.168.50.10', 3306),  -- Master (escrituras)
(1, '192.168.50.20', 3306);  -- Slave (lecturas)

-- Cargar configuración a runtime
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;
3. Configurar Usuarios MySQL en ProxySQL
sql
-- Agregar usuario para conexiones via ProxySQL
INSERT INTO mysql_users(username, password, default_hostgroup) 
VALUES ('root', '', 0);

LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
4. Crear Reglas de Enrutamiento
sql
-- Reglas para diferenciar lecturas vs escrituras
INSERT INTO mysql_query_rules (rule_id, active, match_pattern, destination_hostgroup, apply) 
VALUES 
(1, 1, '^SELECT', 1, 1),           -- Lecturas → Slave (hostgroup 1)
(2, 1, '^INSERT', 0, 1),           -- Escrituras → Master (hostgroup 0)
(3, 1, '^UPDATE', 0, 1),
(4, 1, '^DELETE', 0, 1);

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
5. Configurar Monitoreo
sql
-- Configurar checks de salud
UPDATE global_variables SET variable_value='2000' WHERE variable_name='mysql-monitor_connect_interval';
UPDATE global_variables SET variable_value='2000' WHERE variable_name='mysql-monitor_ping_interval';
UPDATE global_variables SET variable_value='1000' WHERE variable_name='mysql-monitor_read_only_interval';

LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;
✅ Criterios de Éxito:
ProxySQL responde en puerto 6033 (SQL) y 6032 (Admin)

SELECT van al Slave, INSERT/UPDATE/DELETE van al Master

Monitoreo de servidores activo

Configuración persistente después de reinicios

📝 PERSONA 4: PRUEBAS & COORDINACIÓN
🎯 Objetivo Principal:
Crear pruebas automatizadas y documentar resultados

📁 Archivos de tu Responsabilidad:
text
pruebas/
├── pruebas-basicas.sql         (EXPANDIR - pruebas existentes)
├── pruebas-carga.sql           (CREAR - pruebas de carga)
└── pruebas-integracion.sql     (CREAR - pruebas integración)

docs/
├── resultados-pruebas.md       (CREAR - documentar resultados)
└── presentacion.md             (CREAR - preparar presentación)

README.md                       (ACTUALIZAR - documentación general)
🔧 Pasos a Seguir:
1. Crear Pruebas Básicas de Funcionamiento
sql
-- pruebas-basicas.sql
-- Conectar via ProxySQL: mysql -u root -h 192.168.50.30 -P 6033

-- Prueba 1: Crear base de datos y tabla
CREATE DATABASE IF NOT EXISTS proyecto_balanceo;
USE proyecto_balanceo;

CREATE TABLE IF NOT EXISTS transacciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(200),
    monto DECIMAL(10,2),
    fecha TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Prueba 2: Verificar escrituras (deben ir al Master)
INSERT INTO transacciones (descripcion, monto) VALUES 
('Prueba escritura 1', 100.50),
('Prueba escritura 2', 200.75);

-- Prueba 3: Verificar lecturas (deben ir al Slave)
SELECT * FROM transacciones;

-- Prueba 4: Verificar replicación
-- Conectar al Slave directamente y verificar datos
2. Crear Pruebas de Carga
sql
-- pruebas-carga.sql
-- Pruebas con múltiples conexiones simultáneas

-- Prueba de múltiples escrituras
INSERT INTO transacciones (descripcion, monto) VALUES 
('Carga prueba 1', 50.00),
('Carga prueba 2', 75.00);

-- Prueba de múltiples lecturas
SELECT COUNT(*) as total_transacciones FROM transacciones;
SELECT AVG(monto) as promedio_montos FROM transacciones;
3. Verificar Balanceo de Carga
sql
-- En ProxySQL Admin (6032) verificar estadísticas
SELECT * FROM stats_mysql_connection_pool;
SELECT * FROM stats_mysql_commands_counters;
SELECT * FROM mysql_query_rules;
4. Documentar Resultados
Crear docs/resultados-pruebas.md con:

Tiempos de respuesta

Comportamiento bajo carga

Verificación de enrutamiento

Fallos y recuperaciones

✅ Criterios de Éxito:
Pruebas básicas funcionando

Pruebas de carga implementadas

Resultados documentados claramente

README.md actualizado con instrucciones completas

🗓️ Cronograma de Entregas
JUEVES
Cada quien con su rama creada

Configuraciones iniciales funcionando

Primer commit en cada rama

VIERNES
Replicación MySQL 100% funcional

ProxySQL enrutando correctamente

Pruebas básicas documentadas

SÁBADO
Sistema completamente integrado

Pruebas de carga completas

Documentación técnica avanzada

DOMINGO
Revisión final y ajustes

Preparación presentación

LUNES
Presentación lista

Repositorio 100% completo

🔄 Flujo de Trabajo Git
Para comenzar cada día:

# Actualizar desde main
git checkout main
git pull origin main

# Cambiar a tu rama
git checkout tu-rama

# Traer cambios de main
git merge main
Para subir progreso:

# Agregar cambios
git add [archivos-modificados]

# Commit descriptivo
git commit -m "FEAT: [descripción clara de lo logrado]"

# Subir a tu rama
git push origin tu-rama
Ejemplos de mensajes de commit:
"FEAT: Configuración replicación MySQL Master-Slave"

"FEAT: ProxySQL backends y reglas de enrutamiento"

"FEAT: Script pruebas de carga implementado"

"DOC: Guía configuración MySQL completa"

📞 Soporte y Coordinación
¿Problemas técnicos?

Revisar logs: sudo journalctl -u mysql o sudo systemctl status proxysql

Verificar conectividad: ping entre VMs

Consultar documentación en esta guía

¿Dudas de configuración?

Revisar ejemplos en esta guía

Preguntar en el grupo

Coordinar reunión rápida
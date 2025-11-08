# 🚀 Proyecto: Balanceo de Carga MySQL con ProxySQL

Proyecto final para demostrar una arquitectura de alta disponibilidad y balanceo de carga para bases de datos MySQL utilizando replicación Master-Slave y un balanceador ProxySQL.

## 📊 Arquitectura

El entorno se provisiona con Vagrant y consta de 3 máquinas virtuales:

* **MySQL Master (Escrituras):** `192.168.50.10`
* **MySQL Slave (Lecturas):** `192.168.50.20`
* **ProxySQL (Balanceador):** `192.168.50.30`
* **Puerto Admin ProxySQL:** `6032`
* **Puerto SQL ProxySQL:** `6033`

## 🚀 Cómo Ejecutar el Proyecto (Paso a Paso)

**Requisitos:** Vagrant, VirtualBox y Git Bash (o un terminal bash).

1.  **Clonar y levantar la infraestructura:**
    ```bash
    git clone [URL-DE-TU-REPO]
    cd proyecto-mysql-proxysql
    vagrant up
    ```
    *(Esto creará las 3 VMs e instalará MySQL y ProxySQL, pero aún no están conectados entre sí).*

2.  **Configurar la Replicación Master-Slave:**
    *(Este script debe ejecutarse desde tu PC, no desde una VM).*
    ```bash
    bash scripts/mysql-replicacion.sh
    ```

3.  **Autorizar a ProxySQL en los Backends:**
    *(Este script también se ejecuta desde tu PC).*
    ```bash
    bash scripts/fix-backend-auth.sh
    ```
    **¡En este punto, el sistema está 100% operativo!**

## 🧪 Cómo Probar el Proyecto

### 1. Prueba de Integración (Funcional)
Verifica que el enrutamiento (Read/Write Split) y la replicación funcionan.
```bash
bash pruebas/test-integracion.sh
```

2. **Prueba de Carga (Sysbench)**
    Ejecuta una prueba de carga completa que instala sysbench, prepara las tablas, ejecuta la prueba por 60 segundos y limpia al terminar.

    # 1. Conéctate a la VM de proxysql
vagrant ssh proxysql

# 2. Una vez dentro de la VM, ejecuta el script:
bash /vagrant/pruebas/pruebas-carga.sh
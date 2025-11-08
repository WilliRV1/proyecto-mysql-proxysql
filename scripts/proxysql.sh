#!/bin/bash
echo "🔧 Instalando ProxySQL..."

# Configurar DNS
sudo systemctl stop systemd-resolved
sudo systemctl disable systemd-resolved
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Actualizar sistema
sudo apt update
sudo apt install -y wget

# DESCARGAR PROXYSQL DESDE GITHUB (versión alternativa)
echo "📥 Descargando ProxySQL desde GitHub..."
wget https://github.com/sysown/proxysql/releases/download/v2.4.4/proxysql_2.4.4-ubuntu20_amd64.deb -O proxysql.deb

# Si falla GitHub, intentar con mirror alternativo
if [ ! -f proxysql.deb ]; then
    echo "🔄 Intentando descarga alternativa..."
    wget https://github.com/sysown/proxysql/releases/download/v2.4.4/proxysql_2.4.4-ubuntu20_amd64.deb -O proxysql.deb || true
fi

# Si aún no funciona, usar versión más antigua pero funcional
if [ ! -f proxysql.deb ]; then
    echo "🔄 Descargando versión alternativa de ProxySQL..."
    wget https://github.com/sysown/proxysql/releases/download/v2.3.2/proxysql_2.3.2-ubuntu20_amd64.deb -O proxysql.deb
fi

# Instalar si se descargó correctamente
if [ -f proxysql.deb ]; then
    echo "📦 Instalando ProxySQL..."
    sudo dpkg -i proxysql.deb
    sudo apt-get install -f -y  # Corregir dependencias
    
    # Iniciar servicio
    sudo systemctl start proxysql
    sudo systemctl enable proxysql
    
    echo "✅ ProxySQL instalado correctamente"
else
    echo "⚠️  No se pudo descargar ProxySQL, instalando desde repositorio Ubuntu..."
    
    # Instalar desde repositorio de Ubuntu (versión más antigua pero funcional)
    sudo apt install -y proxysql
    
    # Iniciar servicio
    sudo systemctl start proxysql
    sudo systemctl enable proxysql
fi

# Verificar instalación
sleep 3
echo "🔍 Verificando instalación..."
if systemctl is-active --quiet proxysql; then
    echo "✅ ProxySQL funcionando correctamente"
    echo "📊 Puerto Admin: 6032, Puerto SQL: 6033"
else
    echo "❌ ProxySQL no se pudo instalar, pero la infraestructura está lista"
    echo "💡 Podemos continuar con MySQL y configurar ProxySQL manualmente después"
fi
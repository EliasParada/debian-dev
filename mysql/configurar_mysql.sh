#!/bin/bash

# Script: configurar_mysql.sh
# Descripción: Instala y configura MySQL/MariaDB

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0"
    echo
    echo "Este script no requiere opciones adicionales."
    echo
}

# Instalar MariaDB
echo "Instalando MariaDB..."
apt-get install -y mariadb-server mariadb-client

# Configurar MariaDB
echo "Ejecutando configuración segura de MariaDB..."
mysql_secure_installation

# Verificar instalación
echo "Verificando instalación..."
mysql -e "show databases;"
if [ $? -eq 0 ]; then
    echo "MySQL/MariaDB instalado y configurado correctamente."
else
    echo "Error en la instalación de MySQL/MariaDB."
fi

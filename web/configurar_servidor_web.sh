#!/bin/bash

# Script: configurar_servidor_web.sh
# Descripción: Instala y configura el servidor web Apache con PHP y MySQL

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0"
    echo "  -h, --help  - Muestra esta ayuda"
}

# Instalar Apache
echo "Instalando Apache..."
apt-get install -y apache2 apache2-doc

# Instalar PHP
echo "Instalando PHP..."
apt-get install -y php libapache2-mod-php
php -v
sudo service apache2 restart

# Instalar MySQL para PHP
echo "Instalando MySQL para PHP..."
apt-get install -y php-mysql
sudo service apache2 restart

# Crear archivo de información PHP
echo "Creando archivo de información PHP..."
cd /var/www/html/
echo "<?php phpinfo(); ?>" > info.php

echo "Instalación y configuración del servidor web completada."
echo "Para verificar, abra en el navegador la IP del servidor seguido de /info.php"

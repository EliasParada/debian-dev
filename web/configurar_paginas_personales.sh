#!/bin/bash

# Script: configurar_paginas_personales.sh
# Descripción: Configura páginas personales en Apache

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0"
    echo "  -h, --help  - Muestra esta ayuda"
}

# Habilitar módulos de usuario en Apache
echo "Habilitando módulos de usuario en Apache..."
sudo a2enmod userdir
systemctl restart apache2

# Configurar php.7.4.conf
echo "Configurando php.7.4.conf..."
sudo sed -i '/<IfModule mod_userdir.c>/,/<\/IfModule>/ s/#php_admin_flag engine Off/#&/' /etc/apache2/mods-available/php7.4.conf

# Reiniciar Apache
echo "Reiniciando Apache..."
sudo service apache2 restart

# Crear directorio public_html
echo "Creando directorio public_html..."
# ERROR: debe de crear la carpeta en /home/[USUARIO]/
mkdir -p ~/public_html
cd ~/public_html
echo "<html><body><h1>Página Personal</h1></body></html>" > index.html

echo "Configuración de páginas personales completada."
echo "Para verificar, abra en el navegador la IP del servidor seguido de /~usuario/"

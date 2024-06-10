#!/bin/bash

# Script: configurar_paginas_personales.sh
# Descripción: Configura páginas personales en Apache

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --usuario USUARIO"
    echo
    echo "Opciones:"
    echo "  --usuario USUARIO  - Nombre de usuario para la página personal"
    echo "  -h, --help         - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --usuario)
            USUARIO="$2"
            shift
            ;;
        -h|--help)
            mostrar_ayuda
            exit 0
            ;;
        *)
            echo "Opción desconocida: $1"
            mostrar_ayuda
            exit 1
            ;;
    esac
    shift
done

if [[ -z "$USUARIO" ]]; then
    echo "El parámetro --usuario es obligatorio."
    mostrar_ayuda
    exit 1
fi

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
mkdir -p "/home/$USUARIO/public_html"
cd "/home/$USUARIO/public_html"
echo "<html><body><h1>Página Personal</h1></body></html>" > index.html

echo "Configuración de páginas personales completada."
echo "Para verificar, abra en el navegador la IP del servidor seguido de /~usuario/"

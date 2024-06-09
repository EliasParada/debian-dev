#!/bin/bash

# Script: configurar_ntp.sh
# Descripción: Configura NTP para sincronizar el reloj con internet y desplegar un servidor NTP

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0"
    echo "  -h, --help  - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
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

# Mostrar la zona horaria actual
echo "Mostrando la zona horaria actual..."
cat /etc/timezone

# Reconfigurar la zona horaria
echo "Reconfigurando la zona horaria..."
sudo dpkg-reconfigure tzdata

# Mostrar la fecha actual
echo "Mostrando la fecha actual..."
date

# Ajustar la fecha manualmente
echo "Ajustando la fecha manualmente..."
date 09232140

# Instalar paquetes necesarios para NTP
echo "Instalando paquetes necesarios para NTP..."
apt-get update
apt-get install -y ntpdate ntp-doc

# Sincronizar con pool.ntp.org
echo "Sincronizando con pool.ntp.org..."
sudo ntpdate -u pool.ntp.org

# Desplegar un servidor NTP
echo "Instalando y configurando el servidor NTP..."
apt-get install -y ntp ntp-doc

# Comprobar los servidores NTP
echo "Comprobando los servidores NTP..."
ntpq -p

echo "Configuración de NTP completada."

#!/bin/bash

# Script: configurar_antivirus.sh
# Descripción: Instala y configura el antivirus ClamAV

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0"
    echo
    echo "Este script no requiere opciones adicionales."
    echo
}

# Instalar ClamAV y utilidades
echo "Instalando ClamAV..."
apt-get install -y clamav clamav-docs clamav-daemon clamav-freshclam
apt-get install -y arc arj bzip2 cabextract lzop nomarch p7zip pax tnef unrar-free unzip

# Verificar configuración de freshclam
echo "Verificando configuración de freshclam..."
cat /etc/clamav/freshclam.conf

# Actualizar ClamAV
echo "Actualizando ClamAV..."
freshclam

# Mensaje sobre posibles errores de procesos
echo "Si hay errores, puede que haya dos procesos de freshclam en ejecución."
echo "Para solucionar esto, usa los siguientes comandos para matar el proceso:"
echo "ps aux | grep freshclam"
echo "kill <PID>"

# Instalar archivos de prueba
echo "Instalando archivos de prueba para ClamAV..."
apt-get install -y clamav-testfiles
echo "Escaneando archivos de prueba..."
clamscan /usr/share/clamav-testfiles/
clamdscan /usr/share/clamav-testfiles/
echo "Eliminando archivos de prueba..."
apt-get remove -y clamav-testfiles

echo "Instalación y configuración de ClamAV completada."

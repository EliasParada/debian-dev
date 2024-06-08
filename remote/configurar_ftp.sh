#!/bin/bash

# Script: configurar_ftp.sh
# Descripción: Configura el servidor FTP

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

# Instalar vsftpd
echo "Instalando vsftpd..."
apt-get update
apt-get install -y vsftpd

# Configurar /etc/vsftpd.conf
echo "Configurando /etc/vsftpd.conf..."
VSFTPD_CONFIG="/etc/vsftpd.conf"

sed -i "s/#\?listen=.*/listen=YES/" $VSFTPD_CONFIG
sed -i "s/#\?anonymous_enable=.*/anonymous_enable=NO/" $VSFTPD_CONFIG
sed -i "s/#\?local_enable=.*/local_enable=YES/" $VSFTPD_CONFIG
sed -i "s/#\?chroot_local_user=.*/chroot_local_user=YES/" $VSFTPD_CONFIG

# Reiniciar el servicio FTP
echo "Reiniciando el servicio FTP..."
systemctl restart vsftpd

echo "Configuración de FTP completada."

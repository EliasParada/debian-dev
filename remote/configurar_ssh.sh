#!/bin/bash

# Script: configurar_ssh.sh
# Descripción: Configura el servidor SSH

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --ip IP"
    echo
    echo "Opciones:"
    echo "  --ip IP  - Dirección IP para ListenAddress"
    echo "  -h, --help  - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ip)
            IP="$2"
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

if [[ -z "$IP" ]]; then
    echo "El parámetro --ip es obligatorio."
    mostrar_ayuda
    exit 1
fi

# Instalar OpenSSH
echo "Instalando OpenSSH..."
apt-get update
apt-get install -y openssh-server openssh-client

# Configurar /etc/ssh/sshd_config
echo "Configurando /etc/ssh/sshd_config..."
SSHD_CONFIG="/etc/ssh/sshd_config"

sed -i "s/#\?ListenAddress .*/ListenAddress $IP/" $SSHD_CONFIG
sed -i "s/#\?PermitRootLogin .*/PermitRootLogin no/" $SSHD_CONFIG
sed -i "s/#\?PermitEmptyPasswords .*/PermitEmptyPasswords no/" $SSHD_CONFIG

# Reiniciar el servicio SSH
echo "Reiniciando el servicio SSH..."
systemctl restart sshd

echo "Configuración de SSH completada."

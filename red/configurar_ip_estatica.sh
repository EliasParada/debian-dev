#!/bin/bash

# Script: configurar_ip_estatica.sh
# Descripción: Configura una dirección IP estática en una interfaz de red

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --ip IP --iface IFACE --network RED --host HOST"
    echo
    echo "Opciones:"
    echo "  --ip IP              - Dirección IP estática"
    echo "  --iface IFACE        - Interfaz de red (ej. enp0s3)"
    echo "  --network RED        - Red (ej. 192.168.1)"
    echo "  --host HOST          - Nombre del host (ej. server.lan)"
    echo "  -h, --help           - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ip)
            IP="$2"
            shift
            ;;
        --iface)
            IFACE="$2"
            shift
            ;;
        --network)
            NETWORK="$2"
            shift
            ;;
        --host)
            HOST="$2"
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

if [[ -z "$IP" || -z "$IFACE" || -z "$NETWORK" || -z "$HOST" ]]; then
    echo "Todos los parámetros son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Configurar el archivo /etc/network/interfaces
echo "Configurando /etc/network/interfaces..."
INTERFACE_CONFIG="auto $IFACE
iface $IFACE inet static
allow-hotplug $IFACE
address $IP
gateway $IP
netmask 255.255.255.0
broadcast $NETWORK.255
network $NETWORK.0"

if grep -q "iface $IFACE inet static" /etc/network/interfaces; then
    # Reemplazar la configuración existente de la interfaz
    sed -i "/iface $IFACE inet static/,+6d" /etc/network/interfaces
fi

echo "$INTERFACE_CONFIG" >> /etc/network/interfaces

# Reiniciar el servicio de red
echo "Reiniciando el servicio de red..."
systemctl restart networking.service

# Configurar el archivo /etc/resolv.conf
echo "Configurando /etc/resolv.conf..."
RESOLV_CONF="domain $HOST
search $HOST
nameserver $NETWORK.1"

echo "$RESOLV_CONF" > /etc/resolv.conf

# Reiniciar el sistema
echo "Reiniciando el sistema..."
reboot

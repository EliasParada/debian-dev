#!/bin/bash

# Script: ip_virtual.sh
# Descripción: Configura una IP virtual en una interfaz de red

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --ip IP --iface IFACE --virtual-ip VIRTUAL_IP --host HOST"
    echo
    echo "Opciones:"
    echo "  --ip IP                     - Dirección IP estática principal"
    echo "  --iface IFACE               - Interfaz de red (ej. enp0s9)"
    echo "  --virtual-ip VIRTUAL_IP     - Dirección IP virtual (ej. 192.168.87.73)"
    echo "  --host HOST                 - Nombre del host para la IP virtual (ej. virtual.server.lan)"
    echo "  -h, --help                  - Muestra esta ayuda"
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
        --virtual-ip)
            VIRTUAL_IP="$2"
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

if [[ -z "$IP" || -z "$IFACE" || -z "$VIRTUAL_IP" || -z "$HOST" ]]; then
    echo "Todos los parámetros son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Configurar /etc/network/interfaces
echo "Configurando /etc/network/interfaces..."
INTERFACES_FILE="/etc/network/interfaces"

# Crear la configuración de la interfaz virtual
VIRTUAL_CONFIG=$(cat <<EOL
##
## Interfaz virtual
##
auto $IFACE
iface $IFACE inet static
    address $IP
    netmask 255.255.255.0

auto $IFACE:0
iface $IFACE:0 inet static
    address $VIRTUAL_IP
    netmask 255.255.255.0
##
EOL
)

# Actualizar el archivo de configuración de interfaces
if grep -q "## Interfaz virtual" "$INTERFACES_FILE"; then
    sed -i "/## Interfaz virtual/,/##/c\\$VIRTUAL_CONFIG" "$INTERFACES_FILE"
else
    echo "$VIRTUAL_CONFIG" >> "$INTERFACES_FILE"
fi

# Activar la interfaz principal
echo "Activando interfaz principal..."
sudo ifup $IFACE

# Reiniciar el servicio de red
echo "Reiniciando el servicio de red..."
systemctl restart networking.service

# Configurar /etc/hosts
echo "Configurando /etc/hosts..."
HOSTS_FILE="/etc/hosts"
HOSTS_ENTRY=$(cat <<EOL
## Interfaz virtual
$IP   $HOST virtual
##
EOL
)

if grep -q "## Interfaz virtual" "$HOSTS_FILE"; then
    sed -i "/## Interfaz virtual/,/##/c\\$HOSTS_ENTRY" "$HOSTS_FILE"
else
    echo "$HOSTS_ENTRY" >> "$HOSTS_FILE"
fi

# Reiniciar el servicio de red nuevamente
echo "Reiniciando el servicio de red..."
systemctl restart networking.service

# Mostrar la configuración de la interfaz
echo "Mostrando la configuración de la interfaz..."
ip addr show $IFACE

# Probar la conexión
echo "Probando la conexión..."
ping -c3 $HOST

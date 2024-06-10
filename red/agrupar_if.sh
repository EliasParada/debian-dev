#!/bin/bash

# Script: agrupar_if.sh
# Descripción: Configura la agrupación de interfaces de red (bonding)

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --ip IP --network RED --master IFACE_MAESTRA --slaves IFACES_ESCLAVAS --host HOST"
    echo
    echo "Opciones:"
    echo "  --ip IP                     - Dirección IP estática"
    echo "  --network RED               - Red (ej. 192.168.1)"
    echo "  --master IFACE_MAESTRA      - Interfaz maestra (ej. bond0)"
    echo "  --slaves IFACES_ESCLAVAS    - Interfaces esclavas separadas por espacios (ej. enp0s3 enp0s8)"
    echo "  --host HOST                 - Nombre del host (ej. server.lan)"
    echo "  -h, --help                  - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --ip)
            IP="$2"
            shift
            ;;
        --network)
            NETWORK="$2"
            shift
            ;;
        --master)
            MASTER="$2"
            shift
            ;;
        --slaves)
            SLAVES="$2"
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

if [[ -z "$IP" || -z "$NETWORK" || -z "$MASTER" || -z "$SLAVES" || -z "$HOST" ]]; then
    echo "Todos los parámetros son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Instalar paquetes necesarios
echo "Instalando ifenslave y kmod..."
apt-get update
apt-get install -y ifenslave kmod

# Configurar el PATH
export PATH=$PATH:/sbin:/usr/sbin

# Cargar el módulo de bonding
echo "Cargando el módulo de bonding..."
sudo modprobe bonding

# Verificar que el módulo bonding esté cargado
echo "Verificando que el módulo de bonding esté cargado..."
lsmod | grep bonding

# Configurar /etc/network/interfaces
echo "Configurando /etc/network/interfaces..."
INTERFACES_FILE="/etc/network/interfaces"

# Crear la configuración de la interfaz agrupada
BONDING_CONFIG=$(cat <<EOL
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback
##
## Configurar interfaz agrupada
##
auto $MASTER
iface $MASTER inet static
    address $IP
    gateway ${NETWORK}.1
    netmask 255.255.255.0
    broadcast ${NETWORK}.255
    network ${NETWORK}.0
    slaves $SLAVES
    bond-mode balance-rr
    bond-miimon 100
    bond-downdelay 200
    bond-updelay 200

EOL
)

# Configuración para cada interfaz esclava
for SLAVE in $SLAVES; do
    BONDING_CONFIG+=$(cat <<EOL

auto $SLAVE
iface $SLAVE inet manual
    bond-master $MASTER

EOL
    )
done

BONDING_CONFIG+="
##
"

# Actualizar el archivo de configuración de interfaces
# if grep -q "## Configurar interfaz agrupada" "$INTERFACES_FILE"; then
#     sed -i "/## Configurar interfaz agrupada/,/##/c\\$BONDING_CONFIG" "$INTERFACES_FILE"
# else
echo "$BONDING_CONFIG" >> "$INTERFACES_FILE"
# fi

# Configurar cada interfaz esclava
echo "Bajando interfaces esclavas..."
for SLAVE in $SLAVES; do
    ip link set $SLAVE down
done

# Reiniciar el módulo de bonding
echo "Reiniciando el módulo de bonding..."
sudo modprobe -r bonding
sudo modprobe bonding

# Reiniciar el servicio de red
echo "Reiniciando el servicio de red..."
systemctl restart networking.service

# Configurar el archivo /etc/resolv.conf
echo "Configurando /etc/resolv.conf..."
RESOLV_CONF="domain $HOST
search $HOST
nameserver ${NETWORK}.1"

echo "$RESOLV_CONF" > /etc/resolv.conf

# Comprobar que ambas interfaces sean esclavas
echo "Comprobando configuración de bonding..."
cat /proc/net/bonding/$MASTER

# Mostrar configuración de red
echo "Configuración de red:"
ip -4 a

# Probar conexión a Internet
echo "Probando conexión a Internet..."
ping -c 4 8.8.8.8

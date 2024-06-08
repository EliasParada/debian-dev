#!/bin/bash

# Script: agrupar_if.sh
# Descripción: Configura la agrupación de interfaces de red (bonding)

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --ip IP --network RED --master IFACE_MAESTRA --slaves IFACES_ESCLAVAS"
    echo
    echo "Opciones:"
    echo "  --ip IP                     - Dirección IP estática"
    echo "  --network RED               - Red (ej. 192.168.1)"
    echo "  --master IFACE_MAESTRA      - Interfaz maestra (ej. bond0)"
    echo "  --slaves IFACES_ESCLAVAS    - Interfaces esclavas separadas por espacios (ej. enp0s3 enp0s8)"
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

if [[ -z "$IP" || -z "$NETWORK" || -z "$MASTER" || -z "$SLAVES" ]]; then
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
modprobe bonding

# Verificar que el módulo bonding esté cargado
echo "Verificando que el módulo de bonding esté cargado..."
lsmod | grep bonding

# Configurar /etc/network/interfaces
echo "Configurando /etc/network/interfaces..."
INTERFACES_FILE="/etc/network/interfaces"

# Comentar cualquier configuración previa de las interfaces esclavas y maestra
for IFACE in $SLAVES $MASTER; do
    sed -i "s/^iface $IFACE inet static/#&/" $INTERFACES_FILE
    sed -i "s/^auto $IFACE/#&/" $INTERFACES_FILE
done

# Configuración para la interfaz maestra
cat <<EOL >> $INTERFACES_FILE

auto $MASTER
iface $MASTER inet static
    address $IP
    gateway ${NETWORK}.1
    netmask 255.255.255.0
    broadcast ${NETWORK}.255
    network ${NETWORK}.0
    bond-mode balance-rr
    bond-miimon 100
    bond-downdelay 200
    bond-updelay 200
EOL

# Configuración para cada interfaz esclava
for SLAVE in $SLAVES; do
    cat <<EOL >> $INTERFACES_FILE

auto $SLAVE
iface $SLAVE inet manual
    bond-master $MASTER
EOL
done

# Configurar cada interfaz esclava
echo "Bajando interfaces esclavas..."
for SLAVE in $SLAVES; do
    ip link set $SLAVE down
done

# Reiniciar el módulo de bonding
echo "Reiniciando el módulo de bonding..."
modprobe -r bonding
modprobe bonding

# Reiniciar el servicio de red
echo "Reiniciando el servicio de red..."
systemctl restart networking.service

# Comprobar que ambas interfaces sean esclavas
echo "Comprobando configuración de bonding..."
cat /proc/net/bonding/$MASTER

# Mostrar configuración de red
echo "Configuración de red:"
ip -4 a

# Probar conexión a internet
echo "Probando conexión a Internet..."
ping -c 4 8.8.8.8

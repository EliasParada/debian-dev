#!/bin/bash

# Script: debian.sh
# Descripción: Script maestro para ejecutar scripts de configuración con parámetros

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 <comando> [opciones]"
    echo
    echo "Comandos disponibles:"
    echo "  ip-estatica         - Configura una dirección IP estática"
    echo "  agrupar-if          - Configura la agrupación de interfaces de red"
    echo "  ip-virtual          - Configura una IP virtual en una interfaz de red"
    echo "  ssh                 - Configura el servidor SSH"
    echo "  ftp                 - Configura el servidor FTP"
    echo "  ntp                 - Configura NTP"
    echo "  dns                 - Configura DNS"
    echo
    echo "Opciones para ip-estatica:"
    echo "  --ip IP              - Dirección IP estática"
    echo "  --iface IFACE        - Interfaz de red (ej. enp0s3)"
    echo "  --network RED        - Red (ej. 192.168.1)"
    echo "  --host HOST          - Nombre del host (ej. server.lan)"
    echo
    echo "Opciones para agrupar-if:"
    echo "  --ip IP              - Dirección IP estática"
    echo "  --network RED        - Red (ej. 192.168.1)"
    echo "  --master IFACE       - Interfaz maestra (ej. bond0)"
    echo "  --slaves IFACES      - Interfaces esclavas separadas por espacios (ej. enp0s3 enp0s8)"
    echo "  --host HOST          - Nombre del host (ej. server.lan)"
    echo
    echo "Opciones para ip-virtual:"
    echo "  --ip IP              - Dirección IP estática principal (ej. 192.168.1.70)"
    echo "  --iface IFACE        - Interfaz de red (ej. enp0s9)"
    echo "  --virtual-ip IP      - Dirección IP virtual (ej. 192.168.1.71)"
    echo "  --host HOST          - Nombre del host (ej. virtual.server.lan)"
    echo
    echo "Opciones para ssh:"
    echo "  --ip IP              - Dirección IP para ListenAddress"
    echo
    echo "Opciones para ftp:"
    echo "  -h, --help           - Muestra esta ayuda"
    echo
    echo "Opciones para ntp:"
    echo "  -h, --help           - Muestra esta ayuda"
    echo
     echo "Opciones para dns:"
    echo "  --router IP_ROUTER   - Dirección IP del router (ej. 192.168.1.1)"
    echo "  --host HOST          - Nombre del host (ej. server.lan)"
    echo
    echo "Opciones para servidor-dns:"
    echo "  --direct DIRECT        - Dominio directo (ej. server.lan)"
    echo "  --reverse REVERSE      - Dominio inverso (ej. 2.168.192)"
    echo "  --ip IP                - Dirección IP del servidor (ej. 192.168.2.14)"
    echo "  --server-full SERVER_FULL - Nombre completo del servidor (ej. debian.server.lan)"
    echo "  --virtual-ip VIRTUAL_IP   - Dirección IP virtual (ej. 192.168.2.15)"
    echo "  --router ROUTER        - Dirección IP del router (ej. 192.168.2.1)"
}

# Manejo de parámetros
COMANDO=$1
shift

case "$COMANDO" in
    ip-estatica)
        ./red/configurar_ip_estatica.sh "$@"
        ;;
    agrupar-if)
        ./red/agrupar_if.sh "$@"
        ;;
    ip-virtual)
        ./red/ip_virtual.sh "$@"
        ;;
    ssh)
        ./remote/configurar_ssh.sh "$@"
        ;;
    ftp)
        ./remote/configurar_ftp.sh "$@"
        ;;
    ntp)
        ./reloj/configurar_ntp.sh "$@"
        ;;
    dns)
        ./dns/configurar_dns.sh "$@"
        ;;
    servidor-dns)
        ./dns/configurar_servidor_dns.sh "$@"
        ;;
    *)
        echo "Comando no reconocido: $COMANDO"
        mostrar_ayuda
        exit 1
        ;;
esac

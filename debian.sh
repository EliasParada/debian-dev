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
    echo "  proxy                 - Configura PROXY"
    echo "  mysql               - Configura MySQL/MariaDB"
    echo "  antivirus           - Instala y configura el antivirus ClamAV"
    echo "  antispam            - Instala y configura el antispam SpamAssassin"
    echo "  subversion          - Instala y configura Subversion"
    echo "  servidor-web        - Instala y configura el servidor web Apache con PHP y MySQL"
    echo "  paginas-personales  - Configura páginas personales en Apache"
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
    echo
    echo "Opciones para dns-dinamico:"
    echo "  --host HOST           - Nombre del host (ej. myserver.dyndns.org)"
    echo
    echo "Opciones para dhcp:"
    echo "  --iface IFACE         - Interfaz de red (ej. enp0s3)"
    echo "  --host HOST           - Nombre del dominio (ej. server.lan)"
    echo "  --ip IP               - Dirección IP del servidor DNS"
    echo "  --router ROUTER       - Dirección IP del router"
    echo "  --network NETWORK     - Red (ej. 192.168.1.0)"
    echo "  --broadcast BROADCAST - Dirección de broadcast (ej. 192.168.1.255)"
    echo "  --from FROM           - Rango de direcciones IP desde (ej. 192.168.1.100)"
    echo "  --to TO               - Rango de direcciones IP hasta (ej. 192.168.1.200)"
    echo "  --pc-mac PC_MAC       - (Opcional) Dirección MAC de la PC"
    echo "  --pc-ip PC_IP         - (Opcional) Dirección IP fija para la PC"
    echo "  --laptop-mac LAPTOP_MAC       - (Opcional) Dirección MAC de la Laptop"
    echo "  --laptop-ip LAPTOP_IP         - (Opcional) Dirección IP fija para la Laptop"
    echo
    echo "Opciones para proxy:"
    echo "  --host HOST           - Nombre del dominio (ej. server.lan)"
    echo "  --network NETWORK     - Red (ej. 192.168.1.0/24)"
    echo
    echo "Opciones para mysql:"
    echo "  -h, --help            - Muestra esta ayuda"
    echo
    echo "Opciones para antivirus:"
    echo "  -h, --help            - Muestra esta ayuda"
    echo
    echo "Opciones para antispam:"
    echo "  -h, --help            - Muestra esta ayuda"
    echo
    echo "Opciones para subversion:"
    echo "  -h, --help            - Muestra esta ayuda"
    echo
    echo "Opciones para servidor-web:"
    echo "  -h, --help            - Muestra esta ayuda"
    echo
    echo "Opciones para paginas-personales:"
    echo "  -h, --help            - Muestra esta ayuda"
    echo
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
    dns-dinamico)
        ./dns/configurar_dns_dinamico.sh "$@"
        ;;
    dhcp)
        ./dhcp/configurar_dhcp.sh "$@"
        ;;
    proxy)
        ./proxy/configurar_proxy.sh "$@"
        ;;
    mysql)
        ./mysql/configurar_mysql.sh "$@"
        ;;
    antivirus)
        ./seguridad/configurar_antivirus.sh "$@"
        ;;
    antispam)
        ./seguridad/configurar_antispam.sh "$@"
        ;;
    subversion)
        ./vcs/configurar_subversion.sh "$@"
        ;;
    servidor-web)
        ./web/configurar_servidor_web.sh "$@"
        ;;
    paginas-personales)
        ./web/configurar_paginas_personales.sh "$@"
        ;;
    *)
        echo "Comando no reconocido: $COMANDO"
        mostrar_ayuda
        exit 1
        ;;
esac

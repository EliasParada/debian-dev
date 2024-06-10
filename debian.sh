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
    echo "  dns-dinamico        - Configura DNS dinámico"
    echo "  proxy               - Configura PROXY"
    echo "  mysql               - Configura MySQL/MariaDB"
    echo "  antivirus           - Instala y configura el antivirus ClamAV"
    echo "  antispam            - Instala y configura el antispam SpamAssassin"
    echo "  subversion          - Instala y configura Subversion"
    echo "  servidor-web        - Instala y configura el servidor web Apache con PHP y MySQL"
    echo "  paginas-personales  - Configura páginas personales en Apache"
    echo "  servidor-email      - Configura el servidor de correo electrónico"
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
    servidor-email )
        ./email/configurar_servidor_email.sh "$@"
        ;;
    * )
        echo "Comando no reconocido: $COMANDO"
        mostrar_ayuda
        exit 1
        ;;
esac

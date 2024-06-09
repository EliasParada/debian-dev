#!/bin/bash

# Script: configurar_dns.sh
# Descripción: Configura el servidor DNS

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --router IP_ROUTER --host HOST"
    echo
    echo "Opciones:"
    echo "  --router IP_ROUTER  - Dirección IP del router"
    echo "  --host HOST         - Nombre del host (ej. server.lan)"
    echo "  -h, --help          - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --router)
            ROUTER="$2"
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

if [[ -z "$ROUTER" || -z "$HOST" ]]; then
    echo "Todos los parámetros son obligatorios."
    mostrar_ayuda
    exit 1
fi

# Instalar Bind9
echo "Instalando Bind9..."
apt-get update
apt-get install -y bind9 bind9-doc dnsutils

# Configurar /etc/bind/named.conf.options
echo "Configurando /etc/bind/named.conf.options..."
NAMED_OPTIONS="/etc/bind/named.conf.options"

cat <<EOL > $NAMED_OPTIONS
options {
    directory "/var/cache/bind";

    forwarders {
        // Google DNS IPv4
        8.8.8.8;
        8.8.4.4;
        // Google DNS IPv6
        2001:4860:4860::8888;
        2001:4860:4860::8844;
        // OpenDNS
        208.67.222.222;
        208.67.220.220;
        // Router
        $ROUTER;
    };

    dnssec-validation auto;

    auth-nxdomain no;

    // listen-on-v6 { any; };
};
EOL

# Verificar configuración de Bind9
echo "Verificando configuración de Bind9..."
sudo named-checkconf

# Configurar /etc/resolv.conf
echo "Configurando /etc/resolv.conf..."
RESOLV_CONF="/etc/resolv.conf"

cat <<EOL > $RESOLV_CONF
domain $HOST
search $HOST
nameserver 127.0.0.1
nameserver ::1
EOL

# Configurar /etc/nsswitch.conf
echo "Configurando /etc/nsswitch.conf..."
NSSWITCH_CONF="/etc/nsswitch.conf"

sed -i "s/^hosts:.*/hosts: files dns/" $NSSWITCH_CONF

# Reiniciar Bind9
echo "Reiniciando Bind9..."
systemctl restart bind9

# Probar configuración DNS
echo "Probando configuración DNS..."
nslookup www.debian.org

echo "Configuración de DNS completada."

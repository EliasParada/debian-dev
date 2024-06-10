#!/bin/bash

# Script: configurar_proxy.sh
# Descripción: Configura el servidor Proxy

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --host HOST --network NETWORK"
    echo
    echo "Opciones:"
    echo "  --host HOST       - Nombre del dominio (ej. server.lan)"
    echo "  --network NETWORK - Red (ej. 192.168.1.0/24)"
    echo "  -h, --help        - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --host)
            HOST="$2"
            shift
            ;;
        --network)
            NETWORK="$2"
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

if [[ -z "$HOST" || -z "$NETWORK" ]]; then
    echo "Los parámetros obligatorios faltan."
    mostrar_ayuda
    exit 1
fi

# Instalar squid
echo "Instalando squid..."
apt-get install -y squid

# Configurar /etc/squid/squid.conf
echo "Configurando /etc/squid/squid.conf..."

replace_or_add_line() {
    local file=$1
    local key=$2
    local value=$3
    local pattern="^$key"
    local insert_line_after="$4"  # Nueva variable para la línea después de la cual insertar

    if grep -q "$pattern" "$file"; then
        sed -i "/$insert_line_after/a $key $value" "$file"  # Insertar línea después de la línea especificada
    else
        echo "$key $value" >> "$file"
    fi
}

# Reemplazar o agregar líneas en /etc/squid/squid.conf
# Agregar el ACL despues de esta linea "acl CONNECT method CONNECT"
replace_or_add_line "/etc/squid/squid.conf" "acl $HOST src" "$NETWORK" "acl CONNECT method CONNECT"
replace_or_add_line "/etc/squid/squid.conf" "http_access allow" "$HOST"
replace_or_add_line "/etc/squid/squid.conf" "cache_dir ufs /var/spool/squid" "2048 16 256"
replace_or_add_line "/etc/squid/squid.conf" "visible_hostname" "proxy.$HOST"

# Reiniciar squid
echo "Reiniciando squid..."
systemctl restart squid

echo "Configuración del servidor Proxy completada."

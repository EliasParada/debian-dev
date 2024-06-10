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
    
    if grep -q "$pattern" "$file"; then
        sed -i "s|$pattern.*|$key $value|" "$file"
    else
        echo "$key $value" >> "$file"
    fi
}

replace_or_add_line() {
    local file=$1
    local key=$2
    local value=$3
    local pattern="^$key"
    
    if grep -q "$pattern" "$file"; then
        sed -i "s|$pattern.*|$key $value|" "$file"
    else
        echo "$key $value" >> "$file"
    fi
}

# Reemplazar o agregar líneas en /etc/squid/squid.conf
# Obtener el número de línea donde se debe insertar la nueva línea
line_number=$(awk '/acl CONNECT method CONNECT/{ print NR+1; exit }' /etc/squid/squid.conf)
# Insertar la nueva línea en el archivo
sed -i "${line_number}i acl $HOST src $NETWORK" /etc/squid/squid.conf
sed -i 's/cache_dir ufs /var\/cache_dir ufs /var/spool/squid 2048 16 256' /etc/squid/squid.conf
replace_or_add_line "/etc/squid/squid.conf" "visible_hostname" "proxy.$HOST"

# Reiniciar squid
echo "Reiniciando squid..."
systemctl restart squid

echo "Configuración del servidor Proxy completada."

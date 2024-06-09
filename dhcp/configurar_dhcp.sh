#!/bin/bash

# Script: configurar_dhcp.sh
# Descripción: Configura el servidor DHCP

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 --iface IFACE --host HOST --ip IP --router ROUTER --network NETWORK --broadcast BROADCAST --from FROM --to TO [--pc-mac PC_MAC --pc-ip PC_IP]"
    echo
    echo "Opciones:"
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
    echo "  -h, --help            - Muestra esta ayuda"
}

# Manejo de parámetros
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --iface)
            IFACE="$2"
            shift
            ;;
        --host)
            HOST="$2"
            shift
            ;;
        --ip)
            IP="$2"
            shift
            ;;
        --router)
            ROUTER="$2"
            shift
            ;;
        --network)
            NETWORK="$2"
            shift
            ;;
        --broadcast)
            BROADCAST="$2"
            shift
            ;;
        --from)
            FROM="$2"
            shift
            ;;
        --to)
            TO="$2"
            shift
            ;;
        --pc-mac)
            PC_MAC="$2"
            shift
            ;;
        --pc-ip)
            PC_IP="$2"
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

if [[ -z "$IFACE" || -z "$HOST" || -z "$IP" || -z "$ROUTER" || -z "$NETWORK" || -z "$BROADCAST" || -z "$FROM" || -z "$TO" ]]; then
    echo "Los parámetros obligatorios faltan."
    mostrar_ayuda
    exit 1
fi

# Instalar isc-dhcp-server
echo "Instalando isc-dhcp-server..."
apt-get install -y isc-dhcp-server

# Configurar /etc/default/isc-dhcp-server
echo "Configurando /etc/default/isc-dhcp-server..."
sed -i "s/INTERFACESv4=.*/INTERFACESv4=\"$IFACE\"/" /etc/default/isc-dhcp-server

# Configurar /etc/dhcp/dhcpd.conf
echo "Configurando /etc/dhcp/dhcpd.conf..."

replace_or_add_line() {
    local file=$1
    local key=$2
    local value=$3
    local pattern="^$key"
    
    if grep -q "$pattern" "$file"; then
        sed -i "s|$pattern.*|$key $value;|" "$file"
    else
        echo "$key $value;" >> "$file"
    fi
}

# Reemplazar o agregar líneas en /etc/dhcp/dhcpd.conf
replace_or_add_line "/etc/dhcp/dhcpd.conf" "option domain-name" "\"$HOST\""
replace_or_add_line "/etc/dhcp/dhcpd.conf" "option domain-name-servers" "$IP, $ROUTER"
replace_or_add_line "/etc/dhcp/dhcpd.conf" "default-lease-time" "600"
replace_or_add_line "/etc/dhcp/dhcpd.conf" "max-lease-time" "7200"
replace_or_add_line "/etc/dhcp/dhcpd.conf" "ddns-update-style" "none"

# Manejar bloques de configuración
manage_block() {
    local file=$1
    local start_marker=$2
    local end_marker=$3
    local content=$4
    
    if grep -q "$start_marker" "$file"; then
        sed -i "/$start_marker/,/$end_marker/{/$start_marker/{p; r /dev/stdin
}; d}" "$file" <<<"$content"
    else
        echo -e "\n$start_marker\n$content\n$end_marker" >> "$file"
    fi
}

# Configurar bloque DHCP
dhcp_block=$(cat <<EOL
subnet $NETWORK netmask 255.255.255.0 {
    option domain-name "$HOST";
    option domain-name-servers $IP, $ROUTER;
    option routers $ROUTER;
    option broadcast-address $BROADCAST;
    default-lease-time 600;
    max-lease-time 7200;
    range $FROM $TO;
}
EOL
)

manage_block "/etc/dhcp/dhcpd.conf" "## Configurar DHCP" "## Fin" "$dhcp_block"

# Configurar bloque Desktop
if [[ ! -z "$PC_MAC" && ! -z "$PC_IP" ]]; then
    desktop_block=$(cat <<EOL
host desktop {
    hardware ethernet $PC_MAC;
    fixed-address $PC_IP;
}
EOL
    )
    manage_block "/etc/dhcp/dhcpd.conf" "## Configurar Desktop" "## Fin" "$desktop_block"
fi

# Reiniciar isc-dhcp-server
echo "Reiniciando isc-dhcp-server..."
systemctl restart isc-dhcp-server

echo "Configuración del servidor DHCP completada."

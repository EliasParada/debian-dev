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
    echo
    echo "  -h, --help           - Muestra esta ayuda"
}

# Manejo de parámetros
COMANDO=$1
shift

case "$COMANDO" in
    ip-estatica)
        ./configuración/red/configurar_ip_estatica.sh "$@"
        ;;
    agrupar-if)
        ./configuración/red/agrupar_if.sh "$@"
        ;;
    *)
        echo "Comando no reconocido: $COMANDO"
        mostrar_ayuda
        exit 1
        ;;
esac

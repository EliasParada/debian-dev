#!/bin/bash

# Script: servidores-script.sh
# Descripción: Script maestro para ejecutar scripts de configuración con parámetros

# Mostrar ayuda
mostrar_ayuda() {
    echo "Uso: $0 <comando> [opciones]"
    echo
    echo "Comandos disponibles:"
    echo "  ip-estatica         - Configura una dirección IP estática"
    echo
    echo "Opciones para ip-estatica:"
    echo "  --ip IP              - Dirección IP estática"
    echo "  --iface IFACE        - Interfaz de red (ej. enp0s3)"
    echo "  --network RED        - Red (ej. 192.168.1)"
    echo "  --host HOST          - Nombre del host (ej. server.lan)"
    echo "  -h, --help           - Muestra esta ayuda"
}

# Manejo de parámetros
COMANDO=$1
shift

case "$COMANDO" in
    ip-estatica)
        ./red/configurar_ip_estatica.sh "$@"
        ;;
    *)
        echo "Comando no reconocido: $COMANDO"
        mostrar_ayuda
        exit 1
        ;;
esac

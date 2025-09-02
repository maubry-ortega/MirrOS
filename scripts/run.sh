#!/bin/bash
# MirrOS - Script de ejecución en QEMU para Linux/macOS

set -e

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuración
QEMU=${QEMU:-qemu-system-x86_64}
KERNEL="zig-out/bin/zorro-kernel"
MEMORY="512M"

# Funciones de ayuda
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar dependencias
check_dependencies() {
    if ! command -v $QEMU &> /dev/null; then
        log_error "QEMU no está instalado."
        echo "Para instalar:"
        echo "  Ubuntu/Debian: sudo apt-get install qemu-system-x86"
        echo "  CentOS/RHEL:   sudo yum install qemu-system-x86"
        echo "  macOS:         brew install qemu"
        exit 1
    fi
    
    if [[ ! -f "$KERNEL" ]]; then
        log_error "Kernel no encontrado: $KERNEL"
        log_info "Ejecuta 'make build' o './scripts/build.sh' primero"
        exit 1
    fi
}

# Configuración de QEMU según el sistema
setup_qemu() {
    case "$(uname -s)" in
        Darwin)
            # macOS - usar aceleración HVF si está disponible
            if sysctl -n kern.hv_support 2>/dev/null | grep -q "1"; then
                QEMU_FLAGS="-accel hvf"
            else
                QEMU_FLAGS=""
            fi
            ;;
        Linux)
            # Linux - usar KVM si está disponible
            if [[ -r /dev/kvm ]]; then
                QEMU_FLAGS="-enable-kvm"
            else
                QEMU_FLAGS=""
            fi
            ;;
        *)
            QEMU_FLAGS=""
            ;;
    esac
}

# Ejecutar QEMU
run_qemu() {
    local debug_mode=false
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--debug)
                debug_mode=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Opción no reconocida: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    check_dependencies
    setup_qemu
    
    local base_flags="-kernel $KERNEL -m $MEMORY -serial stdio"
    
    if [[ "$debug_mode" == true ]]; then
        log_info "🐛 Modo debug activado"
        log_info "📍 Esperando conexión GDB en localhost:1234"
        log_info "💡 En otra terminal ejecuta: gdb -ex 'target remote localhost:1234'"
        
        exec $QEMU $QEMU_FLAGS $base_flags -s -S
    else
        log_info "🚀 Ejecutando MirrOS en QEMU..."
        log_info "Presiona Ctrl+C para salir"
        
        exec $QEMU $QEMU_FLAGS $base_flags
    fi
}

show_help() {
    echo "Uso: $0 [opciones]"
    echo ""
    echo "Opciones:"
    echo "  -d, --debug  - Ejecutar en modo debug con GDB"
    echo "  -h, --help   - Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  $0              # Ejecutar normal"
    echo "  $0 --debug      # Ejecutar en modo debug"
}

# Ejecutar
run_qemu "$@"
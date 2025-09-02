# MirrOS - Makefile para Linux/macOS
# Variables de configuración
ZIG := zig
QEMU := qemu-system-x86_64
BUILD_DIR := zig-out
KERNEL := $(BUILD_DIR)/bin/zorro-kernel
ISO_DIR := iso
ISO_FILE := $(BUILD_DIR)/mirr-os.iso

# Detectar sistema operativo
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
    OS := linux
endif
ifeq ($(UNAME_S),Darwin)
    OS := macos
endif

# Configuración de QEMU
QEMU_FLAGS := -kernel $(KERNEL) -m 512M -serial stdio
QEMU_DEBUG_FLAGS := $(QEMU_FLAGS) -s -S

# Comandos de construcción
.PHONY: all build clean run run-debug test install-deps help

all: build

build:
	@echo "🔨 Construyendo MirrOS..."
	$(ZIG) build
	@echo "✅ Construcción completada"

clean:
	@echo "🧹 Limpiando artefactos..."
	$(ZIG) build --clean
	@echo "✅ Limpieza completada"

run: build
	@echo "🚀 Ejecutando MirrOS en QEMU..."
	$(QEMU) $(QEMU_FLAGS)

run-debug: build
	@echo "🐛 Ejecutando en modo debug..."
	@echo "📍 Esperando conexión GDB en localhost:1234"
	$(QEMU) $(QEMU_DEBUG_FLAGS)

test:
	@echo "🧪 Ejecutando tests..."
	$(ZIG) build test
	@echo "✅ Tests completados"

# Crear ISO bootable
iso: build
	@echo "💿 Creando ISO bootable..."
	mkdir -p $(ISO_DIR)/boot/grub
	cp $(KERNEL) $(ISO_DIR)/boot/
	cp boot/grub.cfg $(ISO_DIR)/boot/grub/
	grub-mkrescue -o $(ISO_FILE) $(ISO_DIR)
	@echo "✅ ISO creada: $(ISO_FILE)"

run-iso: iso
	@echo "🚀 Ejecutando desde ISO..."
	$(QEMU) -cdrom $(ISO_FILE) -m 512M -serial stdio

# Instalación de dependencias
install-deps:
	@echo "📦 Instalando dependencias para $(OS)..."
ifeq ($(OS),linux)
	sudo apt-get update
	sudo apt-get install -y qemu-system-x86 qemu-system-x86_64 grub-common xorriso
else ifeq ($(OS),macos)
	brew install qemu xorriso
endif
	@echo "✅ Dependencias instaladas"

# Verificación de herramientas
check-deps:
	@echo "🔍 Verificando dependencias..."
	@which $(ZIG) >/dev/null 2>&1 || (echo "❌ Zig no encontrado. Instala ziglang.org" && exit 1)
	@which $(QEMU) >/dev/null 2>&1 || (echo "❌ QEMU no encontrado. Ejecuta: make install-deps" && exit 1)
	@echo "✅ Todas las dependencias están instaladas"

help:
	@echo "MirrOS - Comandos disponibles:"
	@echo "  make build      - Construir el kernel"
	@echo "  make run        - Ejecutar en QEMU"
	@echo "  make run-debug  - Ejecutar con GDB debug"
	@echo "  make test       - Ejecutar tests"
	@echo "  make iso        - Crear ISO bootable"
	@echo "  make run-iso    - Ejecutar desde ISO"
	@echo "  make clean      - Limpiar artefactos"
	@echo "  make install-deps - Instalar dependencias"
	@echo "  make check-deps   - Verificar dependencias"
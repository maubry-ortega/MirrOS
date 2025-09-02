# 🪞 MirrOS – Sistema Operativo Moderno en Zig

## 🎯 Filosofía del Proyecto

MirrOS es un sistema operativo modular, seguro y de alto rendimiento, escrito completamente en Zig, aprovechando:
- **comptime** para optimización en tiempo de compilación
- **Manejo explícito de memoria**, sin GC ni abstracciones ocultas
- **Sistema de build integrado**, simplificando CI/CD y portabilidad

La visión es un OS educativo y experimental, pero con estándares de calidad profesional y posibilidad de evolucionar hacia un entorno usable (similar a RedoxOS o SerenityOS, pero con Zig como ventaja).

## 📁 Estructura del Proyecto

El proyecto se organiza de forma profesional y escalable:

- **boot/** → Bootloader (Limine, Multiboot2, assembly de arranque).
- **arch/** → Soporte multi-arquitectura (x86_64 inicial, ARM64 a futuro).
- **kernel/** → Núcleo (memoria, scheduler, sincronización, tiempo).
- **drivers/** → Controladores (video, input, storage, buses).
- **services/** → Servicios (WASM runtime, Lua scripting).
- **fs/** → Sistemas de archivos (VFS, FAT32, EXT2).
- **sys/** → Syscalls y ABI del sistema.
- **lib/** → Librerías internas y de terceros.
- **tests/** → Tests unitarios e integrales.
- **scripts/** → Scripts de build, ejecución en QEMU y debugging.
- **config/** → Configuración del kernel.

## 📝 Convenciones y Buenas Prácticas

- **Naming**: PascalCase para tipos, snake_case para funciones/variables, camelCase para locales.
- **Errores explícitos**: cada módulo define sus propios ErrorSet.
- **Patrones de diseño**:
  - Singleton para gestores globales (ej. allocators).
  - Factory Pattern para creación de drivers.
- **Gestión de memoria**: manual, con allocators especializados.
- **Logging profesional**: niveles (debug, info, warning, error, fatal) con salida a serial/consola.

## 🧪 Calidad y Testing

- **Unit testing**: allocators, estructuras de datos, syscalls, FS.
- **Integración**: booteo completo hasta shell, ejecución de scripts.
- **Stress tests**: memoria, multitarea, IO.
- **QA**: benchmarks, profiling, análisis estático, docs.

## 📦 Releases Planeados

- **v0.1.0 Alpha** → Kernel booteable + consola + memoria básica + teclado.
- **v0.5.0 Beta** → Multitarea cooperativa + FAT32 + shell + Lua.
- **v1.0.0 Stable** → Multitarea preemptiva + networking + paquetes + documentación.

## 🎯 Próximos Hitos

- Terminar VMM con protección de memoria.
- Scheduler cooperativo funcional.
- Driver ATA + VFS con FAT32.
- Shell básico + scripting Lua.

## 🚀 Cómo Empezar

### Requisitos

- Zig 0.16.0 o superior
- QEMU para emulación
- Opcional: GDB para debugging

### Construcción y ejecución

1. **Compilar el proyecto:**
   ```bash
   zig build
   ```

2. **Ejecutar en QEMU:**
   ```bash
   zig build run
   ```

3. **Ejecutar tests:**
   ```bash
   zig build test
   ```

### Opciones nativas de Windows para ejecutar el kernel

#### 1. Ejecución automática (recomendado)
```powershell
# Detecta automáticamente la mejor opción disponible
.\scripts\run-native.ps1

# Ver qué opciones están disponibles
.\scripts\run-native.ps1 -ShowOptions
```

#### 2. Opciones específicas

**QEMU (más compatible):**
```powershell
# Si tienes QEMU instalado
.\scripts\run-native.ps1 -ForceQEMU

# O directamente con el script original
.\scripts\run.ps1
```

**WSL + QEMU (si tienes WSL):**
```powershell
.\scripts\run-native.ps1 -ForceWSL
```

**Hyper-V (Windows Pro/Enterprise):**
```powershell
.\scripts\run-hyperv.ps1
```

**VirtualBox:**
```powershell
.\scripts\run-virtualbox.ps1
```

### Construcción

1. **Compilar el proyecto:**
   ```powershell
   .\scripts\build.ps1
   ```

2. **Ejecutar tests:**
   ```powershell
   zig build test
   ```

### Instalación de herramientas

#### Opción 1: QEMU (recomendado)
1. Descargar QEMU desde https://www.qemu.org/download/
2. Instalar y agregar al PATH del sistema
3. Ejecutar: `.\scripts\run-native.ps1`

#### Opción 2: WSL + QEMU
1. Abrir PowerShell como administrador
2. Ejecutar: `wsl --install`
3. Reiniciar el sistema
4. Ejecutar: `.\scripts\run-native.ps1`

#### Opción 3: Hyper-V (solo Windows Pro/Enterprise)
1. Abrir PowerShell como administrador
2. Ejecutar: `Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All`
3. Reiniciar el sistema
4. Ejecutar: `.\scripts\run-hyperv.ps1`

## 👥 Contribuciones

Las contribuciones son bienvenidas. Por favor, sigue las convenciones de código y añade tests para nuevas funcionalidades.

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo LICENSE para más detalles.
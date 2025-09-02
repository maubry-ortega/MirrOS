# Script para ejecutar ZorroOS en QEMU

# Verificar que QEMU esté instalado
try {
    $qemuVersion = qemu-system-x86_64 --version
    Write-Host "Usando QEMU: $qemuVersion"
} catch {
    Write-Host "Error: QEMU no está instalado o no está en el PATH."
    Write-Host "Por favor, instale QEMU desde https://www.qemu.org/download/"
    exit 1
}

# Verificar si el kernel existe
$kernelPath = "zig-out/bin/zorro-kernel"
if (-not (Test-Path $kernelPath)) {
    Write-Host "Error: No se encontró el kernel. Ejecute scripts/build.ps1 primero."
    exit 1
}

# Parámetros para QEMU
$qemuParams = @(
    "-kernel", $kernelPath,
    "-m", "512M",
    "-serial", "stdio",
    "-no-reboot",
    "-no-shutdown"
)

# Verificar si se solicitó modo debug
if ($args -contains "-debug") {
    Write-Host "Iniciando en modo debug..."
    $qemuParams += @(
        "-s",
        "-S"
    )
    Write-Host "Esperando conexión GDB en localhost:1234..."
}

# Ejecutar QEMU
Write-Host "Iniciando ZorroOS en QEMU..."
qemu-system-x86_64 @qemuParams
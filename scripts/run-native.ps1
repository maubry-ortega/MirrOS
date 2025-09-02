# Script nativo de Windows para ejecutar ZorroOS
# Detecta automáticamente la mejor opción disponible

param(
    [switch]$ForceQEMU,
    [switch]$ForceWSL,
    [switch]$ShowOptions
)

Write-Host "=== ZorroOS - Ejecución nativa en Windows ===" -ForegroundColor Cyan

# Verificar si el kernel existe
$kernelPath = "zig-out/bin/zorro-kernel"
if (-not (Test-Path $kernelPath)) {
    Write-Host "Error: No se encontró el kernel. Ejecute scripts/build.ps1 primero." -ForegroundColor Red
    exit 1
}

# Función para probar QEMU
function Test-QEMU {
    try {
        $null = qemu-system-x86_64 --version 2>$null
        return $true
    } catch {
        return $false
    }
}

# Función para probar WSL
function Test-WSL {
    try {
        $null = wsl --status 2>$null
        return $true
    } catch {
        return $false
    }
}

# Función para probar Hyper-V
function Test-HyperV {
    try {
        $feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -ErrorAction SilentlyContinue
        return $feature -and $feature.State -eq "Enabled"
    } catch {
        return $false
    }
}

# Función para probar VirtualBox
function Test-VirtualBox {
    $vboxPaths = @(
        "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe",
        "C:\Program Files (x86)\Oracle\VirtualBox\VBoxManage.exe"
    )
    
    foreach ($path in $vboxPaths) {
        if (Test-Path $path) {
            return $true
        }
    }
    return $false
}

# Detectar opciones disponibles
$options = @()

if (Test-QEMU) { $options += "QEMU" }
if (Test-WSL) { $options += "WSL+QEMU" }
if (Test-HyperV) { $options += "Hyper-V" }
if (Test-VirtualBox) { $options += "VirtualBox" }

if ($ShowOptions -or $options.Count -eq 0) {
    Write-Host "Opciones de virtualización disponibles:" -ForegroundColor Yellow
    foreach ($option in $options) {
        Write-Host "  ✓ $option" -ForegroundColor Green
    }
    
    if ($options.Count -eq 0) {
        Write-Host "  ✗ No se encontraron opciones de virtualización" -ForegroundColor Red
        Write-Host ""
        Write-Host "Para instalar QEMU:" -ForegroundColor Cyan
        Write-Host "  1. Descargar desde: https://www.qemu.org/download/"
        Write-Host "  2. Agregar al PATH del sistema"
        Write-Host ""
        Write-Host "Para usar WSL:" -ForegroundColor Cyan
        Write-Host "  1. Ejecutar: wsl --install"
        Write-Host "  2. Reiniciar el sistema"
        exit 1
    }
    
    if ($ShowOptions) { exit 0 }
}

# Seleccionar la mejor opción
$selectedOption = $null

if ($ForceQEMU) {
    $selectedOption = "QEMU"
} elseif ($ForceWSL) {
    $selectedOption = "WSL+QEMU"
} else {
    # Prioridad: QEMU > WSL > Hyper-V > VirtualBox
    if ("QEMU" -in $options) {
        $selectedOption = "QEMU"
    } elseif ("WSL+QEMU" -in $options) {
        $selectedOption = "WSL+QEMU"
    } elseif ("Hyper-V" -in $options) {
        $selectedOption = "Hyper-V"
    } elseif ("VirtualBox" -in $options) {
        $selectedOption = "VirtualBox"
    }
}

Write-Host "Usando: $selectedOption" -ForegroundColor Green

# Ejecutar según la opción seleccionada
switch ($selectedOption) {
    "QEMU" {
        Write-Host "Iniciando ZorroOS en QEMU..." -ForegroundColor Green
        $qemuParams = @(
            "-kernel", $kernelPath,
            "-m", "512M",
            "-serial", "stdio",
            "-no-reboot",
            "-no-shutdown"
        )
        qemu-system-x86_64 @qemuParams
    }
    
    "WSL+QEMU" {
        Write-Host "Iniciando ZorroOS en WSL con QEMU..." -ForegroundColor Green
        $kernelLinuxPath = $kernelPath -replace "\\", "/" -replace "C:/", "/mnt/c/"
        wsl qemu-system-x86_64 -kernel $kernelLinuxPath -m 512M -serial stdio -no-reboot -no-shutdown
    }
    
    "Hyper-V" {
        Write-Host "Hyper-V detectado. Usando script dedicado..." -ForegroundColor Yellow
        .\scripts\run-hyperv.ps1
    }
    
    "VirtualBox" {
        Write-Host "VirtualBox detectado. Usando script dedicado..." -ForegroundColor Yellow
        .\scripts\run-virtualbox.ps1
    }
}

Write-Host "Ejecución completada." -ForegroundColor Green
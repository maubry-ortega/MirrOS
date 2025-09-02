# Script para ejecutar ZorroOS en Hyper-V (Windows nativo)

# Verificar si Hyper-V está disponible
function Test-HyperVAvailable {
    try {
        $hyperv = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
        return $hyperv.State -eq "Enabled"
    } catch {
        return $false
    }
}

# Verificar si el kernel existe
$kernelPath = "zig-out/bin/zorro-kernel"
if (-not (Test-Path $kernelPath)) {
    Write-Host "Error: No se encontró el kernel. Ejecute scripts/build.ps1 primero." -ForegroundColor Red
    exit 1
}

# Verificar Hyper-V
if (-not (Test-HyperVAvailable)) {
    Write-Host "Error: Hyper-V no está habilitado en este sistema." -ForegroundColor Red
    Write-Host "Para habilitar Hyper-V, ejecute como administrador:"
    Write-Host "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All"
    exit 1
}

# Nombre de la máquina virtual
$vmName = "ZorroOS-Test"

# Crear directorio temporal para archivos
$tempDir = "$env:TEMP\ZorroOS"
if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
}

# Copiar kernel al directorio temporal
Copy-Item -Path $kernelPath -Destination "$tempDir\kernel" -Force

# Verificar si la VM ya existe
$existingVM = Get-VM -Name $vmName -ErrorAction SilentlyContinue

if ($existingVM) {
    Write-Host "Máquina virtual '$vmName' ya existe. Eliminando..." -ForegroundColor Yellow
    Stop-VM -Name $vmName -Force -ErrorAction SilentlyContinue
    Remove-VM -Name $vmName -Force
}

# Crear nueva máquina virtual
Write-Host "Creando máquina virtual '$vmName'..." -ForegroundColor Green
New-VM -Name $vmName -MemoryStartupBytes 512MB -Generation 1 -Force | Out-Null

# Configurar la VM
Set-VM -Name $vmName -ProcessorCount 1 -CheckpointType Disabled -AutomaticStopAction ShutDown

# Crear disco virtual temporal
$vhdPath = "$tempDir\zorros-disk.vhdx"
New-VHD -Path $vhdPath -SizeBytes 64MB -Dynamic | Out-Null
Add-VMHardDiskDrive -VMName $vmName -Path $vhdPath

# Configurar arranque desde kernel
Set-VMFirmware -VMName $vmName -EnableSecureBoot Off
Set-VMFirmware -VMName $vmName -FirstBootDevice (Get-VMHardDiskDrive -VMName $vmName)

# Nota: Hyper-V no soporta arranque directo desde kernel ELF
Write-Host "Nota: Hyper-V requiere configuración adicional para arranque desde kernel." -ForegroundColor Yellow
Write-Host "Para pruebas rápidas, se recomienda usar QEMU con el script run.ps1" -ForegroundColor Yellow

# Mostrar instrucciones
Write-Host ""
Write-Host "=== Instrucciones para Hyper-V ===" -ForegroundColor Cyan
Write-Host "1. La VM '$vmName' ha sido creada con 512MB de RAM"
Write-Host "2. Para iniciar la VM: Start-VM -Name $vmName"
Write-Host "3. Para conectarte: vmconnect localhost $vmName"
Write-Host "4. Para detener: Stop-VM -Name $vmName -Force"
Write-Host ""
Write-Host "Alternativa recomendada: Usar QEMU con .\scripts\run.ps1"
# Script para ejecutar ZorroOS en VirtualBox (alternativa nativa Windows)

# Verificar que VirtualBox esté instalado
try {
    $vboxVersion = & "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" --version
    Write-Host "Usando VirtualBox versión: $vboxVersion" -ForegroundColor Green
} catch {
    Write-Host "Error: VirtualBox no está instalado o no está en el PATH." -ForegroundColor Red
    Write-Host "Por favor, instale VirtualBox desde https://www.virtualbox.org/wiki/Downloads"
    exit 1
}

# Verificar si el kernel existe
$kernelPath = "zig-out/bin/zorro-kernel"
if (-not (Test-Path $kernelPath)) {
    Write-Host "Error: No se encontró el kernel. Ejecute scripts/build.ps1 primero." -ForegroundColor Red
    exit 1
}

# Configuración
$vmName = "ZorroOS-VirtualBox"
$vboxManage = "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe"

# Verificar si la VM ya existe
$existingVM = & $vboxManage list vms | Select-String $vmName

if ($existingVM) {
    Write-Host "Máquina virtual '$vmName' ya existe. Eliminando..." -ForegroundColor Yellow
    & $vboxManage controlvm $vmName poweroff 2>$null
    Start-Sleep -Seconds 2
    & $vboxManage unregistervm $vmName --delete 2>$null
}

# Crear nueva máquina virtual
Write-Host "Creando máquina virtual '$vmName'..." -ForegroundColor Green
& $vboxManage createvm --name $vmName --ostype "Other" --register

# Configurar la VM
& $vboxManage modifyvm $vmName --memory 512 --cpus 1 --boot1 dvd
& $vboxManage modifyvm $vmName --nic1 nat --uart1 0x3F8 4 --uartmode1 disconnected

# Crear disco virtual
$diskPath = "$env:TEMP\zorros-disk.vdi"
& $vboxManage createmedium disk --filename $diskPath --size 64 --format VDI

# Agregar controlador SATA y disco
& $vboxManage storagectl $vmName --name "SATA Controller" --add sata --controller IntelAhci
& $vboxManage storageattach $vmName --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $diskPath

# Crear ISO temporal con el kernel (requiere herramientas adicionales)
Write-Host ""
Write-Host "=== Instrucciones para VirtualBox ===" -ForegroundColor Cyan
Write-Host "1. La VM '$vmName' ha sido creada con 512MB de RAM"
Write-Host "2. Para iniciar: VirtualBox → seleccionar '$vmName' → Iniciar"
Write-Host "3. Nota: VirtualBox no soporta arranque directo desde kernel ELF"
Write-Host ""
Write-Host "Alternativa recomendada: Usar QEMU con .\scripts\run.ps1"
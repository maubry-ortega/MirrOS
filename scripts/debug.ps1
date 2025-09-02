# Script para depurar ZorroOS con GDB

# Verificar que GDB esté instalado
try {
    $gdbVersion = gdb --version
    Write-Host "Usando GDB: $gdbVersion"
} catch {
    Write-Host "Error: GDB no está instalado o no está en el PATH."
    Write-Host "Por favor, instale GDB para depurar ZorroOS."
    exit 1
}

# Iniciar QEMU en modo debug en segundo plano
Start-Process -NoNewWindow -FilePath "powershell" -ArgumentList "-File", "scripts/run.ps1", "-debug"

# Esperar a que QEMU inicie
Start-Sleep -Seconds 2

# Iniciar GDB y conectar a QEMU
Write-Host "Conectando GDB a QEMU..."

# Crear archivo temporal de comandos GDB
$gdbInitFile = "temp_gdbinit.txt"
@"
target remote localhost:1234
symbol-file zig-out/bin/zorro-kernel
set disassembly-flavor intel
break kmain
continue
"@ | Out-File -FilePath $gdbInitFile

# Iniciar GDB con el archivo de comandos
gdb -x $gdbInitFile

# Limpiar archivo temporal
Remove-Item $gdbInitFile
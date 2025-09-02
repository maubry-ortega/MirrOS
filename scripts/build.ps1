# Script de compilación para ZorroOS

# Verificar que Zig esté instalado
try {
    $zigVersion = zig version
    Write-Host "Usando Zig versión: $zigVersion"
} catch {
    Write-Host "Error: Zig no está instalado o no está en el PATH."
    Write-Host "Por favor, instale Zig desde https://ziglang.org/download/"
    exit 1
}

# Compilar el proyecto
Write-Host "Compilando ZorroOS..."
zig build

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilación exitosa."
} else {
    Write-Host "Error en la compilación."
    exit 1
}
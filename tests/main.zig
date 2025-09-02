const std = @import("std");

// Importar módulos a probar
const log = @import("log");
const memory = @import("memory");

// Test para el sistema de logging
test "log system" {
    // Inicializar el sistema de logging
    log.init();

    // Probar diferentes niveles de log
    log.Zdebug("Test debug message", .{});
    log.Zinfo("Test info message", .{});
    log.Zwarning("Test warning message", .{});
    log.Zerror("Test error message", .{});

    // Verificar que no hay errores
    try std.testing.expect(true);
}

// Test para el sistema de memoria
test "memory system" {
    // Inicializar el sistema de memoria
    memory.init();

    // Verificar que la inicialización fue exitosa
    try std.testing.expect(true);
}

// Función principal para ejecutar todos los tests
pub fn main() !void {
    // Ejecutar todos los tests
    std.testing.refAllDeclsRecursive(@This());
}

const std = @import("std");
const log = @import("../kernel/log.zig");

// Configuración por defecto del sistema de logging
pub const default_level = log.LogLevel.info;

// Destinos habilitados por defecto
pub const default_destinations = [_]bool{
    true, // console
    false, // serial
    true, // memory_buffer
};

// Tamaño del buffer de memoria
pub const memory_buffer_size = 8192;

// Función para aplicar la configuración por defecto
pub fn applyDefaultConfig() void {
    // Establecer nivel de log
    log.setLevel(default_level);

    // Configurar destinos
    log.setDestination(.console, default_destinations[0]);
    log.setDestination(.serial, default_destinations[1]);
    log.setDestination(.memory_buffer, default_destinations[2]);

    log.Zinfo("Configuración de logging aplicada", .{});
}

// Función para habilitar todos los destinos (modo debug)
pub fn enableAllDestinations() void {
    log.setLevel(.debug);
    log.setDestination(.console, true);
    log.setDestination(.serial, true);
    log.setDestination(.memory_buffer, true);

    log.Zinfo("Modo debug: todos los destinos habilitados", .{});
}

// Función para modo producción (solo errores importantes)
pub fn enableProductionMode() void {
    log.setLevel(.warning);
    log.setDestination(.console, true);
    log.setDestination(.serial, false);
    log.setDestination(.memory_buffer, true);

    log.Zwarning("Modo producción: solo warnings y errores", .{});
}

const std = @import("std");
const console = @import("console.zig");

// Niveles de log
pub const LogLevel = enum {
    Kdebug,
    Kinfo,
    Kwarning,
    Kerror,
    Kfatal,
};

// Destinos de log
pub const LogDestination = enum {
    console,
    serial,
    memory_buffer,
};

// Configuración global del sistema de logging
var current_level: LogLevel = .info;
var destinations: [3]bool = [_]bool{ true, false, false }; // console, serial, memory_buffer
var memory_buffer: [8192]u8 = undefined;
var buffer_index: usize = 0;

// Inicializar el sistema de logging
pub fn init() void {
    // Configuración inicial
    current_level = .Kinfo;
    destinations = [_]bool{ true, false, false }; // Por defecto, solo consola
    buffer_index = 0;

    // Limpiar buffer de memoria
    @memset(memory_buffer[0..], 0);

    Zinfo("Sistema de logging inicializado", .{});
}

// Establecer el nivel de logging
pub fn setLevel(level: LogLevel) void {
    current_level = level;
    Zinfo("Nivel de logging cambiado a {s}", .{@tagName(level)});
}

// Habilitar/deshabilitar destinos de log
pub fn setDestination(dest: LogDestination, enabled: bool) void {
    destinations[@intFromEnum(dest)] = enabled;
    Zinfo("Destino de log {s} {s}", .{
        @tagName(dest),
        if (enabled) "habilitado" else "deshabilitado",
    });
}

// Funciones de logging para cada nivel
pub fn Zdebug(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(current_level) <= @intFromEnum(LogLevel.Kdebug)) {
        log(.Kdebug, fmt, args);
    }
}

pub fn Zinfo(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(current_level) <= @intFromEnum(LogLevel.Kinfo)) {
        log(.Kinfo, fmt, args);
    }
}

pub fn Zwarning(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(current_level) <= @intFromEnum(LogLevel.Kwarning)) {
        log(.Kwarning, fmt, args);
    }
}

pub fn Zerror(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(current_level) <= @intFromEnum(LogLevel.Kerror)) {
        log(.Kerror, fmt, args);
    }
}

pub fn Zfatal(comptime fmt: []const u8, args: anytype) void {
    if (@intFromEnum(current_level) <= @intFromEnum(LogLevel.Kfatal)) {
        log(.Kfatal, fmt, args);
    }
}

// Función interna para imprimir mensajes de log
fn log(level: LogLevel, comptime fmt: []const u8, args: anytype) void {
    // Prefijos para cada nivel
    const prefix_map = [_][]const u8{
        "[DEBUG] ",
        "[INFO] ",
        "[WARN] ",
        "[ERROR] ",
        "[FATAL] ",
    };

    // Colores para cada nivel
    const color_map = [_]console.Color{
        .light_blue, // debug
        .light_green, // info
        .yellow, // warning
        .light_red, // error
        .red, // fatal
    };

    // Formatear el mensaje
    var buf: [1024]u8 = undefined;
    const prefix = prefix_map[@intFromEnum(level)];
    const message = std.fmt.bufPrint(&buf, fmt, args) catch "Error de formato";

    // Enviar a los destinos habilitados
    if (destinations[@intFromEnum(LogDestination.console)]) {
        logToConsole(level, prefix, message, color_map[@intFromEnum(level)]);
    }

    if (destinations[@intFromEnum(LogDestination.serial)]) {
        logToSerial(prefix, message);
    }

    if (destinations[@intFromEnum(LogDestination.memory_buffer)]) {
        logToMemoryBuffer(prefix, message);
    }
}

// Escribir a la consola
fn logToConsole(_: LogLevel, prefix: []const u8, message: []const u8, color: console.Color) void {
    // Guardar el color actual
    console.setColor(color, .black);

    // Imprimir el prefijo
    console.print("{s}", .{prefix});

    // Imprimir el mensaje
    console.print("{s}\n", .{message});

    // Restaurar el color por defecto
    console.setColor(.light_gray, .black);
}

// Escribir a puerto serial
fn logToSerial(_: []const u8, _: []const u8) void {
    // Implementación de escritura a puerto serial
    // Por ahora, es un stub
}

// Escribir a buffer de memoria
fn logToMemoryBuffer(prefix: []const u8, message: []const u8) void {
    // Verificar si hay espacio en el buffer
    if (buffer_index + prefix.len + message.len + 1 >= memory_buffer.len) {
        // Buffer lleno, reiniciar
        buffer_index = 0;
    }

    // Copiar prefijo
    @memcpy(memory_buffer[buffer_index..][0..prefix.len], prefix);
    buffer_index += prefix.len;

    // Copiar mensaje
    @memcpy(memory_buffer[buffer_index..][0..message.len], message);
    buffer_index += message.len;

    // Añadir nueva línea
    memory_buffer[buffer_index] = '\n';
    buffer_index += 1;
}

// Obtener el buffer de memoria
pub fn getMemoryBuffer() []const u8 {
    return memory_buffer[0..buffer_index];
}

// Limpiar el buffer de memoria
pub fn clearMemoryBuffer() void {
    buffer_index = 0;
}

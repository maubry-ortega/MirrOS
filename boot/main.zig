const std = @import("std");
const limine = @import("limine.zig");

// Función principal requerida por Zig
pub fn main() void {
    // Esta función es requerida por el compilador de Zig
    // pero no se usa en un entorno de bootloader
}

// Definir las solicitudes de Limine
export var framebuffer_request: limine.FramebufferRequest = .{};
export var terminal_request: limine.TerminalRequest = .{};
export var memmap_request: limine.MemmapRequest = .{};
export var rsdp_request: limine.RsdpRequest = .{};

// Punto de entrada del bootloader
pub fn _start() callconv(.c) noreturn {
    // Inicializar el bootloader
    init();

    // Transferir el control al kernel
    jumpToKernel();

    // Nunca debería llegar aquí
    while (true) {}
}

// Inicialización del bootloader
fn init() void {
    // Verificar que las solicitudes de Limine fueron respondidas
    if (framebuffer_request.response == null) {
        panic("No se recibió respuesta para framebuffer");
    }

    if (terminal_request.response == null) {
        panic("No se recibió respuesta para terminal");
    }

    if (memmap_request.response == null) {
        panic("No se recibió respuesta para mapa de memoria");
    }

    // Inicializar la terminal
    const terminal = &terminal_request.response.?.terminals[0];
    _ = terminal.callback.?(terminal, "ZorroOS Bootloader Iniciado\n", 0);
}

// Saltar al kernel
fn jumpToKernel() noreturn {
    // Aquí cargaríamos el kernel y saltaríamos a su punto de entrada
    // Por ahora, simplemente entramos en un bucle infinito
    while (true) {}
}

// Función de pánico
fn panic(msg: []const u8) noreturn {
    if (terminal_request.response != null) {
        const terminal = &terminal_request.response.?.terminals[0];
        _ = terminal.callback.?(terminal, "PANIC: ", 0);
        _ = terminal.callback.?(terminal, msg, 0);
        _ = terminal.callback.?(terminal, "\n", 0);
    }

    while (true) {}
}
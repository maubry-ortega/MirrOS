const std = @import("std");
const console = @import("console.zig");
const memory = @import("memory.zig");
const arch = @import("arch");
const log = @import("log.zig");

// Punto de entrada del kernel
pub fn kmain() callconv(.c) noreturn {
    // Inicializar arquitectura específica
    arch.init();

    // Inicializar consola
    console.init();
    console.print("ZorroOS v0.1.0 - Kernel Iniciado\n", .{});

    // Inicializar sistema de logging
    log.init();
    log.Zinfo("Sistema de logging inicializado", .{});

    // Inicializar gestor de memoria
    memory.init();
    log.Zinfo("Gestor de memoria inicializado", .{});

    // Inicializar interrupciones
    arch.interrupts.init();
    log.Zinfo("Interrupciones inicializadas", .{});

    // Inicializar temporizador
    arch.timer.init(100); // 100 Hz
    log.Zinfo("Temporizador inicializado", .{});

    // Habilitar interrupciones
    arch.enableInterrupts();
    log.Zinfo("Interrupciones habilitadas", .{});

    // Bucle principal del kernel
    log.Zinfo("Entrando en bucle principal", .{});
    while (true) {
        // Poner la CPU en modo de bajo consumo hasta la próxima interrupción
        arch.hlt();
    }
}

// Función de pánico del kernel
pub fn panic(msg: []const u8, error_return_trace: ?*std.builtin.StackTrace, ret_addr: ?usize) noreturn {
    // @setCold(true); // Esta función integrada no es válida en la versión actual de Zig

    // Deshabilitar interrupciones
    arch.disableInterrupts();

    // Imprimir mensaje de pánico
    console.setColor(.red, .black);
    console.print("\n\nKERNEL PANIC: {s}\n", .{msg});

    if (ret_addr) |addr| {
        console.print("Dirección de retorno: 0x{x}\n", .{addr});
    }

    if (error_return_trace) |_| {
        console.print("Stack trace:\n", .{});
        // Aquí se podría imprimir la traza de la pila
    }

    // Detener el sistema
    while (true) {
        arch.hlt();
    }
}

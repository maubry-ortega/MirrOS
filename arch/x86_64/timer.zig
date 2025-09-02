const std = @import("std");
const log = @import("log");
const arch = @import("arch.zig");
const interrupts = @import("interrupts.zig");

// Frecuencia base del PIT (Programmable Interval Timer)
const PIT_FREQUENCY: u32 = 1193182;

// Contador de ticks
var tick_count: u64 = 0;

// Inicializar el temporizador
pub fn init(frequency: u32) void {
    log.Zinfo("Inicializando temporizador a {} Hz", .{frequency});
    
    // Calcular el divisor para la frecuencia deseada
    const divisor = PIT_FREQUENCY / frequency;
    
    // Enviar el comando al PIT
    arch.outb(0x43, 0x36); // Canal 0, modo 3, acceso a ambos bytes
    
    // Enviar el divisor
    arch.outb(0x40, @as(u8, @intCast(divisor & 0xFF))); // Byte bajo
    arch.outb(0x40, @as(u8, @intCast(divisor >> 8)));   // Byte alto
    
    // Registrar el manejador de interrupción
    interrupts.registerHandler(0x20, timerHandler);
    
    // Desenmascarar la interrupción del temporizador (IRQ0)
    arch.outb(0x21, arch.inb(0x21) & ~0x01);
    
    log.Zinfo("Temporizador inicializado", .{});
}

// Manejador de interrupción del temporizador
fn timerHandler() callconv(.Interrupt) void {
    // Incrementar el contador de ticks
    tick_count += 1;
    
    // Cada segundo (según la frecuencia configurada), mostrar un mensaje
    if (tick_count % 100 == 0) {
        log.Zdebug("Tick: {}", .{tick_count});
    }
    
    // Enviar EOI
    interrupts.sendEoi(0x20);
}

// Obtener el número de ticks desde el inicio
pub fn getTicks() u64 {
    return tick_count;
}

// Esperar un número de milisegundos
pub fn sleep(ms: u32) void {
    const target_ticks = tick_count + (ms * 100) / 1000;
    while (tick_count < target_ticks) {
        arch.hlt();
    }
}
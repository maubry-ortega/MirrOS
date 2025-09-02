const std = @import("std");
const log = @import("log");

// Módulos de arquitectura específica
pub const interrupts = @import("interrupts.zig");
pub const timer = @import("timer.zig");

// Inicializar la arquitectura
pub fn init() void {
    log.Zinfo("Inicializando arquitectura x86_64", .{});

    // Inicializar GDT (Global Descriptor Table)
    initGDT();

    // Inicializar IDT (Interrupt Descriptor Table)
    // Se hará en interrupts.init()
}

// Inicializar la GDT
fn initGDT() void {
    log.Zinfo("Inicializando GDT", .{});
    // Implementación de la inicialización de la GDT
}

// Habilitar interrupciones
pub fn enableInterrupts() void {
    asm volatile ("sti");
}

// Deshabilitar interrupciones
pub fn disableInterrupts() void {
    asm volatile ("cli");
}

// Detener la CPU hasta la próxima interrupción
pub fn hlt() void {
    asm volatile ("hlt");
}

// Leer puerto de E/S
pub fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]"
        : [result] "={al}" (-> u8),
        : [port] "N{dx}" (port),
    );
}

// Escribir puerto de E/S
pub fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "N{dx}" (port),
    );
}

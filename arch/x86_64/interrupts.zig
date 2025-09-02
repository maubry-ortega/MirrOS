const std = @import("std");
const log = @import("log");
const arch = @import("arch.zig");

// Estructura para la entrada de la IDT
const IdtEntry = packed struct {
    offset_low: u16,
    selector: u16,
    ist: u8,
    type_attr: u8,
    offset_mid: u16,
    offset_high: u32,
    reserved: u32,
};

// Estructura para el registro IDTR
const IdtRegister = packed struct {
    limit: u16,
    base: u64,
};

// Número de entradas en la IDT
const IDT_ENTRIES: usize = 256;

// IDT global
var idt: [IDT_ENTRIES]IdtEntry = undefined;

// Registro IDTR
var idtr: IdtRegister = undefined;

// Inicializar el sistema de interrupciones
pub fn init() void {
    log.Zinfo("Inicializando sistema de interrupciones", .{});

    // Inicializar la IDT
    initIdt();

    // Configurar el controlador de interrupciones (PIC)
    initPic();

    log.Zinfo("Sistema de interrupciones inicializado", .{});
}

// Inicializar la IDT
fn initIdt() void {
    // Limpiar la IDT
    @memset(@as([*]u8, @ptrCast(&idt))[0..@sizeOf(@TypeOf(idt))], 0);

    // Configurar las entradas de la IDT
    // Aquí se configurarían los manejadores de excepciones e interrupciones

    // Configurar el registro IDTR
    idtr.limit = @sizeOf(@TypeOf(idt)) - 1;
    idtr.base = @intFromPtr(&idt);

    // Cargar la IDT
    loadIdt();
}

// Cargar la IDT
fn loadIdt() void {
    asm volatile ("lidt (%[idtr])"
        :
        : [idtr] "r" (&idtr),
    );
}

// Inicializar el controlador de interrupciones (PIC)
fn initPic() void {
    // Enviar ICW1: inicialización
    arch.outb(0x20, 0x11); // PIC maestro
    arch.outb(0xA0, 0x11); // PIC esclavo

    // Enviar ICW2: remapeo de IRQs
    arch.outb(0x21, 0x20); // PIC maestro -> IRQ 0-7: int 0x20-0x27
    arch.outb(0xA1, 0x28); // PIC esclavo -> IRQ 8-15: int 0x28-0x2F

    // Enviar ICW3: cascada
    arch.outb(0x21, 0x04); // PIC maestro tiene esclavo en IRQ2
    arch.outb(0xA1, 0x02); // PIC esclavo tiene maestro en IRQ2

    // Enviar ICW4: modo 8086
    arch.outb(0x21, 0x01); // PIC maestro
    arch.outb(0xA1, 0x01); // PIC esclavo

    // Enmascarar todas las interrupciones excepto IRQ2 (cascada)
    arch.outb(0x21, 0xFB); // 1111 1011 - Permitir IRQ2
    arch.outb(0xA1, 0xFF); // 1111 1111 - Enmascarar todas
}

// Registrar un manejador de interrupción
pub fn registerHandler(interrupt: u8, handler: fn () callconv(.Interrupt) void) void {
    const addr = @intFromPtr(handler);

    idt[interrupt].offset_low = @as(u16, @intCast(addr));
    idt[interrupt].selector = 0x08; // Selector de código del kernel
    idt[interrupt].ist = 0; // No usar IST
    idt[interrupt].type_attr = 0x8E; // Puerta de interrupción, presente, DPL=0
    idt[interrupt].offset_mid = @as(u16, @intCast(addr >> 16));
    idt[interrupt].offset_high = @as(u32, @intCast(addr >> 32));
    idt[interrupt].reserved = 0;
}

// Enviar EOI (End of Interrupt) al PIC
pub fn sendEoi(interrupt: u8) void {
    if (interrupt >= 0x28) {
        // Si es del PIC esclavo, enviar EOI a ambos
        arch.outb(0xA0, 0x20);
    }

    // Enviar EOI al PIC maestro
    arch.outb(0x20, 0x20);
}

// Definiciones para el bootloader Limine

// Constantes comunes
pub const LIMINE_COMMON_MAGIC = [_]u64{ 0xc7b1dd30df4c8b88, 0x0a82e883a194f07b };

// Estructura base para las solicitudes de Limine
pub const BaseRequest = extern struct {
    id: [4]u64 align(8),
    revision: u64,
    response: ?*BaseResponse,
};

// Estructura base para las respuestas de Limine
pub const BaseResponse = extern struct {
    revision: u64,
};

// Solicitud de framebuffer
pub const FramebufferRequest = extern struct {
    id: [4]u64 align(8) = [_]u64{ LIMINE_COMMON_MAGIC[0], LIMINE_COMMON_MAGIC[1], 0xbcf13a9d1f791bcb, 0xd50f5c3544f40ae7 },
    revision: u64 = 0,
    response: ?*FramebufferResponse = null,
};

// Respuesta de framebuffer
pub const FramebufferResponse = extern struct {
    revision: u64,
    framebuffer_count: u64,
    framebuffers: [*]?*Framebuffer,
};

// Estructura de framebuffer
pub const Framebuffer = extern struct {
    address: [*]u8,
    width: u64,
    height: u64,
    pitch: u64,
    bpp: u16,
    memory_model: u8,
    red_mask_size: u8,
    red_mask_shift: u8,
    green_mask_size: u8,
    green_mask_shift: u8,
    blue_mask_size: u8,
    blue_mask_shift: u8,
    edid_size: u64,
    edid: ?[*]u8,
};

// Solicitud de terminal
pub const TerminalRequest = extern struct {
    id: [4]u64 align(8) = [_]u64{ LIMINE_COMMON_MAGIC[0], LIMINE_COMMON_MAGIC[1], 0xc8ac59310c2b0844, 0xa68d0c7265d38878 },
    revision: u64 = 0,
    response: ?*TerminalResponse = null,
};

// Respuesta de terminal
pub const TerminalResponse = extern struct {
    revision: u64,
    terminal_count: u64,
    terminals: [*]Terminal,
    write: ?*const fn (?*Terminal, [*]const u8, u64) callconv(.c) void = null,
};

// Estructura de terminal
pub const Terminal = extern struct {
    columns: u32,
    rows: u32,
    framebuffer: ?*Framebuffer,
    callback: ?*const fn (?*Terminal, [*]const u8, u64) callconv(.c) void,
};

// Solicitud de mapa de memoria
pub const MemmapRequest = extern struct {
    id: [4]u64 align(8) = [_]u64{ LIMINE_COMMON_MAGIC[0], LIMINE_COMMON_MAGIC[1], 0x67cf3d9d378a806f, 0xe304acdfc50c3c62 },
    revision: u64 = 0,
    response: ?*MemmapResponse = null,
};

// Respuesta de mapa de memoria
pub const MemmapResponse = extern struct {
    revision: u64,
    entry_count: u64,
    entries: [*]?*MemmapEntry,
};

// Tipos de entradas de memoria
pub const MEMMAP_USABLE = 0;
pub const MEMMAP_RESERVED = 1;
pub const MEMMAP_ACPI_RECLAIMABLE = 2;
pub const MEMMAP_ACPI_NVS = 3;
pub const MEMMAP_BAD_MEMORY = 4;
pub const MEMMAP_BOOTLOADER_RECLAIMABLE = 5;
pub const MEMMAP_KERNEL_AND_MODULES = 6;
pub const MEMMAP_FRAMEBUFFER = 7;

// Estructura de entrada de mapa de memoria
pub const MemmapEntry = extern struct {
    base: u64,
    length: u64,
    type: u64,
};

// Solicitud de RSDP (Root System Description Pointer)
pub const RsdpRequest = extern struct {
    id: [4]u64 align(8) = [_]u64{ LIMINE_COMMON_MAGIC[0], LIMINE_COMMON_MAGIC[1], 0xc5e77b6b397e7b43, 0x27637845accdcf3c },
    revision: u64 = 0,
    response: ?*RsdpResponse = null,
};

// Respuesta de RSDP
pub const RsdpResponse = extern struct {
    revision: u64,
    address: ?*anyopaque,
};
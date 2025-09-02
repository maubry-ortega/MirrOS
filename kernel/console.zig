const std = @import("std");

// Colores de texto
pub const Color = enum(u4) {
    black = 0,
    blue = 1,
    green = 2,
    cyan = 3,
    red = 4,
    magenta = 5,
    brown = 6,
    light_gray = 7,
    dark_gray = 8,
    light_blue = 9,
    light_green = 10,
    light_cyan = 11,
    light_red = 12,
    light_magenta = 13,
    yellow = 14,
    white = 15,
};

// Estructura para el buffer de video
const VgaBuffer = struct {
    const width: usize = 80;
    const height: usize = 25;
    const buffer_addr: [*]volatile u16 = @ptrFromInt(0xB8000);
    
    var row: usize = 0;
    var col: usize = 0;
    var color: u8 = makeColor(.light_gray, .black);
    
    // Inicializar la consola
    pub fn init() void {
        clear();
    }
    
    // Limpiar la pantalla
    pub fn clear() void {
        const blank = makeVgaEntry(' ', color);
        
        var y: usize = 0;
        while (y < height) : (y += 1) {
            var x: usize = 0;
            while (x < width) : (x += 1) {
                buffer_addr[y * width + x] = blank;
            }
        }
        
        row = 0;
        col = 0;
    }
    
    // Establecer el color de texto
    pub fn setColor(fg: Color, bg: Color) void {
        color = makeColor(fg, bg);
    }
    
    // Escribir un carácter en la posición actual
    pub fn putCharacter(c: u8) void {
        if (c == '\n') {
            // Nueva línea
            col = 0;
            row += 1;
        } else if (c == '\r') {
            // Retorno de carro
            col = 0;
        } else if (c == '\t') {
            // Tabulación (4 espacios)
            const spaces = 4 - (col % 4);
            var i: usize = 0;
            while (i < spaces) : (i += 1) {
                putCharacter(' ');
            }
        } else {
            // Carácter normal
            buffer_addr[row * width + col] = makeVgaEntry(c, color);
            col += 1;
        }
        
        // Si llegamos al final de la línea, avanzamos a la siguiente
        if (col >= width) {
            col = 0;
            row += 1;
        }
        
        // Si llegamos al final de la pantalla, desplazamos el contenido
        if (row >= height) {
            scrollUp();
        }
    }
    
    // Desplazar el contenido de la pantalla hacia arriba
    fn scrollUp() void {
        // Mover todas las líneas una posición hacia arriba
        var y: usize = 0;
        while (y < height - 1) : (y += 1) {
            var x: usize = 0;
            while (x < width) : (x += 1) {
                buffer_addr[y * width + x] = buffer_addr[(y + 1) * width + x];
            }
        }
        
        // Limpiar la última línea
        const blank = makeVgaEntry(' ', color);
        var x: usize = 0;
        while (x < width) : (x += 1) {
            buffer_addr[(height - 1) * width + x] = blank;
        }
        
        // Ajustar la posición del cursor
        row = height - 1;
    }
    
    // Crear una entrada para el buffer de video
    fn makeVgaEntry(c: u8, entry_color: u8) u16 {
        const c_u16: u16 = c;
        const color_u16: u16 = entry_color;
        return c_u16 | (color_u16 << 8);
    }
    
    // Crear un color combinando foreground y background
    fn makeColor(fg: Color, bg: Color) u8 {
        return @as(u8, @intFromEnum(fg)) | (@as(u8, @intFromEnum(bg)) << 4);
    }
};

// Inicializar la consola
pub fn init() void {
    VgaBuffer.init();
}

// Establecer el color de texto
pub fn setColor(fg: Color, bg: Color) void {
    VgaBuffer.setColor(fg, bg);
}

// Imprimir un carácter
pub fn putChar(c: u8) void {
    VgaBuffer.putCharacter(c);
}

// Imprimir una cadena
pub fn print(comptime fmt: []const u8, args: anytype) void {
    var buf: [1024]u8 = undefined;
    const str = std.fmt.bufPrint(&buf, fmt, args) catch "Error de formato";
    
    for (str) |c| {
        putChar(c);
    }
}
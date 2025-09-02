const std = @import("std");

pub fn build(b: *std.Build) void {
    // Configuración estándar
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Configuración del kernel para target freestanding
    const kernel_target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
    });
    const kernel_module = b.createModule(.{
        .root_source_file = b.path("kernel/main.zig"),
        .target = kernel_target,
        .optimize = optimize,
    });
    kernel_module.addImport("arch", b.createModule(.{
        .root_source_file = b.path("arch/x86_64/arch.zig"),
        .target = kernel_target,
        .optimize = optimize,
    }));
    kernel_module.addImport("log", b.createModule(.{
        .root_source_file = b.path("kernel/log.zig"),
        .target = kernel_target,
        .optimize = optimize,
    }));
    const kernel_exe = b.addExecutable(.{
        .name = "zorro-kernel",
        .root_module = kernel_module,
    });



    // Configuración del bootloader
    const bootloader_module = b.createModule(.{
        .root_source_file = b.path("boot/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const bootloader = b.addExecutable(.{
        .name = "zorro-boot",
        .root_module = bootloader_module,
    });

    // Instalar artefactos
    b.installArtifact(kernel_exe);
    b.installArtifact(bootloader);

    // Crear comandos de ejecución
    const run_cmd = b.addSystemCommand(&[_][]const u8{
        "qemu-system-x86_64",
        "-kernel",
        "zig-out/bin/zorro-kernel",
        "-m",
        "512M",
        "-serial",
        "stdio",
    });
    run_cmd.step.dependOn(b.getInstallStep());

    // Crear paso de ejecución
    const run_step = b.step("run", "Ejecutar ZorroOS en QEMU");
    run_step.dependOn(&run_cmd.step);

    // Tests unitarios
    const test_module = b.createModule(.{
        .root_source_file = b.path("tests/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    test_module.addImport("log", b.createModule(.{
        .root_source_file = b.path("kernel/log.zig"),
        .target = target,
        .optimize = optimize,
    }));
    test_module.addImport("memory", b.createModule(.{
        .root_source_file = b.path("kernel/memory.zig"),
        .target = target,
        .optimize = optimize,
    }));
    const unit_tests = b.addTest(.{
        .root_module = test_module,
    });

    const run_unit_tests = b.addRunArtifact(unit_tests);

    // Crear paso de test
    const test_step = b.step("test", "Ejecutar tests unitarios");
    test_step.dependOn(&run_unit_tests.step);
}

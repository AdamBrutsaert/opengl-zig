const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // 0. Create the dependencies
    const glfw_dep = b.dependency("mach-glfw", .{
        .target = target,
        .optimize = optimize,
    });

    const gl_module = @import("zigglgen").generateBindingsModule(b, .{
        .api = .gl,
        .version = .@"4.6",
        .profile = .core,
        .extensions = &.{},
    });

    const zigimg_dep = b.dependency("zigimg", .{
        .target = target,
        .optimize = optimize,
    });

    const zalgebra_dep = b.dependency("zalgebra", .{
        .target = target,
        .optimize = optimize,
    });

    const ecs_dep = b.dependency("ecs", .{
        .target = target,
        .optimize = optimize,
    });

    // 1. Create the engine module
    const engine_module = b.addModule("engine", .{
        .root_source_file = b.path("engine/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    engine_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));
    engine_module.addImport("gl", gl_module);

    // 2. Create the app module
    const app_module = b.addModule("app", .{
        .root_source_file = b.path("app/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    app_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));
    app_module.addImport("gl", gl_module);
    app_module.addImport("zigimg", zigimg_dep.module("zigimg"));
    app_module.addImport("zalgebra", zalgebra_dep.module("zalgebra"));
    app_module.addImport("engine", engine_module);
    app_module.addImport("ecs", ecs_dep.module("ecs"));

    // 3. Create the executable
    const exe = b.addExecutable(.{
        .name = "app",
        .root_module = app_module,
    });

    b.installArtifact(exe);

    // 4. Create the run step
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "hello",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const glfw_dep = b.dependency("mach-glfw", .{
        .target = target,
        .optimize = optimize,
    });

    const gl_bindings = @import("zigglgen").generateBindingsModule(b, .{ .api = .gl, .version = .@"4.6", .profile = .core, .extensions = &.{} });

    exe.root_module.addImport("mach-glfw", glfw_dep.module("mach-glfw"));
    exe.root_module.addImport("gl", gl_bindings);

    b.installArtifact(exe);

    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);
}

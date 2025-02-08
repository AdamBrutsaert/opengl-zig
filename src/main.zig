const std = @import("std");
const za = @import("zalgebra");
const glfw = @import("mach-glfw");
const eng = @import("engine.zig");
const Camera = @import("camera.zig").Camera;
const Container = @import("container.zig").Container;

pub const MyScene = struct {
    allocator: std.heap.GeneralPurposeAllocator(.{}) = undefined,
    camera: Camera = undefined,
    container: Container = undefined,

    escaped: bool = false,
    mouse_first: bool = true,
    mouse_last_x: f32 = undefined,
    mouse_last_y: f32 = undefined,

    const positions = [_]za.Vec3{
        za.Vec3.new(0.0, 0.0, 0.0),
        za.Vec3.new(2.0, 5.0, -15.0),
        za.Vec3.new(-1.5, -2.2, -2.5),
        za.Vec3.new(-3.8, -2.0, -12.3),
        za.Vec3.new(2.4, -0.4, -3.5),
        za.Vec3.new(-1.7, 3.0, -7.5),
        za.Vec3.new(1.3, -2.0, -2.5),
        za.Vec3.new(1.5, 2.0, -2.5),
        za.Vec3.new(1.5, 0.2, -1.5),
        za.Vec3.new(-1.3, 1.0, -1.5),
    };

    pub fn onEnter(self: *MyScene, app: *eng.App) !void {
        app.window.setTitle("MyScene");

        self.allocator = std.heap.GeneralPurposeAllocator(.{}){};
        const framebuffer_size = app.window.getFramebufferSize();
        self.camera = Camera.init(@floatFromInt(framebuffer_size.width), @floatFromInt(framebuffer_size.height));
        self.container = try Container.init(self.allocator.allocator());

        app.window.setInputMode(glfw.Window.InputMode.cursor, glfw.Window.InputModeCursor.disabled);
    }

    pub fn onExit(self: *MyScene, app: *eng.App) void {
        _ = app;
        self.container.deinit();
        _ = self.allocator.deinit();
    }

    pub fn onEvent(self: *MyScene, app: *eng.App, event: eng.Event) !void {
        switch (event) {
            .mouseMove => |pos| {
                if (self.escaped) return;

                if (self.mouse_first) {
                    self.mouse_last_x = pos.x;
                    self.mouse_last_y = pos.y;
                    self.mouse_first = false;
                    return;
                }

                const sensitivity = 0.1;
                const x_offset = (pos.x - self.mouse_last_x) * sensitivity;
                const y_offset = (self.mouse_last_y - pos.y) * sensitivity;
                self.mouse_last_x = pos.x;
                self.mouse_last_y = pos.y;

                self.camera.turn(x_offset, y_offset);
            },
            .key => |key| {
                if (key.key == glfw.Key.escape and key.action == glfw.Action.press) {
                    self.escaped = !self.escaped;
                    self.mouse_first = true;
                    app.window.setInputMode(glfw.Window.InputMode.cursor, if (self.escaped) glfw.Window.InputModeCursor.normal else glfw.Window.InputModeCursor.disabled);
                }
            },
        }
    }

    pub fn fixedUpdate(self: *MyScene, app: *eng.App, fixedDeltaTime: f32) !void {
        const camera_speed = 2.5 * fixedDeltaTime;

        const x = @as(i32, @intFromBool(app.window.getKey(glfw.Key.d) == glfw.Action.press)) - @as(i32, @intFromBool(app.window.getKey(glfw.Key.a) == glfw.Action.press));
        const y = @as(i32, @intFromBool(app.window.getKey(glfw.Key.space) == glfw.Action.press)) - @as(i32, @intFromBool(app.window.getKey(glfw.Key.left_shift) == glfw.Action.press));
        const z = @as(i32, @intFromBool(app.window.getKey(glfw.Key.w) == glfw.Action.press)) - @as(i32, @intFromBool(app.window.getKey(glfw.Key.s) == glfw.Action.press));

        self.camera.move(
            @as(f32, @floatFromInt(z)) * camera_speed,
            @as(f32, @floatFromInt(x)) * camera_speed,
            @as(f32, @floatFromInt(y)) * camera_speed,
        );
    }

    pub fn update(self: *MyScene, app: *eng.App, deltaTime: f32) !void {
        _ = deltaTime;

        const framebuffer_size = app.window.getFramebufferSize();
        self.camera.resize(@floatFromInt(framebuffer_size.width), @floatFromInt(framebuffer_size.height));

        for (positions) |position| {
            self.container.render(self.camera, position);
        }
    }

    fn scene(self: *MyScene) eng.Scene {
        return eng.Scene.init(self);
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var my_scene = MyScene{};

    var application = try eng.App.init(gpa.allocator(), .{
        .title = "OpenGL in Zig!",
        .width = 1280,
        .height = 720,
        .scene = my_scene.scene(),
    });
    defer application.deinit(gpa.allocator());

    try application.run();
}

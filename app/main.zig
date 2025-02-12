const std = @import("std");
const za = @import("zalgebra");
const glfw = @import("mach-glfw");
const eng = @import("engine");
const ecs = @import("ecs");

const meshes = @import("meshes.zig");
const components = @import("components.zig");

const Camera = @import("camera.zig").Camera;

pub const MyScene = struct {
    allocator: std.heap.GeneralPurposeAllocator(.{}) = undefined,
    camera: Camera = undefined,

    container_mesh: meshes.ContainerMesh = undefined,
    light_mesh: meshes.LightMesh = undefined,

    registry: ecs.Registry = undefined,

    // containers: [10]container.Container = undefined,
    // pointLights: [4]light.PointLight = undefined,
    // directionalLight: light.DirectionalLight = undefined,

    escaped: bool = false,
    mouse_first: bool = true,
    mouse_last_x: f32 = undefined,
    mouse_last_y: f32 = undefined,

    const containerPositions = [10]za.Vec3{
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

    const pointLightPositions = [4]za.Vec3{
        za.Vec3.new(0.7, 0.2, 2.0),
        za.Vec3.new(2.3, -3.3, -4.0),
        za.Vec3.new(-4.0, 2.0, -12.0),
        za.Vec3.new(0.0, 0.0, -3.0),
    };

    pub fn onEnter(self: *MyScene, app: *eng.App) !void {
        app.window.setTitle("MyScene");
        app.window.setInputMode(glfw.Window.InputMode.cursor, glfw.Window.InputModeCursor.disabled);

        self.allocator = std.heap.GeneralPurposeAllocator(.{}){};
        const framebuffer_size = app.window.getFramebufferSize();
        self.camera = Camera.init(@floatFromInt(framebuffer_size.width), @floatFromInt(framebuffer_size.height));

        // Meshes
        self.container_mesh = try meshes.ContainerMesh.init(self.allocator.allocator());
        errdefer self.container_mesh.deinit();
        self.light_mesh = try meshes.LightMesh.init(self.allocator.allocator());
        errdefer self.light_mesh.deinit();

        // ECS
        self.registry = ecs.Registry.init(self.allocator.allocator());

        // Objects
        for (containerPositions) |position| {
            const entity = self.registry.create();
            try self.registry.set(entity, components.Transform{ .position = position });
            try self.registry.set(entity, components.Material{
                .ambient = za.Vec3.new(1.0, 0.5, 0.31),
                .diffuse = za.Vec3.new(1.0, 0.5, 0.31),
                .specular = za.Vec3.new(0.5, 0.5, 0.5),
                .shininess = 32.0,
            });
            try self.registry.set(entity, components.Container{});
        }

        // Lights
        {
            const entity = self.registry.create();
            try self.registry.set(entity, components.DirectionalLight{
                .ambient = za.Vec3.new(0.05, 0.05, 0.05),
                .diffuse = za.Vec3.new(0.4, 0.4, 0.4),
                .specular = za.Vec3.new(0.5, 0.5, 0.5),
                .direction = za.Vec3.new(-0.2, -1.0, -0.3),
            });
        }

        for (pointLightPositions) |position| {
            const entity = self.registry.create();
            try self.registry.set(entity, components.Transform{ .position = position });
            try self.registry.set(entity, components.PointLight{
                .ambient = za.Vec3.new(0.05, 0.05, 0.05),
                .diffuse = za.Vec3.new(0.8, 0.8, 0.8),
                .specular = za.Vec3.new(1.0, 1.0, 1.0),
                .constant = 1.0,
                .linear = 0.09,
                .quadratic = 0.032,
            });
        }
    }

    pub fn onExit(self: *MyScene, app: *eng.App) void {
        _ = app;
        self.container_mesh.deinit();
        self.light_mesh.deinit();
        self.registry.deinit();
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

        const allocator = self.allocator.allocator();

        const framebuffer_size = app.window.getFramebufferSize();
        self.camera.resize(@floatFromInt(framebuffer_size.width), @floatFromInt(framebuffer_size.height));

        // Directional light
        var directionalLights = std.ArrayList(components.DirectionalLight).init(allocator);
        defer directionalLights.deinit();

        {
            var view = try self.registry.view(.{components.DirectionalLight});
            var it = view.entityIterator();

            while (it.next()) |entity| {
                const directionalLight = self.registry.get(components.DirectionalLight, entity);
                _ = try directionalLights.append(directionalLight.*);
            }
        }

        // Point lights
        var pointLights = std.MultiArrayList(struct { transform: components.Transform, light: components.PointLight }){};
        defer pointLights.deinit(allocator);

        {
            var view = try self.registry.view(.{ components.Transform, components.PointLight });
            var it = view.entityIterator();

            while (it.next()) |entity| {
                const transform = self.registry.get(components.Transform, entity);
                const pointLight = self.registry.get(components.PointLight, entity);

                self.light_mesh.render(self.camera, transform.*, pointLight.*);

                try pointLights.append(allocator, .{
                    .transform = transform.*,
                    .light = pointLight.*,
                });
            }
        }

        // Containers
        {
            var view = try self.registry.view(.{ components.Transform, components.Material, components.Container });
            var it = view.entityIterator();

            while (it.next()) |entity| {
                const transform = self.registry.get(components.Transform, entity);
                const material = self.registry.get(components.Material, entity);

                // TODO: hardcoded directional light index

                self.container_mesh.render(
                    self.camera,
                    transform.*,
                    material.*,
                    directionalLights.items[0],
                    pointLights.items(.transform),
                    pointLights.items(.light),
                );
            }
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

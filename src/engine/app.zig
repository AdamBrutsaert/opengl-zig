const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");
const Scene = @import("scene.zig").Scene;
const Event = @import("event.zig").Event;

const app_log = std.log.scoped(.glfw);

var glfw_initialized: bool = false;
var gl_initialized: bool = false;

var gl_proc_table: gl.ProcTable = undefined;
var app_count: usize = 0;
threadlocal var current_app: ?*App = null;

fn glfwErrorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
    app_log.err("{}: {s}\n", .{ error_code, description });
}

fn initGLFW() !void {
    if (glfw_initialized) return;

    glfw.setErrorCallback(glfwErrorCallback);

    if (!glfw.init(.{})) {
        app_log.err("failed to initialize GLFW: {?s}\n", .{glfw.getErrorString()});
        return error.GLFWInitFailed;
    }
    glfw_initialized = true;
}

fn deinitGLFW() void {
    if (!glfw_initialized or app_count > 0) return;

    glfw.terminate();
    glfw_initialized = false;
}

fn initGL() !void {
    if (gl_initialized) return;

    if (!gl_proc_table.init(glfw.getProcAddress)) {
        app_log.err("failed to load OpenGL functions\n", .{});
        return error.GLInitFailed;
    }

    gl.makeProcTableCurrent(&gl_proc_table);
    gl_initialized = true;
}

fn deinitGL() void {
    if (!gl_initialized or app_count > 0) return;

    gl.makeProcTableCurrent(null);
    gl_initialized = false;
}

pub const App = struct {
    window: glfw.Window,
    scene: Scene,
    fixedDeltaTime: f32,

    pub const Config = struct {
        title: [*:0]const u8,
        width: u32,
        height: u32,
        fixedDeltaTime: f32 = 1.0 / 60.0,
        scene: Scene,
    };

    fn framebuffer_size_callback(window: glfw.Window, width: u32, height: u32) void {
        _ = window;

        gl.Viewport(0, 0, @intCast(width), @intCast(height));
    }

    fn cursor_pos_callback(window: glfw.Window, x: f64, y: f64) void {
        const ptr = window.getUserPointer(App);

        if (ptr) |app| {
            app.scene.onEvent(app, .{
                .mouseMove = .{ .x = @as(f32, @floatCast(x)), .y = @as(f32, @floatCast(y)) },
            }) catch {};
        }
    }

    pub fn init(allocator: std.mem.Allocator, config: Config) !*App {
        try initGLFW();
        errdefer deinitGLFW();

        var app = try allocator.create(App);

        // Initialize window
        app.window = glfw.Window.create(config.width, config.height, config.title, null, null, .{
            .context_version_major = gl.info.version_major,
            .context_version_minor = gl.info.version_minor,
            .opengl_profile = .opengl_core_profile,
            .opengl_forward_compat = true,
        }) orelse {
            app_log.err("failed to init GLFW window: {?s}\n", .{glfw.getErrorString()});
            return error.GLFWWindowInitFailed;
        };
        errdefer app.window.destroy();

        glfw.makeContextCurrent(app.window);
        current_app = app;
        glfw.swapInterval(1);

        app.window.setUserPointer(app);
        app.window.setFramebufferSizeCallback(framebuffer_size_callback);
        app.window.setCursorPosCallback(cursor_pos_callback);

        // Initialize OpenGL now that we have a context
        try initGL();

        app.scene = config.scene;
        app.fixedDeltaTime = config.fixedDeltaTime;

        app_count += 1;
        return app;
    }

    pub fn deinit(self: *App, allocator: std.mem.Allocator) void {
        app_count -= 1;

        self.window.destroy();

        deinitGL();
        deinitGLFW();

        allocator.destroy(self);
    }

    pub fn run(self: *App) !void {
        var before = @as(f32, @floatCast(glfw.getTime()));
        var fixedDeltaAccumulator: f32 = 0.0;

        try self.scene.onEnter(self);

        while (!self.window.shouldClose()) {
            const now = @as(f32, @floatCast(glfw.getTime()));
            const delta = now - before;
            before = now;

            glfw.pollEvents();

            if (current_app != self) {
                glfw.makeContextCurrent(self.window);
                current_app = self;
            }

            gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

            fixedDeltaAccumulator += delta;
            while (fixedDeltaAccumulator >= self.fixedDeltaTime) {
                try self.scene.fixedUpdate(self, self.fixedDeltaTime);
                fixedDeltaAccumulator -= self.fixedDeltaTime;
            }
            try self.scene.update(self, delta);

            self.window.swapBuffers();
        }
    }
};

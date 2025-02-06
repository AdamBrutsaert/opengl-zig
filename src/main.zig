const std = @import("std");
const glfw = @import("mach-glfw");
const gl = @import("gl");
const zgl = @import("zgl.zig");

const glfw_log = std.log.scoped(.glfw);
const gl_log = std.log.scoped(.gl);

/// Procedure table that will hold loaded OpenGL functions.
var gl_procs: gl.ProcTable = undefined;

const Hexagon = struct {
    const Vertex = extern struct {
        const Position = [2]f32;
        const Color = [3]f32;

        position: Position,
        color: Color,
    };

    // zig fmt: off
    const vertices = [_]Vertex{
        .{ .position = .{  0    , -1   }, .color = .{ 0, 1, 1 } },
        .{ .position = .{ -0.866, -0.5 }, .color = .{ 0, 0, 1 } },
        .{ .position = .{  0.866, -0.5 }, .color = .{ 0, 1, 0 } },
        .{ .position = .{ -0.866,  0.5 }, .color = .{ 1, 0, 1 } },
        .{ .position = .{  0.866,  0.5 }, .color = .{ 1, 1, 0 } },
        .{ .position = .{  0    ,  1   }, .color = .{ 1, 0, 0 } },
    };
    // zig fmt: on

    const indices = [_]u8{
        0, 3, 1,
        0, 4, 3,
        0, 2, 4,
        3, 4, 5,
    };

    program: zgl.Program,
    vao: zgl.VertexArray,
    vbo: zgl.VertexBuffer,
    ibo: zgl.ElementBuffer,

    pub fn init(allocator: std.mem.Allocator) !Hexagon {
        const vertex_shader_source = try readFile(allocator, "shaders/hexagon.vert");
        const fragment_shader_source = try readFile(allocator, "shaders/hexagon.frag");
        defer allocator.free(vertex_shader_source);
        defer allocator.free(fragment_shader_source);

        var vertex_shader = try zgl.Shader.init(zgl.Shader.Kind.Vertex, vertex_shader_source);
        defer vertex_shader.deinit();

        var fragment_shader = try zgl.Shader.init(zgl.Shader.Kind.Fragment, fragment_shader_source);
        defer fragment_shader.deinit();

        const program = try zgl.Program.init(&[_]*const zgl.Shader{ &vertex_shader, &fragment_shader });
        var vao = try zgl.VertexArray.init();
        var vbo = try zgl.VertexBuffer.init();
        var ibo = try zgl.ElementBuffer.init();

        {
            // Make our VAO the current global VAO, but unbind it when we're done so we don't end up
            // inadvertently modifying it later.
            zgl.VertexArray.bind(&vao);
            defer zgl.VertexArray.unbind();

            {
                // Make our VBO the current global VBO and unbind it when we're done.
                zgl.VertexBuffer.bind(&vbo);
                defer zgl.VertexBuffer.unbind();

                // Upload vertex data to the VBO.
                gl.BufferData(
                    gl.ARRAY_BUFFER,
                    @sizeOf(@TypeOf(Hexagon.vertices)),
                    &Hexagon.vertices,
                    gl.STATIC_DRAW,
                );

                // Instruct the VAO how vertex position data is laid out in memory.
                const position_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Position"));
                gl.EnableVertexAttribArray(position_attrib);
                gl.VertexAttribPointer(
                    position_attrib,
                    @typeInfo(Hexagon.Vertex.Position).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(Hexagon.Vertex),
                    @offsetOf(Hexagon.Vertex, "position"),
                );

                // Ditto for vertex colors.
                const color_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Color"));
                gl.EnableVertexAttribArray(color_attrib);
                gl.VertexAttribPointer(
                    color_attrib,
                    @typeInfo(Hexagon.Vertex.Color).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(Hexagon.Vertex),
                    @offsetOf(Hexagon.Vertex, "color"),
                );
            }

            // Instruct the VAO to use our IBO, then upload index data to the IBO.
            zgl.ElementBuffer.bind(&ibo);
            gl.BufferData(
                gl.ELEMENT_ARRAY_BUFFER,
                @sizeOf(@TypeOf(Hexagon.indices)),
                &Hexagon.indices,
                gl.STATIC_DRAW,
            );
        }

        zgl.ElementBuffer.unbind();

        return Hexagon{
            .program = program,
            .vao = vao,
            .vbo = vbo,
            .ibo = ibo,
        };
    }

    pub fn deinit(self: *Hexagon) void {
        self.program.deinit();
        self.vao.deinit();
        self.vbo.deinit();
        self.ibo.deinit();
    }

    pub fn render(self: *const Hexagon, window: *glfw.Window, timer: *std.time.Timer) void {
        const framebuffer_size_uniform = gl.GetUniformLocation(self.program.id, "u_FramebufferSize");
        const angle_uniform = gl.GetUniformLocation(self.program.id, "u_Angle");

        zgl.Program.bind(&self.program);
        defer zgl.Program.unbind();

        // Make sure any changes to the window's size are reflected.
        const framebuffer_size = window.getFramebufferSize();
        gl.Viewport(0, 0, @intCast(framebuffer_size.width), @intCast(framebuffer_size.height));
        gl.Uniform2f(framebuffer_size_uniform, @floatFromInt(framebuffer_size.width), @floatFromInt(framebuffer_size.height));

        // Rotate the hexagon clockwise at a rate of one complete turn per minute.
        const seconds = @as(f32, @floatFromInt(timer.read())) / std.time.ns_per_s;
        gl.Uniform1f(angle_uniform, seconds / 60 * -std.math.tau);

        zgl.VertexArray.bind(&self.vao);
        defer zgl.VertexArray.unbind();

        // Draw the hexagon!
        gl.DrawElements(gl.TRIANGLES, Hexagon.indices.len, gl.UNSIGNED_BYTE, 0);
    }
};

fn readFile(allocator: std.mem.Allocator, path: []const u8) ![:0]u8 {
    var file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    var buffer = try allocator.allocSentinel(u8, stat.size, 0);

    _ = try file.readAll(buffer[0..stat.size]);
    return buffer;
}

const State = struct {
    window: glfw.Window,

    fn glfwErrorCallback(error_code: glfw.ErrorCode, description: [:0]const u8) void {
        glfw_log.err("{}: {s}\n", .{ error_code, description });
    }

    pub fn init() !State {
        glfw.setErrorCallback(glfwErrorCallback);

        if (!glfw.init(.{})) {
            glfw_log.err("failed to initialize GLFW: {?s}", .{glfw.getErrorString()});
            return error.GLFWInitFailed;
        }

        const window = glfw.Window.create(640, 480, "OpenGL in Zig!", null, null, .{
            .context_version_major = gl.info.version_major,
            .context_version_minor = gl.info.version_minor,
            .opengl_profile = .opengl_core_profile,
            .opengl_forward_compat = true,
        }) orelse {
            glfw_log.err("failed to init GLFW window: {?s}", .{glfw.getErrorString()});
            return error.initWindowFailed;
        };
        errdefer window.destroy();

        glfw.makeContextCurrent(window);
        glfw.swapInterval(1);

        if (!gl_procs.init(glfw.getProcAddress)) {
            gl_log.err("failed to load OpenGL functions", .{});
            return error.GLInitFailed;
        }
        gl.makeProcTableCurrent(&gl_procs);

        return State{ .window = window };
    }

    pub fn deinit(self: *State) void {
        glfw.makeContextCurrent(null);
        self.window.destroy();
        gl.makeProcTableCurrent(null);
        glfw.terminate();
    }

    pub fn run(self: *State) !void {
        var hexagon = try Hexagon.init(std.heap.page_allocator);
        defer hexagon.deinit();

        var timer = try std.time.Timer.start();

        gl.ClearColor(0.1, 0.1, 0.1, 1);
        gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE);

        while (!self.window.shouldClose()) {
            glfw.pollEvents();

            gl.Clear(gl.COLOR_BUFFER_BIT);
            hexagon.render(&self.window, &timer);

            self.window.swapBuffers();
        }
    }
};

pub fn main() !void {
    var state = try State.init();
    defer state.deinit();
    try state.run();
}

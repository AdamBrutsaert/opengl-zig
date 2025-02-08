const std = @import("std");
const gl = @import("gl");
const glfw = @import("mach-glfw");
const za = @import("zalgebra");
const zgl = @import("zgl.zig");
const Camera = @import("camera.zig").Camera;

fn readFile(allocator: std.mem.Allocator, path: []const u8) ![:0]u8 {
    var file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    var buffer = try allocator.allocSentinel(u8, stat.size, 0);

    _ = try file.readAll(buffer[0..stat.size]);
    return buffer;
}

pub const Container = struct {
    const Vertex = extern struct {
        const Position = [3]f32;
        const Color = [3]f32;
        const Tex = [2]f32;

        position: Position,
        color: Color,
        tex: Tex,
    };

    const vertices = [_]Vertex{
        .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 }, .tex = .{ 0.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 }, .tex = .{ 0.0, 0.0 } },

        .{ .position = .{ -0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 }, .tex = .{ 0.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 1.0, 0.5, 0.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 1.0, 0.5, 0.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ -0.5, 0.5, 0.5 }, .color = .{ 0.5, 0.0, 0.5 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ -0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 }, .tex = .{ 0.0, 0.0 } },

        .{ .position = .{ -0.5, 0.5, 0.5 }, .color = .{ 0.5, 0.0, 0.5 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ -0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 }, .tex = .{ 0.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, 0.5 }, .color = .{ 0.5, 0.0, 0.5 }, .tex = .{ 1.0, 0.0 } },

        .{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 1.0, 0.5, 0.0 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 }, .tex = .{ 0.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 1.0, 0.5, 0.0 }, .tex = .{ 1.0, 0.0 } },

        .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .color = .{ 0.0, 1.0, 0.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .color = .{ 0.0, 1.0, 1.0 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ -0.5, -0.5, 0.5 }, .color = .{ 1.0, 0.0, 1.0 }, .tex = .{ 0.0, 0.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .color = .{ 1.0, 0.0, 0.0 }, .tex = .{ 0.0, 1.0 } },

        .{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .color = .{ 0.0, 0.0, 1.0 }, .tex = .{ 1.0, 1.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 1.0, 0.5, 0.0 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .color = .{ 1.0, 0.5, 0.0 }, .tex = .{ 1.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, 0.5 }, .color = .{ 0.5, 0.0, 0.5 }, .tex = .{ 0.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, -0.5 }, .color = .{ 1.0, 1.0, 0.0 }, .tex = .{ 0.0, 1.0 } },
    };

    program: zgl.Program,
    texture: zgl.Texture2D,
    texture2: zgl.Texture2D,
    vao: zgl.VertexArray,
    vbo: zgl.VertexBuffer,

    pub fn init(allocator: std.mem.Allocator) !Container {
        const vertex_shader_source = try readFile(allocator, "shaders/container.vert");
        const fragment_shader_source = try readFile(allocator, "shaders/container.frag");
        defer allocator.free(vertex_shader_source);
        defer allocator.free(fragment_shader_source);

        var vertex_shader = try zgl.Shader.init(zgl.Shader.Kind.Vertex, vertex_shader_source);
        defer vertex_shader.deinit();

        var fragment_shader = try zgl.Shader.init(zgl.Shader.Kind.Fragment, fragment_shader_source);
        defer fragment_shader.deinit();

        var program = try zgl.Program.init(&[_]*const zgl.Shader{ &vertex_shader, &fragment_shader });
        errdefer program.deinit();

        var texture = try zgl.Texture2D.initRGB(allocator, "assets/container.png");
        errdefer texture.deinit();

        var texture2 = try zgl.Texture2D.initRGBA(allocator, "assets/awesomeface.png");
        errdefer texture2.deinit();

        var vao = try zgl.VertexArray.init();
        errdefer vao.deinit();

        var vbo = try zgl.VertexBuffer.init();
        errdefer vbo.deinit();

        {
            zgl.VertexArray.bind(&vao);
            defer zgl.VertexArray.unbind();

            {
                zgl.VertexBuffer.bind(&vbo);
                defer zgl.VertexBuffer.unbind();

                gl.BufferData(
                    gl.ARRAY_BUFFER,
                    @sizeOf(@TypeOf(Container.vertices)),
                    &Container.vertices,
                    gl.STATIC_DRAW,
                );

                const position_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Pos"));
                gl.EnableVertexAttribArray(position_attrib);
                gl.VertexAttribPointer(
                    position_attrib,
                    @typeInfo(Container.Vertex.Position).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(Container.Vertex),
                    @offsetOf(Container.Vertex, "position"),
                );

                const color_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Color"));
                gl.EnableVertexAttribArray(color_attrib);
                gl.VertexAttribPointer(
                    color_attrib,
                    @typeInfo(Container.Vertex.Color).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(Container.Vertex),
                    @offsetOf(Container.Vertex, "color"),
                );

                const tex_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Tex"));
                gl.EnableVertexAttribArray(tex_attrib);
                gl.VertexAttribPointer(
                    tex_attrib,
                    @typeInfo(Container.Vertex.Tex).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(Container.Vertex),
                    @offsetOf(Container.Vertex, "tex"),
                );
            }
        }

        return Container{
            .program = program,
            .texture = texture,
            .texture2 = texture2,
            .vao = vao,
            .vbo = vbo,
        };
    }

    pub fn deinit(self: *Container) void {
        self.program.deinit();
        self.texture.deinit();
        self.texture2.deinit();
        self.vao.deinit();
        self.vbo.deinit();
    }

    pub fn render(self: *const Container, camera: Camera, window: *glfw.Window, position: za.Vec3) void {
        const time: f32 = @floatCast(glfw.getTime());

        zgl.Program.bind(&self.program);
        defer zgl.Program.unbind();

        zgl.VertexArray.bind(&self.vao);
        defer zgl.VertexArray.unbind();

        zgl.Texture2D.bind(&self.texture, 0);
        defer zgl.Texture2D.unbind(0);

        zgl.Texture2D.bind(&self.texture2, 1);
        defer zgl.Texture2D.unbind(1);

        gl.Uniform1i(gl.GetUniformLocation(self.program.id, "u_Texture1"), 0);
        gl.Uniform1i(gl.GetUniformLocation(self.program.id, "u_Texture2"), 1);

        gl.Uniform1f(gl.GetUniformLocation(self.program.id, "u_Mix1"), std.math.cos(time));
        gl.Uniform1f(gl.GetUniformLocation(self.program.id, "u_Mix2"), std.math.sin(0.1 * time));

        const framebuffer_size = window.getFramebufferSize();

        const model = za.Mat4.fromTranslate(position).rotate(time * 50.0, za.Vec3.new(0.5, 1.0, 0.0));
        const view = camera.matrix();
        const projection = za.Mat4.perspective(45.0, @as(f32, @floatFromInt(framebuffer_size.width)) / @as(f32, @floatFromInt(framebuffer_size.height)), 0.1, 100.0);

        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Model"), 1, gl.FALSE, model.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_View"), 1, gl.FALSE, view.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Projection"), 1, gl.FALSE, projection.getData());

        gl.DrawArrays(gl.TRIANGLES, 0, Container.vertices.len);
    }
};

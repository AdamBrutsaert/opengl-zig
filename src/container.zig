const std = @import("std");
const gl = @import("gl");
const glfw = @import("mach-glfw");
const za = @import("zalgebra");
const zgl = @import("zgl.zig");
const utils = @import("utils.zig");
const Camera = @import("camera.zig").Camera;

pub const Container = struct {
    const Vertex = extern struct {
        const Position = [3]f32;
        const Tex = [2]f32;
        const Normal = [3]f32;

        position: Position,
        tex: Tex,
        normal: Normal,
    };

    const vertices = [_]Vertex{
        .{ .position = .{ -0.5, -0.5, -0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ 0.0, 0.0, -1.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 0.0, 0.0, -1.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ 0.0, 0.0, -1.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ 0.0, 0.0, -1.0 } },
        .{ .position = .{ -0.5, 0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 0.0, 0.0, -1.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ 0.0, 0.0, -1.0 } },

        .{ .position = .{ -0.5, -0.5, 0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ 0.0, 0.0, 1.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 0.0, 0.0, 1.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ 0.0, 0.0, 1.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ 0.0, 0.0, 1.0 } },
        .{ .position = .{ -0.5, 0.5, 0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 0.0, 0.0, 1.0 } },
        .{ .position = .{ -0.5, -0.5, 0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ 0.0, 0.0, 1.0 } },

        .{ .position = .{ -0.5, 0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ -1.0, 0.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, -0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ -1.0, 0.0, 0.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ -1.0, 0.0, 0.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ -1.0, 0.0, 0.0 } },
        .{ .position = .{ -0.5, -0.5, 0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ -1.0, 0.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ -1.0, 0.0, 0.0 } },

        .{ .position = .{ 0.5, 0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 1.0, 0.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ 1.0, 0.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 1.0, 0.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 1.0, 0.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ 1.0, 0.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 1.0, 0.0, 0.0 } },

        .{ .position = .{ -0.5, -0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 0.0, -1.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, -0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ 0.0, -1.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 0.0, -1.0, 0.0 } },
        .{ .position = .{ 0.5, -0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 0.0, -1.0, 0.0 } },
        .{ .position = .{ -0.5, -0.5, 0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ 0.0, -1.0, 0.0 } },
        .{ .position = .{ -0.5, -0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 0.0, -1.0, 0.0 } },

        .{ .position = .{ -0.5, 0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 0.0, 1.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, -0.5 }, .tex = .{ 1.0, 1.0 }, .normal = .{ 0.0, 1.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 0.0, 1.0, 0.0 } },
        .{ .position = .{ 0.5, 0.5, 0.5 }, .tex = .{ 1.0, 0.0 }, .normal = .{ 0.0, 1.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, 0.5 }, .tex = .{ 0.0, 0.0 }, .normal = .{ 0.0, 1.0, 0.0 } },
        .{ .position = .{ -0.5, 0.5, -0.5 }, .tex = .{ 0.0, 1.0 }, .normal = .{ 0.0, 1.0, 0.0 } },
    };

    program: zgl.Program,
    texture: zgl.Texture2D,
    vao: zgl.VertexArray,
    vbo: zgl.VertexBuffer,

    pub fn init(allocator: std.mem.Allocator) !Container {
        const vertex_shader_source = try utils.readFile(allocator, "shaders/container.vert");
        const fragment_shader_source = try utils.readFile(allocator, "shaders/container.frag");
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

                const normal_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Normal"));
                gl.EnableVertexAttribArray(normal_attrib);
                gl.VertexAttribPointer(
                    normal_attrib,
                    @typeInfo(Container.Vertex.Normal).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(Container.Vertex),
                    @offsetOf(Container.Vertex, "normal"),
                );
            }
        }

        return Container{
            .program = program,
            .texture = texture,
            .vao = vao,
            .vbo = vbo,
        };
    }

    pub fn deinit(self: *Container) void {
        self.program.deinit();
        self.texture.deinit();
        self.vao.deinit();
        self.vbo.deinit();
    }

    pub fn render(self: *const Container, camera: Camera, position: za.Vec3, light_position: za.Vec3) void {
        zgl.Program.bind(&self.program);
        defer zgl.Program.unbind();

        zgl.VertexArray.bind(&self.vao);
        defer zgl.VertexArray.unbind();

        zgl.Texture2D.bind(&self.texture, 0);
        defer zgl.Texture2D.unbind(0);

        gl.Uniform1i(gl.GetUniformLocation(self.program.id, "u_Texture"), 0);
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_ObjectColor"), 1.0, 0.5, 0.31);
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_LightColor"), 1.0, 1.0, 1.0);
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_LightPos"), light_position.x(), light_position.y(), light_position.z());

        const model = za.Mat4.fromTranslate(position);
        const view = camera.viewMatrix();
        const projection = camera.projectionMatrix();

        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Model"), 1, gl.FALSE, model.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_View"), 1, gl.FALSE, view.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Projection"), 1, gl.FALSE, projection.getData());

        gl.DrawArrays(gl.TRIANGLES, 0, Container.vertices.len);
    }
};

const std = @import("std");
const gl = @import("gl");
const glfw = @import("mach-glfw");
const za = @import("zalgebra");
const zgl = @import("zgl.zig");
const utils = @import("utils.zig");
const Camera = @import("camera.zig").Camera;

pub const Light = struct {
    const Vertex = extern struct {
        const Position = [3]f32;
        position: Position,
    };

    const vertices = [_]Vertex{
        .{ .position = .{ -0.5, -0.5, -0.5 } },
        .{ .position = .{ 0.5, -0.5, -0.5 } },
        .{ .position = .{ 0.5, 0.5, -0.5 } },
        .{ .position = .{ 0.5, 0.5, -0.5 } },
        .{ .position = .{ -0.5, 0.5, -0.5 } },
        .{ .position = .{ -0.5, -0.5, -0.5 } },

        .{ .position = .{ -0.5, -0.5, 0.5 } },
        .{ .position = .{ 0.5, -0.5, 0.5 } },
        .{ .position = .{ 0.5, 0.5, 0.5 } },
        .{ .position = .{ 0.5, 0.5, 0.5 } },
        .{ .position = .{ -0.5, 0.5, 0.5 } },
        .{ .position = .{ -0.5, -0.5, 0.5 } },

        .{ .position = .{ -0.5, 0.5, 0.5 } },
        .{ .position = .{ -0.5, 0.5, -0.5 } },
        .{ .position = .{ -0.5, -0.5, -0.5 } },
        .{ .position = .{ -0.5, -0.5, -0.5 } },
        .{ .position = .{ -0.5, -0.5, 0.5 } },
        .{ .position = .{ -0.5, 0.5, 0.5 } },

        .{ .position = .{ 0.5, 0.5, 0.5 } },
        .{ .position = .{ 0.5, 0.5, -0.5 } },
        .{ .position = .{ 0.5, -0.5, -0.5 } },
        .{ .position = .{ 0.5, -0.5, -0.5 } },
        .{ .position = .{ 0.5, -0.5, 0.5 } },
        .{ .position = .{ 0.5, 0.5, 0.5 } },

        .{ .position = .{ -0.5, -0.5, -0.5 } },
        .{ .position = .{ 0.5, -0.5, -0.5 } },
        .{ .position = .{ 0.5, -0.5, 0.5 } },
        .{ .position = .{ 0.5, -0.5, 0.5 } },
        .{ .position = .{ -0.5, -0.5, 0.5 } },
        .{ .position = .{ -0.5, -0.5, -0.5 } },

        .{ .position = .{ -0.5, 0.5, -0.5 } },
        .{ .position = .{ 0.5, 0.5, -0.5 } },
        .{ .position = .{ 0.5, 0.5, 0.5 } },
        .{ .position = .{ 0.5, 0.5, 0.5 } },
        .{ .position = .{ -0.5, 0.5, 0.5 } },
        .{ .position = .{ -0.5, 0.5, -0.5 } },
    };

    program: zgl.Program,
    vao: zgl.VertexArray,
    vbo: zgl.VertexBuffer,

    pub fn init(allocator: std.mem.Allocator) !Light {
        const vertex_shader_source = try utils.readFile(allocator, "shaders/light.vert");
        const fragment_shader_source = try utils.readFile(allocator, "shaders/light.frag");
        defer allocator.free(vertex_shader_source);
        defer allocator.free(fragment_shader_source);

        var vertex_shader = try zgl.Shader.init(zgl.Shader.Kind.Vertex, vertex_shader_source);
        defer vertex_shader.deinit();

        var fragment_shader = try zgl.Shader.init(zgl.Shader.Kind.Fragment, fragment_shader_source);
        defer fragment_shader.deinit();

        var program = try zgl.Program.init(&[_]*const zgl.Shader{ &vertex_shader, &fragment_shader });
        errdefer program.deinit();

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
                    @sizeOf(@TypeOf(Light.vertices)),
                    &Light.vertices,
                    gl.STATIC_DRAW,
                );

                const position_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Pos"));
                gl.EnableVertexAttribArray(position_attrib);
                gl.VertexAttribPointer(
                    position_attrib,
                    @typeInfo(Light.Vertex.Position).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(Light.Vertex),
                    @offsetOf(Light.Vertex, "position"),
                );
            }
        }

        return Light{
            .program = program,
            .vao = vao,
            .vbo = vbo,
        };
    }

    pub fn deinit(self: *Light) void {
        self.program.deinit();
        self.vao.deinit();
        self.vbo.deinit();
    }

    pub fn render(self: *const Light, camera: Camera, position: za.Vec3) void {
        zgl.Program.bind(&self.program);
        defer zgl.Program.unbind();

        zgl.VertexArray.bind(&self.vao);
        defer zgl.VertexArray.unbind();

        const model = za.Mat4.fromScale(za.Vec3.new(0.2, 0.2, 0.2)).translate(position);
        const view = camera.viewMatrix();
        const projection = camera.projectionMatrix();

        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Model"), 1, gl.FALSE, model.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_View"), 1, gl.FALSE, view.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Projection"), 1, gl.FALSE, projection.getData());

        gl.DrawArrays(gl.TRIANGLES, 0, Light.vertices.len);
    }
};

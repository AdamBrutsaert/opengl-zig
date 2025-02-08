const std = @import("std");
const gl = @import("gl");
const glfw = @import("mach-glfw");
const za = @import("zalgebra");
const zgl = @import("zgl.zig");
const utils = @import("utils.zig");
const Camera = @import("camera.zig").Camera;

pub const LightMesh = struct {
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

    pub fn init(allocator: std.mem.Allocator) !LightMesh {
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
                    @sizeOf(@TypeOf(LightMesh.vertices)),
                    &LightMesh.vertices,
                    gl.STATIC_DRAW,
                );

                const position_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Pos"));
                gl.EnableVertexAttribArray(position_attrib);
                gl.VertexAttribPointer(
                    position_attrib,
                    @typeInfo(LightMesh.Vertex.Position).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(LightMesh.Vertex),
                    @offsetOf(LightMesh.Vertex, "position"),
                );
            }
        }

        return LightMesh{
            .program = program,
            .vao = vao,
            .vbo = vbo,
        };
    }

    pub fn deinit(self: *LightMesh) void {
        self.program.deinit();
        self.vao.deinit();
        self.vbo.deinit();
    }
};

pub const Light = struct {
    mesh: *LightMesh,
    position: za.Vec3,
    ambient: za.Vec3,
    diffuse: za.Vec3,
    specular: za.Vec3,

    pub fn render(self: *const Light, camera: Camera) void {
        zgl.Program.bind(&self.mesh.program);
        defer zgl.Program.unbind();

        zgl.VertexArray.bind(&self.mesh.vao);
        defer zgl.VertexArray.unbind();

        const model = za.Mat4.fromScale(za.Vec3.new(0.2, 0.2, 0.2)).translate(self.position);
        const view = camera.viewMatrix();
        const projection = camera.projectionMatrix();

        gl.UniformMatrix4fv(gl.GetUniformLocation(self.mesh.program.id, "u_Model"), 1, gl.FALSE, model.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.mesh.program.id, "u_View"), 1, gl.FALSE, view.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.mesh.program.id, "u_Projection"), 1, gl.FALSE, projection.getData());

        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_Color"), self.diffuse.x(), self.diffuse.y(), self.diffuse.z());

        gl.DrawArrays(gl.TRIANGLES, 0, LightMesh.vertices.len);
    }
};

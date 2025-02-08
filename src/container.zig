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
        const time: f32 = @floatCast(glfw.getTime());

        zgl.Program.bind(&self.program);
        defer zgl.Program.unbind();

        zgl.VertexArray.bind(&self.vao);
        defer zgl.VertexArray.unbind();

        zgl.Texture2D.bind(&self.texture, 0);
        defer zgl.Texture2D.unbind(0);

        const model = za.Mat4.fromTranslate(position);
        const view = camera.viewMatrix();
        const projection = camera.projectionMatrix();

        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Model"), 1, gl.FALSE, model.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_View"), 1, gl.FALSE, view.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.program.id, "u_Projection"), 1, gl.FALSE, projection.getData());

        gl.Uniform1i(gl.GetUniformLocation(self.program.id, "u_Texture"), 0);

        const view_light_pos = view.mulByVec4(light_position.toVec4(1.0)).toVec3();
        const light_color = za.Vec3.new(std.math.sin(time * 2.0), std.math.sin(time * 0.7), std.math.sin(time * 1.3));
        const diffuse_color = light_color.scale(0.5);
        const ambient_color = diffuse_color.scale(0.2);

        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_Light.position"), view_light_pos.x(), view_light_pos.y(), view_light_pos.z());
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_Light.ambient"), ambient_color.x(), ambient_color.y(), ambient_color.z());
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_Light.diffuse"), diffuse_color.x(), diffuse_color.y(), diffuse_color.z());
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_Light.specular"), 1.0, 1.0, 1.0);

        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_Material.ambient"), 1.0, 0.5, 0.31);
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_Material.diffuse"), 1.0, 0.5, 0.31);
        gl.Uniform3f(gl.GetUniformLocation(self.program.id, "u_Material.specular"), 0.5, 0.5, 0.5);
        gl.Uniform1f(gl.GetUniformLocation(self.program.id, "u_Material.shininess"), 32.0);

        gl.DrawArrays(gl.TRIANGLES, 0, Container.vertices.len);
    }
};

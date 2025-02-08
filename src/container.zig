const std = @import("std");
const gl = @import("gl");
const glfw = @import("mach-glfw");
const za = @import("zalgebra");
const zgl = @import("zgl.zig");
const utils = @import("utils.zig");
const Camera = @import("camera.zig").Camera;
const light = @import("light.zig");

pub const ContainerMesh = struct {
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
    diffuse_texture: zgl.Texture2D,
    specular_texture: zgl.Texture2D,
    vao: zgl.VertexArray,
    vbo: zgl.VertexBuffer,

    pub fn init(allocator: std.mem.Allocator) !ContainerMesh {
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

        var diffuse_texture = try zgl.Texture2D.initRGBA(allocator, "assets/container2.png");
        errdefer diffuse_texture.deinit();

        var specular_texture = try zgl.Texture2D.initRGBA(allocator, "assets/container2_specular.png");
        errdefer specular_texture.deinit();

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
                    @sizeOf(@TypeOf(ContainerMesh.vertices)),
                    &ContainerMesh.vertices,
                    gl.STATIC_DRAW,
                );

                const position_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Pos"));
                gl.EnableVertexAttribArray(position_attrib);
                gl.VertexAttribPointer(
                    position_attrib,
                    @typeInfo(ContainerMesh.Vertex.Position).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(ContainerMesh.Vertex),
                    @offsetOf(ContainerMesh.Vertex, "position"),
                );

                const tex_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Tex"));
                gl.EnableVertexAttribArray(tex_attrib);
                gl.VertexAttribPointer(
                    tex_attrib,
                    @typeInfo(ContainerMesh.Vertex.Tex).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(ContainerMesh.Vertex),
                    @offsetOf(ContainerMesh.Vertex, "tex"),
                );

                const normal_attrib: c_uint = @intCast(gl.GetAttribLocation(program.id, "a_Normal"));
                gl.EnableVertexAttribArray(normal_attrib);
                gl.VertexAttribPointer(
                    normal_attrib,
                    @typeInfo(ContainerMesh.Vertex.Normal).array.len,
                    gl.FLOAT,
                    gl.FALSE,
                    @sizeOf(ContainerMesh.Vertex),
                    @offsetOf(ContainerMesh.Vertex, "normal"),
                );
            }
        }

        return ContainerMesh{
            .program = program,
            .diffuse_texture = diffuse_texture,
            .specular_texture = specular_texture,
            .vao = vao,
            .vbo = vbo,
        };
    }

    pub fn deinit(self: *ContainerMesh) void {
        self.program.deinit();
        self.diffuse_texture.deinit();
        self.specular_texture.deinit();
        self.vao.deinit();
        self.vbo.deinit();
    }
};

pub const Container = struct {
    mesh: *ContainerMesh,
    position: za.Vec3,
    ambient: za.Vec3,
    diffuse: za.Vec3,
    specular: za.Vec3,
    shininess: f32,

    pub fn render(self: *const Container, camera: Camera, directionalLight: light.DirectionalLight, pointLights: [4]light.PointLight) void {
        zgl.Program.bind(&self.mesh.program);
        defer zgl.Program.unbind();

        zgl.VertexArray.bind(&self.mesh.vao);
        defer zgl.VertexArray.unbind();

        zgl.Texture2D.bind(&self.mesh.diffuse_texture, 0);
        defer zgl.Texture2D.unbind(0);

        zgl.Texture2D.bind(&self.mesh.specular_texture, 1);
        defer zgl.Texture2D.unbind(1);

        const model = za.Mat4.fromTranslate(self.position);
        const view = camera.viewMatrix();
        const projection = camera.projectionMatrix();

        gl.UniformMatrix4fv(gl.GetUniformLocation(self.mesh.program.id, "u_Model"), 1, gl.FALSE, model.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.mesh.program.id, "u_View"), 1, gl.FALSE, view.getData());
        gl.UniformMatrix4fv(gl.GetUniformLocation(self.mesh.program.id, "u_Projection"), 1, gl.FALSE, projection.getData());

        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_DirectionalLight.direction"), directionalLight.direction.x(), directionalLight.direction.y(), directionalLight.direction.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_DirectionalLight.ambient"), directionalLight.ambient.x(), directionalLight.ambient.y(), directionalLight.ambient.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_DirectionalLight.diffuse"), directionalLight.diffuse.x(), directionalLight.diffuse.y(), directionalLight.diffuse.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_DirectionalLight.specular"), directionalLight.specular.x(), directionalLight.specular.y(), directionalLight.specular.z());

        var view_light_pos = view.mulByVec4(pointLights[0].position.toVec4(1.0)).toVec3();
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[0].position"), view_light_pos.x(), view_light_pos.y(), view_light_pos.z());
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[0].constant"), pointLights[0].constant);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[0].linear"), pointLights[0].linear);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[0].quadratic"), pointLights[0].quadratic);
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[0].ambient"), pointLights[0].ambient.x(), pointLights[0].ambient.y(), pointLights[0].ambient.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[0].diffuse"), pointLights[0].diffuse.x(), pointLights[0].diffuse.y(), pointLights[0].diffuse.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[0].specular"), pointLights[0].specular.x(), pointLights[0].specular.y(), pointLights[0].specular.z());

        view_light_pos = view.mulByVec4(pointLights[1].position.toVec4(1.0)).toVec3();
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[1].position"), view_light_pos.x(), view_light_pos.y(), view_light_pos.z());
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[1].constant"), pointLights[1].constant);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[1].linear"), pointLights[1].linear);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[1].quadratic"), pointLights[1].quadratic);
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[1].ambient"), pointLights[1].ambient.x(), pointLights[1].ambient.y(), pointLights[1].ambient.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[1].diffuse"), pointLights[1].diffuse.x(), pointLights[1].diffuse.y(), pointLights[1].diffuse.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[1].specular"), pointLights[1].specular.x(), pointLights[1].specular.y(), pointLights[1].specular.z());

        view_light_pos = view.mulByVec4(pointLights[2].position.toVec4(1.0)).toVec3();
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[2].position"), view_light_pos.x(), view_light_pos.y(), view_light_pos.z());
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[2].constant"), pointLights[2].constant);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[2].linear"), pointLights[2].linear);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[2].quadratic"), pointLights[2].quadratic);
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[2].ambient"), pointLights[2].ambient.x(), pointLights[2].ambient.y(), pointLights[2].ambient.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[2].diffuse"), pointLights[2].diffuse.x(), pointLights[2].diffuse.y(), pointLights[2].diffuse.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[2].specular"), pointLights[2].specular.x(), pointLights[2].specular.y(), pointLights[2].specular.z());

        view_light_pos = view.mulByVec4(pointLights[3].position.toVec4(1.0)).toVec3();
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[3].position"), view_light_pos.x(), view_light_pos.y(), view_light_pos.z());
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[3].constant"), pointLights[3].constant);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[3].linear"), pointLights[3].linear);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[3].quadratic"), pointLights[3].quadratic);
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[3].ambient"), pointLights[3].ambient.x(), pointLights[3].ambient.y(), pointLights[3].ambient.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[3].diffuse"), pointLights[3].diffuse.x(), pointLights[3].diffuse.y(), pointLights[3].diffuse.z());
        gl.Uniform3f(gl.GetUniformLocation(self.mesh.program.id, "u_PointLights[3].specular"), pointLights[3].specular.x(), pointLights[3].specular.y(), pointLights[3].specular.z());

        gl.Uniform1i(gl.GetUniformLocation(self.mesh.program.id, "u_Material.diffuse"), 0);
        gl.Uniform1i(gl.GetUniformLocation(self.mesh.program.id, "u_Material.specular"), 1);
        gl.Uniform1f(gl.GetUniformLocation(self.mesh.program.id, "u_Material.shininess"), self.shininess);

        gl.DrawArrays(gl.TRIANGLES, 0, ContainerMesh.vertices.len);
    }
};

const std = @import("std");
const gl = @import("gl");

const gl_log = std.log.scoped(.gl);

pub const Shader = struct {
    id: c_uint,

    pub const Kind = enum(u16) {
        Vertex = gl.VERTEX_SHADER,
        Fragment = gl.FRAGMENT_SHADER,
    };

    pub fn create(kind: Kind, source: [:0]const u8) !Shader {
        const id = gl.CreateShader(@intFromEnum(kind));
        if (id == 0) return error.CreateShaderFailed;

        gl.ShaderSource(id, 1, (&source.ptr)[0..1], (&@as(c_int, @intCast(source.len)))[0..1]);
        gl.CompileShader(id);

        var success: c_int = undefined;
        gl.GetShaderiv(id, gl.COMPILE_STATUS, &success);
        if (success == gl.FALSE) {
            var info_log_buf: [512:0]u8 = undefined;
            gl.GetShaderInfoLog(id, info_log_buf.len, null, &info_log_buf);
            gl_log.err("{s}", .{std.mem.sliceTo(&info_log_buf, 0)});
            gl.DeleteShader(id);
            return error.CompileShaderFailed;
        }

        return Shader{ .id = id };
    }

    pub fn destroy(self: *Shader) void {
        gl.DeleteShader(self.id);
    }
};

pub const Program = struct {
    id: c_uint,

    pub fn create(vertex: *const Shader, fragment: *const Shader) !Program {
        const id = gl.CreateProgram();
        if (id == 0) return error.CreateProgramFailed;

        gl.AttachShader(id, vertex.id);
        gl.AttachShader(id, fragment.id);
        gl.LinkProgram(id);

        var success: c_int = undefined;
        gl.GetProgramiv(id, gl.LINK_STATUS, &success);
        if (success == gl.FALSE) {
            var info_log_buf: [512:0]u8 = undefined;
            gl.GetProgramInfoLog(id, info_log_buf.len, null, &info_log_buf);
            gl_log.err("{s}", .{std.mem.sliceTo(&info_log_buf, 0)});
            gl.DeleteProgram(id);
            return error.LinkProgramFailed;
        }

        return Program{ .id = id };
    }

    pub fn destroy(self: *Program) void {
        gl.DeleteProgram(self.id);
    }

    pub fn bind(self: *const Program) void {
        gl.UseProgram(self.id);
    }

    pub fn unbind() void {
        gl.UseProgram(0);
    }
};

pub const VertexArray = struct {
    id: c_uint,

    pub fn create() !VertexArray {
        var id: c_uint = undefined;
        gl.GenVertexArrays(1, (&id)[0..1]);
        if (id == 0) return error.CreateVertexArrayFailed;

        return VertexArray{ .id = id };
    }

    pub fn destroy(self: *VertexArray) void {
        gl.DeleteVertexArrays(1, (&self.id)[0..1]);
    }

    pub fn bind(self: *const VertexArray) void {
        gl.BindVertexArray(self.id);
    }

    pub fn unbind() void {
        gl.BindVertexArray(0);
    }
};

pub const VertexBuffer = struct {
    id: c_uint,

    pub fn create() !VertexBuffer {
        var id: c_uint = undefined;
        gl.GenBuffers(1, (&id)[0..1]);
        if (id == 0) return error.CreateVertexBufferFailed;

        return VertexBuffer{ .id = id };
    }

    pub fn destroy(self: *VertexBuffer) void {
        gl.DeleteBuffers(1, (&self.id)[0..1]);
    }

    pub fn bind(self: *const VertexBuffer) void {
        gl.BindBuffer(gl.ARRAY_BUFFER, self.id);
    }

    pub fn unbind() void {
        gl.BindBuffer(gl.ARRAY_BUFFER, 0);
    }
};

pub const ElementBuffer = struct {
    id: c_uint,

    pub fn create() !ElementBuffer {
        var id: c_uint = undefined;
        gl.GenBuffers(1, (&id)[0..1]);
        if (id == 0) return error.CreateIndexBufferFailed;

        return ElementBuffer{ .id = id };
    }

    pub fn destroy(self: *ElementBuffer) void {
        gl.DeleteBuffers(1, (&self.id)[0..1]);
    }

    pub fn bind(self: *const ElementBuffer) void {
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
    }

    pub fn unbind() void {
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }
};

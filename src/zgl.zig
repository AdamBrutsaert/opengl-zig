const std = @import("std");
const gl = @import("gl");
const img = @import("zigimg");

const gl_log = std.log.scoped(.gl);

pub const Shader = struct {
    id: c_uint,

    pub const Kind = enum(u16) {
        Vertex = gl.VERTEX_SHADER,
        Fragment = gl.FRAGMENT_SHADER,
    };

    pub fn init(kind: Kind, source: [:0]const u8) !Shader {
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

    pub fn deinit(self: *Shader) void {
        gl.DeleteShader(self.id);
    }
};

pub const Program = struct {
    id: c_uint,

    pub fn init(shaders: []const *const Shader) !Program {
        const id = gl.CreateProgram();
        if (id == 0) return error.CreateProgramFailed;

        for (shaders) |shader| {
            gl.AttachShader(id, shader.id);
        }
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

    pub fn deinit(self: *Program) void {
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

    pub fn init() !VertexArray {
        var id: c_uint = undefined;
        gl.GenVertexArrays(1, (&id)[0..1]);
        if (id == 0) return error.CreateVertexArrayFailed;

        return VertexArray{ .id = id };
    }

    pub fn deinit(self: *VertexArray) void {
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

    pub fn init() !VertexBuffer {
        var id: c_uint = undefined;
        gl.GenBuffers(1, (&id)[0..1]);
        if (id == 0) return error.CreateVertexBufferFailed;

        return VertexBuffer{ .id = id };
    }

    pub fn deinit(self: *VertexBuffer) void {
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

    pub fn init() !ElementBuffer {
        var id: c_uint = undefined;
        gl.GenBuffers(1, (&id)[0..1]);
        if (id == 0) return error.CreateIndexBufferFailed;

        return ElementBuffer{ .id = id };
    }

    pub fn deinit(self: *ElementBuffer) void {
        gl.DeleteBuffers(1, (&self.id)[0..1]);
    }

    pub fn bind(self: *const ElementBuffer) void {
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.id);
    }

    pub fn unbind() void {
        gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, 0);
    }
};

pub const Texture2D = struct {
    id: c_uint,

    pub fn initRGB(allocator: std.mem.Allocator, path: []const u8) !Texture2D {
        var id: c_uint = undefined;
        gl.GenTextures(1, (&id)[0..1]);
        if (id == 0) return error.CreateTextureFailed;
        errdefer gl.DeleteTextures(1, (&id)[0..1]);

        var image = try img.Image.fromFilePath(allocator, path);
        defer image.deinit();

        gl.BindTexture(gl.TEXTURE_2D, id);
        defer gl.BindTexture(gl.TEXTURE_2D, 0);

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        const width: c_int = @intCast(image.width);
        const height: c_int = @intCast(image.height);

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGB, gl.UNSIGNED_BYTE, image.rawBytes().ptr);
        gl.GenerateMipmap(gl.TEXTURE_2D);

        return Texture2D{ .id = id };
    }

    pub fn initRGBA(allocator: std.mem.Allocator, path: []const u8) !Texture2D {
        var id: c_uint = undefined;
        gl.GenTextures(1, (&id)[0..1]);
        if (id == 0) return error.CreateTextureFailed;
        errdefer gl.DeleteTextures(1, (&id)[0..1]);

        var image = try img.Image.fromFilePath(allocator, path);
        defer image.deinit();

        gl.BindTexture(gl.TEXTURE_2D, id);
        defer gl.BindTexture(gl.TEXTURE_2D, 0);

        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_S, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_WRAP_T, gl.REPEAT);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MIN_FILTER, gl.LINEAR_MIPMAP_LINEAR);
        gl.TexParameteri(gl.TEXTURE_2D, gl.TEXTURE_MAG_FILTER, gl.LINEAR);

        const width: c_int = @intCast(image.width);
        const height: c_int = @intCast(image.height);

        gl.TexImage2D(gl.TEXTURE_2D, 0, gl.RGB, width, height, 0, gl.RGBA, gl.UNSIGNED_BYTE, image.rawBytes().ptr);
        gl.GenerateMipmap(gl.TEXTURE_2D);

        return Texture2D{ .id = id };
    }

    pub fn deinit(self: *Texture2D) void {
        gl.DeleteTextures(1, (&self.id)[0..1]);
    }

    pub fn bind(self: *const Texture2D, slot: c_uint) void {
        gl.ActiveTexture(gl.TEXTURE0 + slot);
        gl.BindTexture(gl.TEXTURE_2D, self.id);
    }

    pub fn unbind(slot: c_uint) void {
        gl.ActiveTexture(gl.TEXTURE0 + slot);
        gl.BindTexture(gl.TEXTURE_2D, 0);
    }
};

const App = @import("app.zig").App;

pub const Scene = struct {
    ptr: *anyopaque,
    updateFn: *const fn (ptr: *anyopaque, app: *App, delta: f32) anyerror!void,

    pub fn init(ptr: anytype) Scene {
        const T = @TypeOf(ptr);
        const ptr_info = @typeInfo(T);

        if (ptr_info != .pointer) @compileError("ptr must be a pointer");
        if (ptr_info.pointer.size != .one) @compileError("ptr must be a pointer to a single value");

        const gen = struct {
            pub fn update(pointer: *anyopaque, app: *App, delta: f32) anyerror!void {
                const self: T = @ptrCast(@alignCast(pointer));
                return @call(.auto, ptr_info.pointer.child.update, .{ self, app, delta });
            }
        };

        return .{
            .ptr = ptr,
            .updateFn = gen.update,
        };
    }

    pub fn update(self: *Scene, app: *App, delta: f32) !void {
        return self.updateFn(self.ptr, app, delta);
    }
};

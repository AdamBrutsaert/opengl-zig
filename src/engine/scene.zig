const App = @import("app.zig").App;

pub const Scene = struct {
    ptr: *anyopaque,

    fixedUpdateFn: *const fn (ptr: *anyopaque, app: *App, fixedDeltaTime: f32) anyerror!void,
    updateFn: *const fn (ptr: *anyopaque, app: *App, deltaTime: f32) anyerror!void,

    pub fn init(ptr: anytype) Scene {
        const T = @TypeOf(ptr);
        const ptr_info = @typeInfo(T);

        if (ptr_info != .pointer) @compileError("ptr must be a pointer");
        if (ptr_info.pointer.size != .one) @compileError("ptr must be a pointer to a single value");

        const gen = struct {
            pub fn fixedUpdate(pointer: *anyopaque, app: *App, fixedDeltaTime: f32) anyerror!void {
                const self: T = @ptrCast(@alignCast(pointer));
                return @call(.auto, ptr_info.pointer.child.fixedUpdate, .{ self, app, fixedDeltaTime });
            }

            pub fn update(pointer: *anyopaque, app: *App, deltaTime: f32) anyerror!void {
                const self: T = @ptrCast(@alignCast(pointer));
                return @call(.auto, ptr_info.pointer.child.update, .{ self, app, deltaTime });
            }
        };

        return .{
            .ptr = ptr,
            .fixedUpdateFn = gen.fixedUpdate,
            .updateFn = gen.update,
        };
    }

    pub fn fixedUpdate(self: *Scene, app: *App, fixedDeltaTime: f32) !void {
        return self.fixedUpdateFn(self.ptr, app, fixedDeltaTime);
    }

    pub fn update(self: *Scene, app: *App, deltaTime: f32) !void {
        return self.updateFn(self.ptr, app, deltaTime);
    }
};

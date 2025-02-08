const App = @import("app.zig").App;
const Event = @import("event.zig").Event;

pub const Scene = struct {
    ptr: *anyopaque,

    onEnterFn: *const fn (ptr: *anyopaque, app: *App) anyerror!void,
    onEventFn: *const fn (ptr: *anyopaque, app: *App, event: Event) anyerror!void,
    fixedUpdateFn: *const fn (ptr: *anyopaque, app: *App, fixedDeltaTime: f32) anyerror!void,
    updateFn: *const fn (ptr: *anyopaque, app: *App, deltaTime: f32) anyerror!void,

    pub fn init(ptr: anytype) Scene {
        const T = @TypeOf(ptr);
        const ptr_info = @typeInfo(T);

        if (ptr_info != .pointer) @compileError("ptr must be a pointer");
        if (ptr_info.pointer.size != .one) @compileError("ptr must be a pointer to a single value");

        const gen = struct {
            pub fn onEnter(pointer: *anyopaque, app: *App) anyerror!void {
                const self: T = @ptrCast(@alignCast(pointer));
                return @call(.auto, ptr_info.pointer.child.onEnter, .{ self, app });
            }

            pub fn onEvent(pointer: *anyopaque, app: *App, event: Event) anyerror!void {
                const self: T = @ptrCast(@alignCast(pointer));
                return @call(.auto, ptr_info.pointer.child.onEvent, .{ self, app, event });
            }

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
            .onEnterFn = gen.onEnter,
            .onEventFn = gen.onEvent,
            .fixedUpdateFn = gen.fixedUpdate,
            .updateFn = gen.update,
        };
    }

    pub fn onEnter(self: *Scene, app: *App) !void {
        return self.onEnterFn(self.ptr, app);
    }

    pub fn onEvent(self: *Scene, app: *App, event: Event) !void {
        return self.onEventFn(self.ptr, app, event);
    }

    pub fn fixedUpdate(self: *Scene, app: *App, fixedDeltaTime: f32) !void {
        return self.fixedUpdateFn(self.ptr, app, fixedDeltaTime);
    }

    pub fn update(self: *Scene, app: *App, deltaTime: f32) !void {
        return self.updateFn(self.ptr, app, deltaTime);
    }
};

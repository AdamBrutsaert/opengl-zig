const glfw = @import("mach-glfw");

pub const Event = union(enum) {
    mouseMove: struct { x: f32, y: f32 },
    key: struct { key: glfw.Key, scancode: i32, action: glfw.Action, mods: glfw.Mods },
};

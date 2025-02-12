const za = @import("zalgebra");

pub const Transform = struct {
    position: za.Vec3,
};

pub const Material = struct {
    ambient: za.Vec3,
    diffuse: za.Vec3,
    specular: za.Vec3,
    shininess: f32,
};

pub const Container = struct {};

pub const PointLight = struct {
    constant: f32,
    linear: f32,
    quadratic: f32,
    ambient: za.Vec3,
    diffuse: za.Vec3,
    specular: za.Vec3,
};

pub const DirectionalLight = struct {
    direction: za.Vec3,
    ambient: za.Vec3,
    diffuse: za.Vec3,
    specular: za.Vec3,
};

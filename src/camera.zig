const std = @import("std");
const za = @import("zalgebra");

pub const Camera = struct {
    position: za.Vec3,
    front: za.Vec3,
    up: za.Vec3,

    yaw: f32,
    pitch: f32,

    pub fn init() Camera {
        return Camera{
            .position = za.Vec3.new(0.0, 0.0, 3.0),
            .front = za.Vec3.new(0.0, 0.0, -1.0),
            .up = za.Vec3.new(0.0, 1.0, 0.0),
            .yaw = -90.0,
            .pitch = 0.0,
        };
    }

    pub fn move(self: *Camera, forward: f32, right: f32, up: f32) void {
        self.position = self.position.add(self.front.scale(forward).add(self.front.cross(self.up).norm().scale(right)).add(self.up.scale(up)));
    }

    pub fn turn(self: *Camera, yaw_: f32, pitch_: f32) void {
        self.yaw += yaw_;
        self.pitch += pitch_;

        if (self.pitch > 89.0) {
            self.pitch = 89.0;
        } else if (self.pitch < -89.0) {
            self.pitch = -89.0;
        }

        self.front = za.Vec3.new(
            std.math.cos(std.math.degreesToRadians(self.yaw)) * std.math.cos(std.math.degreesToRadians(self.pitch)),
            std.math.sin(std.math.degreesToRadians(self.pitch)),
            std.math.sin(std.math.degreesToRadians(self.yaw)) * std.math.cos(std.math.degreesToRadians(self.pitch)),
        ).norm();
    }

    pub fn matrix(self: Camera) za.Mat4 {
        return za.Mat4.lookAt(self.position, self.position.add(self.front), self.up);
    }
};

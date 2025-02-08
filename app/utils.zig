const std = @import("std");

pub fn readFile(allocator: std.mem.Allocator, path: []const u8) ![:0]u8 {
    var file = try std.fs.cwd().openFile(path, .{ .mode = .read_only });
    defer file.close();

    const stat = try file.stat();
    var buffer = try allocator.allocSentinel(u8, stat.size, 0);

    _ = try file.readAll(buffer[0..stat.size]);
    return buffer;
}

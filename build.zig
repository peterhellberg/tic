const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b.addModule("tic", .{ .source_file = .{
        .path = "src/tic80.zig",
    } });
}

const std = @import("std");
pub fn main() anyerror!void {
    const stdout = std.io.getStdOut().writer();
    const image_width: u16 = 256;
    const image_height: u16 = 256;
    try stdout.print("P3\n{d} {d}\n255\n", .{ image_width, image_height });
    var j: i16 = 0;
    while (j <= image_height - 1) : (j += 1) {
        var i: i16 = 0;
        while (i < image_width) : (i += 1) {
            const r = @as(f64, @floatFromInt(i)) / @as(f64, @floatFromInt(image_width - 1));
            const g = @as(f64, @floatFromInt(j)) / @as(f64, @floatFromInt(image_height - 1));
            const b = 0.0;
            const ir = @as(u16, @intFromFloat(255.999 * r));
            const ig = @as(u16, @intFromFloat(255.999 * g));
            const ib = @as(u16, @intFromFloat(255.999 * b));
            try stdout.print("{d} {d} {d}\n", .{ ir, ig, ib });
        }
    }
}

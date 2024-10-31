const std = @import("std");

pub const RGB = packed struct {
    r: u8,
    g: u8,
    b: u8,
};

// Define ppm image structure
pub const Image = struct {
    width: u64,
    height: u64,
    data: []RGB,

    // allocator for the rgb values depending on width and height
    allocator: std.mem.Allocator,

    // return a base image with memory allocated for the certain width and height
    pub fn init(allocator: std.mem.Allocator, width: u64, height: u64) !Image {
        return Image{
            .width = width,
            .height = height,
            .data = try allocator.alloc(RGB, width * height),
            .allocator = allocator,
        };
    }

    // free the data allocated for the RGB values
    pub fn deinit(self: *Image) void {
        self.allocator.free(self.data);
    }

    // make a bufferedWriter to then add all the values to and write to file all in one go
    pub fn writeToFile(self: *Image, filename: []const u8) !void {
        const file = try std.fs.cwd().createFile(filename, .{ .truncate = true });
        defer file.close();

        const fwriter = file.writer();
        var bufwriter = std.io.bufferedWriter(fwriter);
        var bufw = bufwriter.writer();

        try bufw.print("P3\n{} {}\n255\n", .{ self.width, self.height });
        for (self.data) |rgb| {
            try bufw.print("{} {} {}\n", .{ rgb.r, rgb.g, rgb.b });
        }

        try bufwriter.flush();
    }
};

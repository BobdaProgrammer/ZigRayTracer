const std = @import("std");
const ImageFile = @import("image.zig");
const RayFile = @import("ray.zig");
const HittableFile = @import("hittable.zig");
const Image = ImageFile.Image;
const RGB = ImageFile.RGB;
const Vec3 = @import("vec.zig").Vec3;
const Ray = RayFile.Ray;
const Interval = @import("interval.zig").Interval;
const Camera = @import("camera.zig").Camera;

const Color3 = Vec3;

pub fn MakeImage() !void {
    // Create allocator and make image
    const allocator = std.heap.page_allocator;

    // World
    var world = try HittableFile.HittableList.init(allocator);
    var sphere = HittableFile.Sphere.init(Vec3.init(0, 0, -1), 0.5);
    var ground = HittableFile.Sphere.init(Vec3.init(0, -100.5, -1), 100);
    try world.objects.append(ground.hittable());
    try world.objects.append(sphere.hittable());

    const cam = Camera.init(16.0 / 9.0, 400);

    try cam.render(&world, allocator);
}

const std = @import("std");
const ImageFile = @import("image.zig");
const RayFile = @import("ray.zig");
const HittableFile = @import("hittable.zig");
const Image = ImageFile.Image;
const RGB = ImageFile.RGB;
const Vec3 = @import("vec.zig").Vec3;
const Ray = RayFile.Ray;

const Color3 = Vec3;

pub fn Color3_to_RGB(color: Color3) RGB {
    return RGB{
        .r = @intFromFloat(color.X()),
        .g = @intFromFloat(color.Y()),
        .b = @intFromFloat(color.Z()),
    };
}

pub fn ray_color(ray: Ray, world: *HittableFile.HittableList) Color3 {
    var rec: HittableFile.hit_record = undefined;
    if (world.hit(ray, 0, std.math.inf(f64), &rec)) {
        return rec.normal.add(Color3.init(1, 1, 1)).mulScalar(0.5);
    }

    const unit_direction = ray.dir.unit_vector();
    const a = 0.5 * (unit_direction.Y() + 1);
    return Color3.init(1.0, 1.0, 1.0).mulScalar(1.0 - a).add(Color3.init(0.5, 0.7, 1.0).mulScalar(a));
}

pub fn MakeImage() !void {
    const aspect_ratio = 16.0 / 9.0;
    const image_width = 400;
    var image_height: u64 = @intFromFloat(@as(f64, @floatFromInt(image_width)) / aspect_ratio);
    if (image_height < 1) {
        image_height = 1;
    }

    const focal_length = 1.0;
    const viewport_height = 2.0;
    const viewport_width = viewport_height * aspect_ratio;
    const camera_center = Vec3.zero();

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    const viewport_u = Vec3.init(viewport_width, 0, 0);
    const viewport_v = Vec3.init(0, -viewport_height, 0);

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    const pixel_delta_u = viewport_u.divScalar(@as(f64, @floatFromInt(image_width)));
    const pixel_delta_v = viewport_v.divScalar(@as(f64, @floatFromInt(image_height)));

    // Calculate the location of the upper left pixel.
    const viewport_upper_left = camera_center.sub(Vec3.init(0, 0, focal_length)).sub(viewport_u.divScalar(2.0)).sub(viewport_v.divScalar(2.0));
    const pixel00_loc = viewport_upper_left.add(pixel_delta_u.add(pixel_delta_v).mulScalar(0.5));
    // Create allocator and make image
    const allocator = std.heap.page_allocator;
    var image: Image = try Image.init(allocator, image_width, image_height);

    // World
    var world = try HittableFile.HittableList.init(allocator);
    var sphere = HittableFile.Sphere.init(Vec3.init(0, 0, -1), 0.5);
    var ground = HittableFile.Sphere.init(Vec3.init(0, -100.5, -1), 100);
    try world.objects.append(HittableFile.HittableObj{ .ctx = &ground, .hittable = ground.hittable() });
    try world.objects.append(HittableFile.HittableObj{ .ctx = &sphere, .hittable = sphere.hittable() });

    // free memory
    defer image.deinit();

    //loop through image and generate colors for the pixels
    var j: usize = 0;
    while (j < image.height) : (j += 1) {
        std.debug.print("Lines Left: {d}\n", .{image.height - j});
        var i: usize = 0;
        while (i < image.width) : (i += 1) {
            const pixel_center = pixel00_loc.add(pixel_delta_u.mulScalar(@as(f64, @floatFromInt(i)))).add(pixel_delta_v.mulScalar(@as(f64, @floatFromInt(j))));
            const ray_direction = pixel_center.sub(camera_center);

            const ray = Ray.init(camera_center, ray_direction);

            var col = ray_color(ray, &world);
            col = col.mulScalar(255.999);

            const index = i + j * image.width;

            const res = Color3_to_RGB(col);

            image.data[index] = res;
        }
    }
    try image.writeToFile("image.ppm");

    std.debug.print("Done!!\n", .{});
}

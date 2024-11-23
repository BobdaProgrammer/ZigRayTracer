const std = @import("std");
const ImageFile = @import("image.zig");
const RayFile = @import("ray.zig");
const HittableFile = @import("hittable.zig");
const Image = ImageFile.Image;
const RGB = ImageFile.RGB;
const Vec3 = @import("vec.zig").Vec3;
const Ray = RayFile.Ray;
const Interval = @import("interval.zig").Interval;

pub const Camera = struct {
    aspect_ratio: f64,
    image_width: u32,
    image_height: u32,
    center: Vec3, // Camera center
    pixel00_loc: Vec3, // Location of pixel 0, 0
    pixel_delta_u: Vec3, // Offset of pixel to the right
    pixel_delta_v: Vec3, // Offset of pixel below

    pub fn render(self: *const Camera, world: *HittableFile.HittableList, allocator: std.mem.Allocator) !void {
        var image: Image = try Image.init(allocator, self.image_width, self.image_height);
        // free memory
        defer image.deinit();

        //loop through image and generate colors for the pixels
        var j: usize = 0;
        while (j < image.height) : (j += 1) {
            std.debug.print("Lines Left: {d}\n", .{image.height - j});
            var i: usize = 0;
            while (i < image.width) : (i += 1) {
                const pixel_center = self.pixel00_loc.add(self.pixel_delta_u.mulScalar(@as(f64, @floatFromInt(i)))).add(self.pixel_delta_v.mulScalar(@as(f64, @floatFromInt(j))));
                const ray_direction = pixel_center.sub(self.center);

                const ray = Ray.init(self.center, ray_direction);

                var col = ray_color(ray, world);
                col = col.mulScalar(255.999);

                const index = i + j * image.width;

                const res = Color3_to_RGB(col);

                image.data[index] = res;
            }
        }
        try image.writeToFile("image.ppm");

        std.debug.print("Done!!\n", .{});
    }

    pub fn init(aspect_ratio: f64, width: u32) Camera {
        var self: Camera = undefined;
        self.aspect_ratio = aspect_ratio;
        self.image_width = width;
        self.image_height = @intFromFloat(@as(f64, @floatFromInt(self.image_width)) / aspect_ratio);
        self.image_height = if (self.image_height < 1) 1 else self.image_height;

        self.center = Vec3.zero();

        // Determine viewport dimensions.
        const focal_length = 1.0;
        const viewport_height = 2.0;
        const viewport_width = viewport_height * (@as(f64, @floatFromInt(self.image_width)) / @as(f64, @floatFromInt(self.image_height)));

        // Calculate the vectors across the horizontal and down the vertical viewport edges.
        var viewport_u = Vec3.init(viewport_width, 0, 0);
        var viewport_v = Vec3.init(0, -viewport_height, 0);

        // Calculate the horizontal and vertical delta vectors from pixel to pixel.
        self.pixel_delta_u = viewport_u.divScalar(@as(f64, @floatFromInt(self.image_width)));
        self.pixel_delta_v = viewport_v.divScalar(@as(f64, @floatFromInt(self.image_height)));

        // Calculate the location of the upper left pixel.
        const viewport_upper_left =
            self.center.sub(Vec3.init(0, 0, focal_length)).sub(viewport_u.divScalar(2)).sub(viewport_v.divScalar(2));
        self.pixel00_loc = viewport_upper_left.add(self.pixel_delta_u.add(self.pixel_delta_v).mulScalar(0.5));
        return self;
    }

    const Color3 = Vec3;

    pub fn Color3_to_RGB(color: Color3) RGB {
        return RGB{
            .r = @intFromFloat(color.X()),
            .g = @intFromFloat(color.Y()),
            .b = @intFromFloat(color.Z()),
        };
    }

    pub fn ray_color(ray: Ray, world: *const HittableFile.HittableList) Color3 {
        var rec: HittableFile.hit_record = undefined;
        if (world.hit(ray, Interval.init(0, std.math.inf(f64)), &rec)) {
            return rec.normal.add(Color3.init(1, 1, 1)).mulScalar(0.5);
        }

        const unit_direction = ray.dir.unit_vector();
        const a = 0.5 * (unit_direction.Y() + 1);
        return Color3.init(1.0, 1.0, 1.0).mulScalar(1.0 - a).add(Color3.init(0.5, 0.7, 1.0).mulScalar(a));
    }
};

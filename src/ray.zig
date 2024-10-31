const std = @import("std");
const Vec3 = @import("vec.zig").Vec3;

// make the ray class
pub const Ray = struct {
    // each ray has an origin of the ray and the direction it is pointing to
    orig: Vec3,
    dir: Vec3,

    pub fn zero() Ray {
        return Ray{
            .orig = Vec3.zero(),
            .dit = Vec3.zero(),
        };
    }

    pub fn init(orig: Vec3, dir: Vec3) Ray {
        return Ray{
            .orig = orig,
            .dir = dir,
        };
    }

    pub fn at(self: *const Ray, t: f64) Vec3 {
        return self.orig.add(self.dir.mulScalar(t));
    }
};

pub fn hit_sphere(center: Vec3, radius: f64, r: Ray) f64 {
    // P - C
    var oc: Vec3 = r.orig.sub(center);
    const a = r.dir.dot(r.dir);
    const b = oc.dot(r.dir) * 2.0;
    const c = oc.dot(oc) - radius * radius;

    const discriminant = b * b - 4 * a * c;

    if (discriminant < 0) {
        return -1.0;
    } else {
        return (-b - std.math.sqrt(discriminant)) / (2.0 * a);
    }
}

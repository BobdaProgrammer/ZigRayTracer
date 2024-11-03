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

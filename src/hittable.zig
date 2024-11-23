const Vec3 = @import("vec.zig").Vec3;
const RayFile = @import("ray.zig");
const Interval = @import("interval.zig").Interval;
const std = @import("std");

pub const hit_record = struct {
    p: Vec3,
    normal: Vec3,
    t: f64,
    front_face: bool,

    pub fn set_face_normal(self: *hit_record, r: *const RayFile.Ray, outward_normal: Vec3) void {
        self.front_face = r.dir.dot(outward_normal) < 0;
        self.normal = if (self.front_face) outward_normal else outward_normal.negate();
    }
};

// defines basically a template for an object that can be hittable by a ray
pub const Hittable = struct {
    // look in the documentation: VTable was the best thing I found
    ptr: *anyopaque,
    vtable: VTable,
    pub const VTable = struct {
        hit: *const fn (ctx: *anyopaque, r: RayFile.Ray, ray_t: Interval, rec: *hit_record) bool,
    };

    pub fn raw_hit(self: Hittable, r: RayFile.Ray, ray_t: Interval, rec: *hit_record, return_addr: *anyopaque) bool {
        return self.Vtable.hit(self.ptr, r, ray_t, rec, return_addr);
    }
};

// sphere implementation
pub const Sphere = struct {
    center: Vec3,
    radius: f64,

    // return a sphere at a center point with a certain radius
    pub fn init(center: Vec3, radius: f64) Sphere {
        return Sphere{ .center = center, .radius = radius };
    }

    // returns wether a ray has hit the circle or not
    pub fn hit(ctx: *anyopaque, r: RayFile.Ray, ray_t: Interval, rec: *hit_record) bool {
        const self: *Sphere = @ptrCast(@alignCast(ctx));

        // x^2+y^2+z^2=r^2
        // h=b/-2=d⋅(C−Q)
        // C is the center point
        // Q is the origin
        // d is the direction

        // Subtract the rays origin by the center of the sphere
        var oc: Vec3 = r.orig.sub(self.center);

        // square the lenght of the ray and set it to a
        const a = r.dir.length_squared();
        // get the dot product of the oc and the ray direction
        const h = oc.dot(r.dir);
        // get the oc length squared and subtract it by the radius squared (the r^2 in the equation)
        const c = oc.length_squared() - self.radius * self.radius;

        const discriminant = h * h - a * c;

        if (discriminant < 0) {
            return false;
        }
        const sqrtd = std.math.sqrt(discriminant);

        // find nearest root in acceptable range
        var root = (-h - sqrtd) / a;
        if (!ray_t.surrounds(root)) {
            root = (-h + sqrtd) / a;
            if (!ray_t.surrounds(root)) {
                return false;
            }
        }

        rec.t = root;
        rec.p = r.at(rec.t);
        const outward_normal: Vec3 = rec.p.sub(self.center).divScalar(self.radius);
        rec.set_face_normal(&r, outward_normal);

        return true;
    }

    pub fn hittable(self: *Sphere) Hittable {
        return Hittable{ .ptr = self, .vtable = Hittable.VTable{
            .hit = hit,
        } };
    }
};

// world scene, a list of hittable objects
pub const HittableList = struct {
    objects: std.ArrayList(Hittable),

    // initiate an empty list of hittable objects with an allocator
    pub fn init(allocator: std.mem.Allocator) !HittableList {
        return HittableList{
            .objects = std.ArrayList(Hittable).init(allocator),
        };
    }

    // returns if any of the objects in the HittableList were hit
    pub fn hit(self: *const HittableList, r: RayFile.Ray, ray_t: Interval, rec: *hit_record) bool {
        var temp_rec: hit_record = undefined;
        var hit_anything: bool = false;
        var closest_so_far: f64 = ray_t.max;

        // loops through all items and checks if they have been hit
        for (self.objects.items) |object| {
            const @"hitSummin?" = object.vtable.hit(object.ptr, r, Interval.init(ray_t.min, closest_so_far), &temp_rec);
            if (@"hitSummin?") {
                hit_anything = true;
                closest_so_far = temp_rec.t;
                rec.* = temp_rec;
            }
        }

        return hit_anything;
    }
};

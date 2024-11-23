const std = @import("std");

pub const Interval = struct {
    min: f64,
    max: f64,

    pub fn init(min: f64, max: f64) Interval {
        return Interval{
            .min = min,
            .max = max,
        };
    }

    pub fn empty() Interval {
        return Interval{
            .min = std.math.inf(f64),
            .max = -std.math.inf(f64),
        };
    }

    pub fn universe() Interval {
        return Interval{
            .min = -std.math.inf(f64),
            .max = std.math.inf(f64),
        };
    }

    pub fn size(self: *const Interval) f64 {
        return self.max - self.min;
    }

    pub fn contains(self: *const Interval, x: f64) bool {
        return self.min <= x and x <= self.max;
    }

    pub fn surrounds(self: *const Interval, x: f64) bool {
        return self.min < x and x < self.max;
    }

    pub fn clamp(self: *const Interval, x: f64) f64 {
        if (x < self.min) {
            return self.min;
        }
        if (x > self.max) {
            return self.max;
        }
        return x;
    }
};

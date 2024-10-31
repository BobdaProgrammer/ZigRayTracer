// Defining a vector 3
pub const Vec3 = struct {
    data: @Vector(3, f64),

    // makes a vector with specific values
    pub fn init(x: f64, y: f64, z: f64) Vec3 {
        var self = Vec3{ .data = @Vector(3, f64){ 0.0, 0.0, 0.0 } };

        self.data[0] = x;
        self.data[1] = y;
        self.data[2] = z;

        return self;
    }

    // makes an empty vector with all values at 0
    pub fn zero() Vec3 {
        return Vec3{ .data = @Vector(3, f64){ 0.0, 0.0, 0.0 } };
    }

    // returns a the vector's X
    pub fn X(self: *const Vec3) f64 {
        return self.data[0];
    }

    // returns a the vector's Y
    pub fn Y(self: *const Vec3) f64 {
        return self.data[1];
    }

    // returns a the vector's Z
    pub fn Z(self: *const Vec3) f64 {
        return self.data[2];
    }

    // makes the vector data negative
    pub fn negate(self: *const Vec3) Vec3 {
        return Vec3{ .data = -self.data };
    }

    // adds a different vector's values to itself
    pub fn addEq(self: *const Vec3, v: Vec3) *Vec3 {
        self.data += v.data;
        return self;
    }

    // adds two vectors' data
    pub fn add(u: *const Vec3, v: Vec3) Vec3 {
        return Vec3{ .data = u.data + v.data };
    }

    // subtracts two vectors' data
    pub fn sub(u: *const Vec3, v: Vec3) Vec3 {
        return Vec3{ .data = u.data - v.data };
    }

    // multiplies two vectors
    pub fn mul(u: *const Vec3, v: Vec3) Vec3 {
        return Vec3{ .data = u.data * v.data };
    }

    // divides two vectors
    pub fn div(u: *const Vec3, v: Vec3) Vec3 {
        return Vec3{ .data = u.data / v.data };
    }

    // multiply vector by scalar
    pub fn mulScalar(v: Vec3, scalar: f64) Vec3 {
        return Vec3{ .data = v.data * @as(@Vector(3, f64), @splat(scalar)) };
    }

    // divide vector by scalar
    pub fn divScalar(v: Vec3, scalar: f64) Vec3 {
        return Vec3{ .data = v.data / @as(@Vector(3, f64), @splat(scalar)) };
    }

    // multiply the vector by another vector
    pub fn mulEq(self: *const Vec3, scalar: f64) *Vec3 {
        self.data *= @splat(scalar);
        return self;
    }

    // divide the vector by another vector
    pub fn divEq(self: *const Vec3, scalar: f64) *Vec3 {
        self.data /= @splat(scalar);
        return self;
    }

    // Get length of vector data by squaring each thing and square rooting the answer
    pub fn length(self: *const Vec3) f64 {
        return @sqrt(length_squared(self));
    }

    // square the vectors data values
    pub fn length_squared(self: *const Vec3) f64 {
        const x = self.data[0];
        const y = self.data[1];
        const z = self.data[2];
        return x * x + y * y + z * z;
    }

    // dot product of 2 vectors
    pub fn dot(u: Vec3, v: Vec3) f64 {
        // goes through each value of the two datas and multiplies each one
        // u⋅v = ux × vx + uy × vy + uz × vz
        const res = @reduce(.Add, u.data * v.data);
        return res;
    }

    // cross product of 2 vectors (creating a vector perpendicular to two vectors)
    pub fn cross(u: Vec3, v: Vec3) Vec3 {
        const x: f64 = u.data[1] * v.data[2] - u.data[2] * v.data[1];
        const y: f64 = u.data[2] * v.data[0] - u.data[0] * v.data[2];
        const z: f64 = u.data[0] * v.data[1] - u.data[1] * v.data[0];

        return Vec3.init(x, y, z);
    }

    pub fn unit_vector(v: Vec3) Vec3 {
        return v.divScalar(v.length());
    }
};

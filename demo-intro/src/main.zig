// imports
const std = @import("std");

const debug = std.debug;
const expect = std.testing.expect;

// Comments start with double slashes
// No multiline comments

/// Doc Comments have triple slashes
///! Top-Level Comments describe the contents of the file

// Main is the starting point of the application
pub fn main() !void {
    basicTypes();
    advancedTypes();
    control();
    structs();
    defers();
    errors();
    buildIns();
    @"comptime"();
    async_calls();
    try allocators();
}

// basicTypes
pub fn basicTypes() void {
    // Basic types

    // Ints
    const a: i32 = 1; // 32 bit signed int
    // Unused variables fail to compile so we assign back to underscore
    _ = a;
    const b: i16 = 2; // 16 bit signed int
    _ = b;
    const c: u64 = 1; // 64 bit unsigned int
    _ = c;
    const d: u22 = 1; // 22 bit unsigned int
    _ = d;

    // Floats
    const e: f128 = 1_234_234.4; // 32 bit float
    _ = e;
    // Booleans
    const f: bool = true;
    _ = f;

    // strings
    const msg_1 = "abc";
    _ = msg_1; // implied as []const u8

    const msg_2 =
        \\ 
        \\ This
        \\ Is
        \\ a 
        \\ Multiline String
        \\ asdasd
    ;
    _ = msg_2;

    // type inference
    const g = 64; // infered as i32
    _ = g;

    // Other types
    // unsigned pointer integer
    const h: usize = 2;
    _ = h;

    // C int type (int)
    const l: c_int = 2;
    _ = l;

    // Optionals can have a null value. var here means its a mutable value.
    // The null of the optional is guaranteed to be address 0.
    var j: ?i32 = null;
    // Undefined is setting the value unspecifed. This is different than null.
    j = undefined;

    // Error union represent either a value or an error.
    // The left part is always an error type followed by `!` and then the type of the variable
    var k: anyerror!i32 = 456;
    // Errors are values and you can create ones on the fly like that:
    k = error.BadExample;

    // Format Printing
    debug.print("{d}, {s}, {any}\n", .{ 1, "hello world", k });

    // Mutability
    const i = 1;
    _ = i;
    // i += 1; that won't compile

    // Identifiers. Prefix with `@` if name classes with existing identifier
    const @"error" = "abc";
    _ = @"error";
}

// advancedTypes
pub fn advancedTypes() void {
    // Arrays. Undefined size
    const ch_array = [_]u8{ 'a', 'b', 'c' };
    const ch_array_len = ch_array.len;
    _ = ch_array_len;

    // Arrays. Fixed size
    const ints = [2]i32{ 1, 2 };
    _ = ints;

    // Arrays. Zero terminated array.
    const chrs = [_:0]u8{ 'a', 'b', 'c' };
    _ = chrs;

    // Array init
    const pattern = "ab" ** 4;
    _ = pattern; // "abababab"

    // Enums
    const myEnum = enum { one, two, three };
    const first = myEnum.one;
    _ = first;

    // Structs
    const Point = struct {
        x: i32,
        y: i32,
    };
    _ = Point;
}

// control
pub fn control() void {
    // if statements with optionals
    var a: ?i32 = null;
    a = 2;
    if (a) |v| {
        // v here is not optional
        debug.print("{d}\n", .{v});
    }

    // for loops
    // Range
    for (0..10) |i| {
        debug.print("{d} ", .{i});
    }
    debug.print("\n", .{});

    const arr = [_]i32{ 1, 2, 3, 4, 5 };
    for (arr, 0..) |v, i| {
        debug.print("{d}:{d} ", .{ i, v });
    }
    debug.print("\n", .{});

    // while loops
    var i: i32 = 0;
    while (i < 10) : (i += 1) {
        debug.print("{d} ", .{i});
    }
    debug.print("\n", .{});
    // switch statements
    const aa = 2;
    const b = switch (aa) {
        1, 2, 3 => 0,
        5...9 => 1,
        10 => 2,
        else => 3,
    };
    _ = b;
}

// structs
const Vector = struct {
    // Default value
    x: f32 = 0,
    y: f32 = 0,
    z: f32 = 0,
    // Methods
    pub fn init(x: f32, y: f32, z: f32) Vector {
        // create new struct
        return Vector{
            .x = x,
            .y = y,
            .z = z,
        };
    }
    // Methods
    pub fn dot(self: Vector, other: Vector) f32 {
        return self.x * other.x + self.y * other.y + self.z * other.z;
    }
};
pub fn structs() void {
    // Call methods. Static means it cannot change
    const v = Vector.init(1, 2, 3);
    _ = v;
    // v.x = 2; src/main.zig:185:6: error: cannot assign to constant, v.x = 2;
}

// defers
pub fn defers() void {
    // defer will execute an expression at the end of the current scope.
    // This happens in reverse order of when they are called. LIFO
    defer {
        debug.print("second ", .{});
    }
    defer {
        debug.print("first ", .{});
    }
}

const AllocationError = error{
    OutOfMemory,
};

fn failingFunction() error{Oops}!void {
    return error.Oops;
}

// Errors
pub fn errors() void {
    failingFunction() catch |e| {
        switch (e) {
            error.Oops => {
                debug.print("Oops \n", .{});
            },
        }
        return;
    };
    // try failingFunction();
}

// buildins
pub fn buildIns() void {
    // convert int to pointer
    const ptr = @intToPtr(?*i32, 0x0);
    std.debug.assert(ptr == null);

    // int to float, float to int
    const a: i32 = 0;
    const b = @intToFloat(f32, a);
    const c = @floatToInt(i32, b);
    _ = c;

    // @as performs an explicit type coercion
    const inferred_constant = @as(i16, 5);
    _ = inferred_constant;

    // Exact division. Caller guarantees denominator != 0
    var x: i8 = 10;
    x = @divExact(x, 10);

    // Truncated division. Rounds toward zero.
    x = @divTrunc(10, 3);
    std.debug.print("{}\n", .{x});

    // get the size of type
    std.debug.print("{}\n", .{@sizeOf(usize) == @sizeOf(*u8)});

    // Full list here https://ziglang.org/documentation/0.10.1/#Builtin-Functions
}

const Header = struct {
    magic: u32,
    name: []const u8,
};

fn printInfoAboutStruct(comptime T: type) void {
    const info = @typeInfo(T);
    inline for (info.Struct.fields) |field| {
        std.debug.print(
            "{s} has a field called {s} with type {s}\n",
            .{
                @typeName(T),
                field.name,
                @typeName(field.type),
            },
        );
    }
}

// Zig implements generics suing comptime. It is compile-time duck typing.
fn max(comptime T: type, a: T, b: T) T {
    return if (a > b) a else b;
}

// comptime
pub fn @"comptime"() void {
    printInfoAboutStruct(Header);

    const maxOfInts = max(i32, 2, 3);
    std.debug.print("{}\n", .{maxOfInts});

    // caveats with stack-overflow https://github.com/ziglang/zig/issues/13724
}

var p: i32 = 1;
fn func() void {
    p += 1;
    suspend {}
    // This line is never reached because the suspend has no matching resume.
    p += 1;
}
pub fn async_calls() void {
    // var frame = async func();
    // _ = frame;
    // try expect(p == 2);
}

const Foo = struct { data: *u32 };
// allocators
pub fn allocators() !void {
    // Allocates an array of n items of type T and sets all the items to undefined
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = general_purpose_allocator.allocator();
    // Allocates an array of n items of type T and sets all the items to undefined
    var foos = try allocator.alloc(Foo, 3);
    std.debug.print("{}\n", .{foos.len});

    // Pass allocator on init
    var list1 = try std.ArrayList(i32).initCapacity(allocator, 3);
    defer list1.deinit();
    try list1.insert(0, 1);
    try list1.insert(0, 2);
    try list1.insert(0, 3);
    std.debug.print("{}\n", .{list1});

    // Pass allocator on each method
    var list2 = std.ArrayListUnmanaged(i32){};
    defer list2.deinit(allocator);
    try list2.append(allocator, 1);
    try list2.append(allocator, 2);
    try list2.append(allocator, 3);
    std.debug.print("{}\n", .{list2});
}

test "simple test" {
    var list = std.ArrayList(i32).init(std.testing.allocator);
    defer list.deinit(); // try commenting this out and see if zig detects the memory leak!
    try list.append(42);

    try std.testing.expectEqual(@as(i32, 42), list.pop());
    try std.testing.expect(1 == 1);
    try std.testing.expectStringStartsWith("ABCDEFG", "ABC");
}

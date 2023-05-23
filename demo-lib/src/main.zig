const std = @import("std");
const testing = std.testing;

// pub is visible to importers and export means that the symbol is
// visible to extern declarations and the linker.
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    try testing.expect(add(3, 7) == 10);
}

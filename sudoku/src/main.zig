const std = @import("std");
extern fn print(i32) void;

const walloc = std.heap.wasm_allocator;

const Sudoku = struct { content: []u8 };

export fn get_sudoku(s: [*]u8) i32 {
    const nums = "01234567890";
    var i: u8 = 0;
    while (i < 81) : (i += 1) {
        s[i] = nums[i % 10];
    }
    return 0;
}

export fn add(a: i32, b: i32) i32 {
    return a + b;
}

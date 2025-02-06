const std = @import("std");
extern fn print(i32) void;
const solver = @import("solver.zig");
const walloc = std.heap.wasm_allocator;

const Sudoku = struct { puzzle: [81]u8, solved: [81]u8, difficulty: f32 };

export fn get_sudoku_buffer() *const [@sizeOf(Sudoku)]u8 {
    const buf = "0" ** @sizeOf(Sudoku);
    return buf;
}

export fn get_sudoku(s: [*]u8) i32 {
    const nums1 = "012080405607290";
    var i: u8 = 0;
    while (i < 81) : (i += 1) {
        s[i] = nums1[i % 15];
    }
    const nums2 = "312689485627893";
    i = 0;
    while (i < 81) : (i += 1) {
        s[i + 81] = nums2[i % 15];
    }

    return 0;
}

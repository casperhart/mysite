const std = @import("std");
const testing = std.testing;

// fn crossProduct(comptime N: usize, comptime M: usize, arr1: [N]u8, arr2: [M]u8) [N * M][2]u8 {
//     var result: [N * M][2]u8 = undefined;
//     var index: usize = 0;

//     for (arr2) |ch1| {
//         for (arr1) |ch2| {
//             result[index] = .{ ch1, ch2 };
//             index += 1;
//         }
//     }
//     return result;
// }
//
//
const SudokuError = error{Contradiction};

const Candidates = struct {
    data: usize,

    pub fn init() Candidates {
        const data: usize = @as(usize, 0b111111111);
        return Candidates{ .data = data };
    }

    pub fn contains(self: *const Candidates, digit: usize) bool {
        return self.data >> @truncate(digit - 1) & 1 == 1;
    }

    pub fn remove(self: *Candidates, digit: usize) void {
        self.data &= ~(std.math.pow(usize, 2, digit - 1));
    }

    pub fn fill(self: *Candidates, digit: u8) SudokuError!void {
        //std.debug.print("self: {}, digit: {}, contains: {}", .{ self, digit, self.contains(digit) });

        if (!self.contains(digit)) {
            return SudokuError.Contradiction;
        }
        for (1..10) |d| {
            if (d != digit) {
                self.remove(d);
            }
        }
    }

    pub fn repr(self: *const Candidates) void {
        var s: [9]u8 = undefined;
        var i: u6 = 0;
        while (i < 9) : (i += 1) {
            if ((self.data >> i) & 1 == 1) {
                s[i] = i + '0';
            }
        }
        return std.fmt.formatText(s, "{}");
    }

    pub fn print(self: *const Candidates) void {
        var i: u6 = 0;
        while (i < 9) : (i += 1) {
            if ((self.data >> i) & 1 == 1) {
                std.debug.print("{d}", .{i + 1});
            } else {
                std.debug.print(".", .{});
            }
        }
    }
};

const Sudoku = struct {
    puzzle: *const [81]u8,
    solution: [81]u8,
    candidates: [81]Candidates,

    fn new(puzzle: *const [81]u8) Sudoku {
        var candidates: [81]Candidates = undefined;
        for (0..81) |i| {
            candidates[i] = Candidates.init();
        }
        return Sudoku{ .puzzle = puzzle, .solution = undefined, .candidates = candidates };
    }

    fn eliminate(self: *Sudoku, s: usize, d: u8) void {
        self.candidates[s].remove(d);
    }

    fn fill(self: *Sudoku, s: usize, d: u8) void {
        self.candidates[s].fill(d);
    }

    fn print(self: *const Sudoku) void {
        std.debug.print("\n", .{});

        for (0..3) |i| {
            if (i > 0) {
                std.debug.print(" " ++ "-" ** 91 ++ "\n", .{});
            }
            for (0..3) |j| {
                for (0..3) |k| {
                    if (k > 0) {
                        std.debug.print("| ", .{});
                    }
                    for (0..3) |l| {
                        self.candidates[i * 3 + j * 3 + k * 3 + l].print();
                        std.debug.print(" ", .{});
                    }
                }
                std.debug.print("\n", .{});
            }
        }
    }
};

//const Solver = struct { digits: [9]u8, rows: [9]u8, cols: [9]u8, all_squares: [81][2]u8, sudoku: Sudoku };

pub fn main() !void {
    var sudoku = Sudoku.new("1" ** 81);
    std.debug.print("{}", .{!sudoku.candidates[0].contains(6)});
    try sudoku.candidates[0].fill(6);

    // try sudoku.candidates[0].fill(6) catch std.debug.print("{}", .{sudoku.candidates[0]});
    // try sudoku.candidates[2].fill(4) catch 0;
    // try sudoku.candidates[8].fill(4) catch 0;

    sudoku.print();
}

test "candidates" {
    var c = Candidates.init();
    try testing.expect(c.contains(1));
    c.remove(1);
    try testing.expect(!c.contains(1));
    try testing.expect(c.contains(5));
    c.remove(5);
    try testing.expect(!c.contains(5));
    c.print();
}

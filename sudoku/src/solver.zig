const std = @import("std");
const testing = std.testing;
const grid = @import("grid.zig");

const SudokuError = error{Contradiction};

const Candidates = struct {
    data: usize,

    pub fn init_empty() Candidates {
        const data: usize = @as(usize, 0b111111111);
        return Candidates{ .data = data };
    }

    pub fn init_value(value: usize) Candidates {
        const data: usize = @as(usize, 1) << @truncate(value);
        return Candidates{ .data = data };
    }

    pub fn contains(self: *const Candidates, digit: usize) bool {
        return self.data >> @truncate(digit - 1) & 1 == 1;
    }

    pub fn eliminate(self: *Candidates, digit: usize) void {
        // self.data &= ~(std.math.pow(usize, 2, digit - 1));
        //const
        self.data &= ~(@as(usize, 1) << @truncate(digit - 1));
    }

    pub fn len(self: *Candidates) u8 {
        var l = 0;
        for (0..9) |i| {
            l += (self.data >> i) & 1;
        }
        return l;
    }

    // pub fn fill(self: *Candidates, digit: u8) SudokuError!void {
    //     //std.debug.print("self: {}, digit: {}, contains: {}", .{ self, digit, self.contains(digit) });

    //     if (!self.contains(digit)) {
    //         return SudokuError.Contradiction;
    //     }
    //     for (1..10) |d| {
    //         if (d != digit) {
    //             self.eliminate(d);
    //         }
    //     }
    // }

    // pub fn repr(self: *const Candidates) void {
    //     var s: [9]u8 = undefined;
    //     var i: u6 = 0;
    //     while (i < 9) : (i += 1) {
    //         if ((self.data >> i) & 1 == 1) {
    //             s[i] = i + '0';
    //         }
    //     }
    //     return std.fmt.formatText(s, "{}");
    // }

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
    peers: *const [81][20]usize,
    units: *const [81][3][9]usize,
    puzzle: *const [81]u8,
    solution: [81]u8,
    candidates: [81]Candidates,

    fn new(puzzle: *const [81]u8) Sudoku {
        var candidates: [81]Candidates = undefined;
        for (0..81) |i| {
            if (puzzle[i] == '.' or puzzle[i] == '0') {
                candidates[i] = Candidates.init_empty();
            } else if (puzzle[i] - '0' >= 1 and puzzle[i] - '1' <= 9) {
                candidates[i] = Candidates.init_value(puzzle[i] - '1');
            }
        }

        return Sudoku{ .peers = &grid.peers, .units = &grid.units, .puzzle = puzzle, .solution = undefined, .candidates = candidates };
    }

    fn constrain(self: *Sudoku) void {
        for (self.candidates) |c| {
            if (c.len() == 1) {
                self.fill(c, c.get());
            }
        }
    }

    fn fill(self: *Sudoku, square: usize) void {
        std.debug.print("{}{}", .{ self, square });
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
    fn print_cell(self: *const Sudoku, cell: usize) void {
        for (0..9) |row| {
            for (0..9) |col| {
                var exists = false;
                for (self.peers[cell]) |val| {
                    if (row * 9 + col == val) {
                        exists = true;
                        break;
                    }
                }
                if (exists) {
                    std.debug.print("X ", .{});
                } else {
                    std.debug.print(". ", .{});
                }
            }
            std.debug.print("\n", .{});
        }
    }
};

pub fn main() void {
    var sudoku = Sudoku.new("1" ** 81);
    sudoku.print();
    sudoku.print_cell(10);
}

test "candidates" {
    var c = Candidates.init_empty();
    try testing.expect(c.contains(1));
    c.eliminate(1);
    try testing.expect(!c.contains(1));
    try testing.expect(c.contains(5));
    c.eliminate(5);
    try testing.expect(!c.contains(5));
    c.print();
}

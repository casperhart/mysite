const std = @import("std");
const testing = std.testing;
const grid = @import("grid.zig");

const SudokuError = error{ Contradiction, MultipleSolutions };
var n_sol: usize = 0;
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

    pub fn remove(self: *Candidates, digit: usize) void {
        self.data &= ~(@as(usize, 1) << @truncate(digit - 1));
    }

    pub fn len(self: *const Candidates) u8 {
        var l: u8 = 0;
        for (0..9) |i| {
            if ((self.data >> @truncate(i)) & 1 == 1) {
                l += 1;
            }
        }
        return l;
    }

    pub fn get_first(self: *const Candidates) usize {
        var result: usize = 0;
        for (0..9) |i| {
            if (self.contains(i + 1)) {
                result = i + 1;
                break;
            }
        }
        return result;
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
    peers: *const [81][20]usize,
    units: *const [81][3][9]usize,
    puzzle: *const [81]u8,
    solution: [81]u8,
    candidates: [81]Candidates,

    fn new(puzzle: *const [81]u8) Sudoku {
        var candidates: [81]Candidates = undefined;
        var solution: [81]u8 = undefined;
        for (0..81) |i| {
            if (puzzle[i] == '.' or puzzle[i] == '0') {
                candidates[i] = Candidates.init_empty();
            } else if (puzzle[i] - '0' >= 1 and puzzle[i] - '1' <= 9) {
                candidates[i] = Candidates.init_value(puzzle[i] - '1');
            }

            solution[i] = puzzle[i];
        }

        return Sudoku{ .peers = &grid.peers, .units = &grid.units, .puzzle = puzzle, .solution = solution, .candidates = candidates };
    }

    fn constrain(self: *Sudoku) !void {
        for (self.candidates, 0..) |c, i| {
            if (c.len() == 1) {
                //std.debug.print("candidates: {}, i: {}", .{ c.get_first(), i });
                try self.fill(i, c.get_first());
            }
        }
    }

    fn fill(self: *Sudoku, square: usize, digit: usize) SudokuError!void {
        for (1..10) |i| {
            if (i != digit) {
                self.candidates[square].remove(i);
            }
        }

        for (self.peers[square]) |p| {
            if (self.candidates[square].contains(digit)) {
                try self.eliminate(p, digit);
            }
        }
    }

    // eliminate a digit as a candidate from other squares
    fn eliminate(self: *Sudoku, square: usize, digit: usize) !void {
        if (!self.candidates[square].contains(digit)) {
            return;
        }
        // we're about to eliminate the last possible digit
        if (self.candidates[square].len() == 1) {
            return SudokuError.Contradiction;
        }

        self.candidates[square].remove(digit);

        // strategy 1: eliminate digit from all peers
        if (self.candidates[square].len() == 1) {
            try self.fill(square, self.candidates[square].get_first());
        }

        // strategy 2: if digit is the only digit in a unit, fill it
        for (self.units[square]) |unit| {
            var cnt: u8 = 0;
            for (unit) |sq| {
                if (self.candidates[sq].contains(digit)) {
                    cnt += 1;
                }
            }
            if (cnt == 1) {
                for (unit) |sq| {
                    if (self.candidates[sq].contains(digit)) {
                        try self.fill(sq, digit);
                    }
                }
            }
        }
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
                        self.candidates[i * 27 + j * 9 + k * 3 + l].print();
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

    fn is_solved(self: *const Sudoku) bool {
        for (self.candidates) |c| {
            if (c.len() > 1) {
                return false;
            }
        }
        return true;
    }

    fn min_c_idx(self: *const Sudoku) usize {
        var min: usize = std.math.maxInt(usize);
        var idx: usize = 0;
        for (self.candidates, 0..) |c, i| {
            if (c.len() < min and c.len() > 1) {
                min = c.len();
                idx = i;
            }
        }
        return idx;
    }

    fn solve(self: *Sudoku) SudokuError!void {
        if (self.is_solved()) {
            n_sol += 1;
            if (n_sol > 1) {
                return SudokuError.MultipleSolutions;
            }
            return;
        }

        const min_idx = self.min_c_idx();
        var new_s: Sudoku = self.*;
        var solved = false;
        var solution = self.candidates;

        for (1..10) |c| {
            if (self.candidates[min_idx].contains(c)) {
                new_s.candidates = self.candidates;
                new_s.fill(min_idx, c) catch continue;
                new_s.solve() catch |e| {
                    switch (e) {
                        SudokuError.Contradiction => continue,
                        SudokuError.MultipleSolutions => return e,
                    }
                };
                solved = true;
                solution = new_s.candidates;
            }
        }
        if (!solved) {
            return SudokuError.Contradiction;
        } else {
            self.candidates = solution;
            for (self.solution, 0..) |s, i| {
                if (s == '0' or s == '.') {
                    self.solution[i] = @intCast(self.candidates[i].get_first() + @as(u8, '0'));
                }
            }
        }
    }
};

pub fn main() !void {
    var timer = try std.time.Timer.start();
    const s = "0.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......";
    var sudoku = Sudoku.new(s);

    try sudoku.constrain();
    try sudoku.solve();
    std.debug.print("{}", .{timer.lap()});
}

// test "candidates" {
//     var c = Candidates.init_empty();
//     try testing.expect(c.contains(1));
//     c.remove(1);
//     try testing.expect(!c.contains(1));

//     try testing.expect(c.contains(9));
//     c.remove(9);
//     try testing.expect(!c.contains(9));
// }

// test "eliminate1" {
//     const s = "53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79";
//     var sudoku = Sudoku.new(s);

//     try sudoku.eliminate(2, 2);
//     try testing.expect(sudoku.candidates[2].contains(4));
//     try testing.expect(!sudoku.candidates[2].contains(2));
//     //try testing.expect(!sudoku.candidates[1].contains(1));
// }

// test "eliminate2" {
//     const s = "53..7....6..195....98....6.8...6...34..8.3..17...2...6.6....28....419..5....8..79";
//     var sudoku = Sudoku.new(s);

//     sudoku.print();
//     try sudoku.constrain();
//     sudoku.print();
//     //try testing.expect(sudoku.candidates[0].contains(1));
//     //try testing.expect(!sudoku.candidates[1].contains(1));
// }

// test "eliminate3" {
//     const s = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......";
//     var sudoku = Sudoku.new(s);

//     sudoku.print();
//     try sudoku.constrain();
//     sudoku.print();
//     //try testing.expect(sudoku.candidates[0].contains(1));
//     //try testing.expect(!sudoku.candidates[1].contains(1));
// }

test "solve" {
    const s = "4.....8.5.3..........7......2.....6.....8.4......1.......6.3.7.5..2.....1.4......";
    var sudoku = Sudoku.new(s);

    try sudoku.constrain();
    try sudoku.solve();
    sudoku.print();
    std.debug.print("{s}", .{sudoku.solution});
    //try testing.expect(sudoku.candidates[0].contains(1));
    //try testing.expect(!sudoku.candidates[1].contains(1));
}

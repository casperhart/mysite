fn get_units() [81][3][9]usize {
    @setEvalBranchQuota(5000);
    var u: [81][3][9]usize = undefined;

    // populate row peers
    for (0..9) |row| {
        for (0..9) |cell| {
            for (0..9) |peer| {
                u[row * 9 + cell][0][peer] = row * 9 + peer;
            }
        }
    }
    // populate column peers
    for (0..9) |row| {
        for (0..9) |cell| {
            for (0..9) |peer| {
                u[row * 9 + cell][1][peer] = cell + 9 * peer;
            }
        }
    }

    // populate box peers
    var box_row: usize = undefined;
    var box_col: usize = undefined;
    const first_box: [9]u8 = .{ 0, 1, 2, 9, 10, 11, 18, 19, 20 };
    for (0..9) |row| {
        for (0..9) |col| {
            box_row = (row / 3);
            box_col = (col / 3);
            for (0..9) |peer| {
                u[row * 9 + col][2][peer] = first_box[peer] + 27 * box_row + 3 * box_col;
            }
        }
    }
    return u;
}

pub const units = get_units();

fn get_peers(u: [81][3][9]usize) [81][20]usize {
    @setEvalBranchQuota(100000);
    // get unique peers across rows, cells, boxes
    var p: [81][20]usize = undefined;
    var i: usize = undefined;
    for (0..81) |cell| {
        i = 0;
        // add row peers, as they will be unique
        for (0..9) |row_peer| {
            if (u[cell][0][row_peer] != cell) {
                p[cell][i] = u[cell][0][row_peer];
                i += 1;
            }
        }
        // add col peers, as they will also be unique
        for (0..9) |col_peer| {
            if (u[cell][1][col_peer] != cell) {
                p[cell][i] = u[cell][1][col_peer];
                i += 1;
            }
        }

        var exists = false;
        var peer_val: usize = undefined;
        for (0..9) |box_peer| {
            exists = false;
            peer_val = u[cell][2][box_peer];
            for (0..i) |existing| {
                if (p[cell][existing] == peer_val) {
                    exists = true;
                }
            }
            // std.debug.print("\nbox_peer: {}, i: {}", .{ box_peer, i });
            if (exists or peer_val == cell) {
                continue;
            } else {
                p[cell][i] = peer_val;
                i += 1;
            }
        }
    }
    return p;
}

pub const peers = get_peers(units);

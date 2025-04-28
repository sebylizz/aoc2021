const std = @import("std");
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input/2.txt", .{});
    defer file.close();

    const allocator = std.heap.page_allocator;

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var nrs = ArrayList(u32).init(allocator);
    defer nrs.deinit();

    var lines = std.mem.splitScalar(u8, buffer, '\n');

    var x: i32 = 0;
    var y: i32 = 0;
    var x2: i32 = 0;
    var y2: i32 = 0;
    var aim: i32 = 0;

    while (lines.next()) |line| {
        if (line.len == 0) continue;

        var split = std.mem.splitScalar(u8, line, ' ');
        const dir = std.meta.stringToEnum(enum { forward, down, up }, split.next().?) orelse continue;
        const num = try parseInt(i32, split.next().?, 10);

        switch (dir) {
            .forward => {
                x += num;
                x2 += num;
                y2 += aim * num;
            },
            .down => {
                y += num;
                aim += num;
            },
            .up => {
                y -= num;
                aim -= num;
            },
        }
    }

    std.debug.print("Part 1: {}\n", .{x * y});
    std.debug.print("Part 2: {}\n", .{x2 * y2});


    // Trying without stdlib

    const Struct = struct {
        Dir: u8,
        Val: u32,
    };

    var i: usize = 0;
    var nrlines: usize = 0;
    while (i < file_size) {
        if (buffer[i] == '\n') nrlines += 1;
        i += 1;
    }

    var arr = try allocator.alloc(Struct, nrlines);
    defer allocator.free(arr);

    var cnt2: usize = 0;
    i = 0;
    while (i < file_size) {
        if (buffer[i] != '\n') {
            if (i >= file_size or buffer[i] == '\n') {
                i += 1;
                continue;
            }

            var j: usize = i;
            while (j < file_size and buffer[j] != ' ') {
                j += 1;
            }

            arr[cnt2].Dir = buffer[i];

            j += 1;
            i = j;

            var num: u32 = 0;
            while (j < file_size and buffer[j] != '\n') {
                num = num * 10 + (buffer[j] - '0');
                j += 1;
            }

            arr[cnt2].Val = num;

            i = j + 1;
            cnt2 += 1;
        }
    }

    var xx: u32 = 0;
    var yy: u32 = 0;
    var xx2: u32 = 0;
    var yy2: u32= 0;
    var aimm: u32 = 0;

    for (arr) |line| {
        switch (line.Dir) {
            'f' => {
                xx += line.Val;
                xx2 += line.Val;
                yy2 += aimm * line.Val;
            },
            'd' => {
                yy += line.Val;
                aimm += line.Val;
            },
            'u' => {
                yy -= line.Val;
                aimm -= line.Val;
            },
            else => {
                return error.InvalidInput;
            },
        }
    }

    std.debug.print("Part 1: {}\n", .{xx * yy});
    std.debug.print("Part 2: {}\n", .{xx2 * yy2});
}

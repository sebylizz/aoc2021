const std = @import("std");
const ArrayList = std.ArrayList;
const parseInt = std.fmt.parseInt;

pub fn main() !void {
    try first();
    try second();
    try third();
}

// using stdlib
pub fn first() !void {
    const file = try std.fs.cwd().openFile("input/1.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file_size = try file.getEndPos();
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var nrs = ArrayList(u32).init(allocator);
    defer nrs.deinit();

    var lines = std.mem.splitScalar(u8, buffer, '\n');

    while (lines.next()) |line| {
        if (line.len == 0) continue;
        const nr = try parseInt(u32, line, 10);
        try nrs.append(nr);
    }

    var cnt: i32 = 0;
    for (1..nrs.items.len) |i| {
        if (nrs.items[i - 1] < nrs.items[i])
            cnt += 1;
    }
    std.debug.print("Part 1: {}\n", .{cnt});

    cnt = 0;
    for (2..nrs.items.len - 1) |i| {
        const nr1 = nrs.items[i - 2] + nrs.items[i - 1] + nrs.items[i];
        const nr2 = nrs.items[i - 1] + nrs.items[i] + nrs.items[i + 1];
        if (nr1 < nr2)
            cnt += 1;
    }

    std.debug.print("Part 2: {}\n", .{cnt});
}

// without stdlib, manual buffering
pub fn second() !void {
    const file = try std.fs.cwd().openFile("input/1.txt", .{});
    defer file.close();

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const file_size = try file.getEndPos();
    var i: usize = 0;
    var nrlines: usize = 0;

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    while (i < file_size) {
        if (buffer[i] == '\n') nrlines += 1;
        i += 1;
    }

    var arr = try allocator.alloc(usize, nrlines);
    defer allocator.free(arr);

    var cnt: usize = 0;
    i = 0;
    while (i < file_size) {
        if (i >= file_size or buffer[i] == '\n') {
            i += 1;
            cnt += 1;
            continue;
        }

        arr[cnt] = 0;
        while (i < file_size and buffer[i] != '\n') {
            arr[cnt] = arr[cnt] * 10 + (buffer[i] - '0');
            i += 1;
        }
    }

    cnt = 0;
    var cnt2: usize = 0;
    for (1..nrlines) |idx| {
        if (arr[idx - 1] < arr[idx])
            cnt += 1;
        if (idx == 1 or idx == nrlines - 1) continue;
        const nr1 = arr[idx - 2] + arr[idx - 1] + arr[idx];
        const nr2 = arr[idx - 1] + arr[idx] + arr[idx + 1];
        if (nr1 < nr2)
            cnt2 += 1;
    }
    std.debug.print("Part 1: {}\n", .{cnt});
    std.debug.print("Part 2: {}\n", .{cnt2});
}

// without heap, pure stream
pub fn third() !void {
    const file = try std.fs.cwd().openFile("input/1.txt", .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    var buf_reader = reader.reader();

    var prev: ?u32 = null;
    var window = [4]?u32{ null, null, null, null };
    var idx: usize = 0;
    var part1: usize = 0;
    var part2: usize = 0;

    var line_buffer: [32]u8 = undefined;
    while (try buf_reader.readUntilDelimiterOrEof(&line_buffer, '\n')) |line| {
        const trimmed = std.mem.trim(u8, line, "\r\n");
        if (trimmed.len == 0) continue;
        const current = try std.fmt.parseInt(u32, trimmed, 10);

        if (prev) |p| {
            if (p < current) part1 += 1;
        }
        prev = current;

        window[idx % 4] = current;
        if (idx >= 3) {
            const a = window[(idx - 3) % 4].?;
            const d = current;
            if (a < d) part2 += 1;
        }
        idx += 1;
    }

    std.debug.print("Part 1: {}\n", .{part1});
    std.debug.print("Part 2: {}\n", .{part2});
}

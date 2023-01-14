const std = @import("std");
const io = std.io;

pub fn main() !void {
    const stdin = io.getStdIn().reader();
    var c: [1]u8 = undefined;
    while (true) 
        if (try stdin.read(&c) != 1 or c[0] == 'q') break;
}

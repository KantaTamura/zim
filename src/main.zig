const std = @import("std");
const io = std.io;
const os = std.os;

pub fn main() !void {
    try enableRawMode();
    const stdin = io.getStdIn().reader();
    var c: [1]u8 = undefined;
    while (true) 
        if (try stdin.read(&c) != 1 or c[0] == 'q') break;
}

fn enableRawMode() !void {
    const handler = io.getStdIn().handle;
    var raw = try os.tcgetattr(handler);
    raw.lflag &= ~@as(os.tcflag_t, os.linux.ECHO);
    try os.tcsetattr(handler, os.TCSA.FLUSH, raw);
}

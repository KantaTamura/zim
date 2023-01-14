const std = @import("std");
const io = std.io;
const os = std.os;

// default terminal attribute
var original_termios : os.termios = undefined;
const stdin_handle = io.getStdIn().handle;

pub fn main() !void {
    defer disableRawMode();
    try enableRawMode();
    const stdin = io.getStdIn().reader();
    var c: [1]u8 = undefined;
    while (true) {
        var c_size = try stdin.read(&c);
        if (c_size != 1 or c[0] == 'q') break;
    }
}

fn enableRawMode() !void {
    original_termios = try os.tcgetattr(stdin_handle);
    var raw = original_termios;
    raw.lflag &= ~(os.linux.ECHO | os.linux.ICANON);
    try os.tcsetattr(stdin_handle, os.TCSA.FLUSH, raw);
}

fn disableRawMode() void {
    os.tcsetattr(stdin_handle, os.TCSA.FLUSH, original_termios) catch |err| {
        std.debug.print("{}", .{err});
    };
}

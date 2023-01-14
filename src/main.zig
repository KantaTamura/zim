const std = @import("std");
const io = std.io;
const os = std.os;
const ascii = std.ascii;

// default terminal attribute
var original_termios: os.termios = undefined;
const stdin_handle = io.getStdIn().handle;

pub fn main() !void {
    const stdin = io.getStdIn().reader();
    const stdout = io.getStdOut().writer();
    try enableRawMode();
    defer disableRawMode();
    var buf: [1]u8 = undefined;
    while (true) {
        var buf_size = try stdin.read(&buf);
        if (buf_size != 1 or buf[0] == 'q') break;
        const c = buf[0];
        if (ascii.isControl(c)) {
            try stdout.print("{d}\n", .{c});
        } else {
            try stdout.print("{d} ('{c}')\n", .{ c, c });
        }
    }
}

fn enableRawMode() !void {
    original_termios = try os.tcgetattr(stdin_handle);
    var raw = original_termios;
    raw.lflag &= ~(os.linux.IXON);
    raw.lflag &= ~(os.linux.ECHO | os.linux.ICANON | os.linux.ISIG);
    try os.tcsetattr(stdin_handle, os.TCSA.FLUSH, raw);
}

fn disableRawMode() void {
    os.tcsetattr(stdin_handle, os.TCSA.FLUSH, original_termios) catch |err| {
        std.debug.print("{}", .{err});
    };
}

const std = @import("std");
const io = std.io;
const os = std.os;
const ascii = std.ascii;

// termios cc id
const VMIN  = 6;
const VTIME = 5;

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
        buf[0] = 0;
        _ = try stdin.read(&buf);
        const c = buf[0];
        if (ascii.isControl(c)) {
            try stdout.print("{d}\r\n", .{c});
        } else {
            try stdout.print("{d} ('{c}')\r\n", .{ c, c });
        }
        if (c == 'q') break;
    }
}

fn enableRawMode() !void {
    original_termios = try os.tcgetattr(stdin_handle);
    var raw = original_termios;
    raw.iflag &= ~(os.linux.BRKINT | os.linux.ICRNL | os.linux.INPCK | os.linux.ISTRIP | os.linux.IXON);
    raw.oflag &= ~(os.linux.OPOST);
    raw.cflag |=  (os.linux.CS8);
    raw.lflag &= ~(os.linux.ECHO | os.linux.ICANON | os.linux.IEXTEN | os.linux.ISIG);
    raw.cc[VMIN]  = 0;
    raw.cc[VTIME] = 1;
    try os.tcsetattr(stdin_handle, os.TCSA.FLUSH, raw);
}

fn disableRawMode() void {
    os.tcsetattr(stdin_handle, os.TCSA.FLUSH, original_termios) catch |err| {
        std.debug.print("{}", .{err});
    };
}

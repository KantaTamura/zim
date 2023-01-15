const std = @import("std");
const io = std.io;
const os = std.os;
const debug = std.debug;
const terminal = @import("terminal.zig");
const window_size = @import("window_size.zig");

const stdin = io.getStdIn().reader();
const stdout = io.getStdOut().writer();

pub fn readkey() u8 {
    var buf: [1]u8 = undefined;
    while (true) {
        var nread = stdin.read(&buf) catch debug.panic("{s}\n", .{"read"});
        if (nread == 1) break;
    }
    return buf[0];
}

pub fn processKeyPress() !void {
    var c = readkey();

    switch (c) {
        ctrlKey('q') => {
            try stdout.writeAll("\x1b[2J");
            try stdout.writeAll("\x1b[H");
            os.exit(0);
        },
        else => {},
    }
}

fn ctrlKey(k: u8) u8 {
    return k & 0x1f;
}

pub fn refreshScreen() !void {
    try stdout.writeAll("\x1b[2J");
    try stdout.writeAll("\x1b[H");
    try drawRows();
    try stdout.writeAll("\x1b[H");
}

fn drawRows() !void {
    var y: usize = 0;
    while (y < terminal.editor.size.row) : (y += 1) {
        try stdout.writeAll("~\r\n");
    }
}

pub fn init() !void {
    terminal.editor.size = try window_size.getWindowsSize();
}

const std = @import("std");
const io = std.io;
const os = std.os;
const debug = std.debug;
const Terminal = @import("Terminal.zig");
const AppendBuffer = @import("AppendBuffer.zig");

const stdin = io.getStdIn().reader();
const stdout = io.getStdOut().writer();

const Self = @This();

ter: Terminal,
buf: AppendBuffer,

pub fn init(ter: Terminal, buf: AppendBuffer) Self {
    return Self{
        .ter = ter,
        .buf = buf,
    };
}

pub fn readkey() u8 {
    var buf: [1]u8 = undefined;
    while (true) {
        var nread = stdin.read(&buf) catch debug.panic("{s}\n", .{"read"});
        if (nread == 1) break;
    }
    return buf[0];
}

pub fn processKeyPress(_: Self) !void {
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

pub fn refreshScreen(self: *Self) !void {
    try self.buf.append("\x1b[2J");
    try self.buf.append("\x1b[H");
    try self.drawRows();
    try self.buf.append("\x1b[H");
    try stdout.writeAll(self.buf.memory.items);
}

fn drawRows(self: *Self) !void {
    var y: usize = 0;
    while (y < self.ter.size.row) : (y += 1) {
        try self.buf.append("~");
        if (y < self.ter.size.row - 1) {
            try self.buf.append("\r\n");
        }
    }
}

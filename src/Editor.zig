const std = @import("std");
const io = std.io;
const os = std.os;
const fmt = std.fmt;
const debug = std.debug;
const Terminal = @import("Terminal.zig");
const AppendBuffer = @import("AppendBuffer.zig");

const stdin = io.getStdIn().reader();
const stdout = io.getStdOut().writer();

const Self = @This();

ter: Terminal,
buf: AppendBuffer,
version: []const u8,

pub fn init(ter: Terminal, buf: AppendBuffer, version: []const u8) Self {
    return Self{
        .ter = ter,
        .buf = buf,
        .version = version,
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
    try self.buf.append("\x1b[?25l");
    try self.buf.append("\x1b[H");
    try self.drawRows();
    try self.buf.append("\x1b[H");
    try self.buf.append("\x1b[?25h");
    try stdout.writeAll(self.buf.memory.items);
}

fn drawRows(self: *Self) !void {
    var y: usize = 0;
    while (y < self.ter.size.row) : (y += 1) {
        if (y == @divTrunc(self.ter.size.row, 3)) {
            var welcome: [27]u8 = undefined;
            var fis = io.fixedBufferStream(&welcome);
            var writer = fis.writer();
            try fmt.format(writer, "zim editor -- version {s}", .{self.version});
            var padding = @divTrunc((@intCast(usize, self.ter.size.col) -| welcome.len), 2);
            if (padding > 0) {
                try self.buf.append("~");
                padding -= 1;
            }
            while (padding > 0) : (padding -= 1)
                try self.buf.append(" ");
            try self.buf.append(&welcome);
        } else {
            try self.buf.append("~");
        }
        try self.buf.append("\x1b[K");
        if (y < self.ter.size.row - 1) {
            try self.buf.append("\r\n");
        }
    }
}

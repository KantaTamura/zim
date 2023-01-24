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

cx: i32,
cy: i32,
ter: Terminal,
buf: AppendBuffer,
version: []const u8,

const Key = union(enum) {
    char: u8,
    func: FuncKey,
};

const FuncKey = enum {
    arrow_left,
    arrow_right,
    arrow_up,
    arrow_down,
    home,
    end,
    delete,
    page_up,
    page_down,
};

pub fn init(ter: Terminal, buf: AppendBuffer, version: []const u8) Self {
    return Self{
        .cx = 0,
        .cy = 0,
        .ter = ter,
        .buf = buf,
        .version = version,
    };
}

pub fn readkey() Key {
    var buf: [1]u8 = undefined;
    while (true) {
        var nread = stdin.read(&buf) catch debug.panic("{s}\n", .{"read"});
        if (nread == 1) break;
    }
    if (buf[0] == '\x1b') {
        var seq: [3]u8 = undefined;
        _ = stdin.read(&seq) catch debug.panic("{s}\n", .{"read"});
        if (seq[0] == '[') {
            switch (seq[1]) {
                'A' => return Key{ .func = .arrow_up },
                'B' => return Key{ .func = .arrow_down },
                'C' => return Key{ .func = .arrow_right },
                'D' => return Key{ .func = .arrow_left },
                'H' => return Key{ .func = .home },
                'F' => return Key{ .func = .end },
                '5' => {
                    if (seq[2] != '~') return Key{ .char = '\x1b' };
                    return Key{ .func = .page_up };
                },
                '6' => {
                    if (seq[2] != '~') return Key{ .char = '\x1b' };
                    return Key{ .func = .page_down };
                },
                '1', '7' => {
                    if (seq[2] != '~') return Key{ .char = '\x1b' };
                    return Key{ .func = .home };
                },
                '4', '8' => {
                    if (seq[2] != '~') return Key{ .char = '\x1b' };
                    return Key{ .func = .end };
                },
                '3' => {
                    if (seq[2] != '~') return Key{ .char = '\x1b' };
                    return Key{ .func = .delete };
                },
                else => {},
            }
        } else if (seq[0] == 'O') {
            switch (seq[1]) {
                'H' => return Key{ .func = .home },
                'F' => return Key{ .func = .end },
                else => {},
            }
        }
        return Key{ .char = '\x1b' };
    }
    return Key{ .char = buf[0] };
}

pub fn processKeyPress(self: *Self) !void {
    var c = readkey();

    switch (c) {
        .char => |ch| switch (ch) {
            ctrlKey('q') => {
                try stdout.writeAll("\x1b[2J");
                try stdout.writeAll("\x1b[H");
                os.exit(0);
            },
            else => {},
        },
        .func => |fun| self.moveCursor(fun),
    }
}

fn moveCursor(self: *Self, fun: FuncKey) void {
    switch (fun) {
        .arrow_left => {
            if (self.cx > 0)
                self.cx -= 1;
        },
        .arrow_right => {
            if (self.cx < self.ter.size.col)
                self.cx += 1;
        },
        .arrow_up => {
            if (self.cy > 0)
                self.cy -= 1;
        },
        .arrow_down => {
            if (self.cy < self.ter.size.row)
                self.cy += 1;
        },
        .page_up, .page_down => {
            var times = self.ter.size.row;
            while (times > 0) : (times -= 1) self.moveCursor(if (fun == .page_up) .arrow_up else .arrow_down);
        },
        .home => self.cx = 0,
        .end => self.cx = self.ter.size.col - 1,
        .delete => {},
    }
}

fn ctrlKey(k: u8) u8 {
    return k & 0x1f;
}

pub fn refreshScreen(self: *Self) !void {
    try self.buf.append("\x1b[?25l");
    try self.buf.append("\x1b[H");
    try self.drawRows();
    var cursor: [1024]u8 = undefined;
    var fis = io.fixedBufferStream(&cursor);
    var writer = fis.writer();
    try fmt.format(writer, "\x1b[{d};{d}H", .{ self.cx + 1, self.cy + 1 });
    var length: usize = 0;
    while (length < cursor.len) : (length += 1) if (cursor[length] == 'H') break;
    try self.buf.append(cursor[0 .. length + 1]);
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

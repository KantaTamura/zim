const std = @import("std");
const os = std.os;
const io = std.io;
const fmt = std.fmt;
const debug = std.debug;
const editor = @import("editor.zig");

const stdin_handle = io.getStdIn().handle;
const stdin = io.getStdIn().reader();
const stdout = io.getStdOut().writer();

pub const Size = struct {
    row: i32,
    col: i32,
};

pub fn getWindowsSize() !Size {
    var ws: os.linux.winsize = undefined;
    if (os.linux.ioctl(stdin_handle, os.linux.T.IOCGWINSZ, @ptrToInt(&ws)) == -1 or ws.ws_col == 0) {
        try stdout.writeAll("\x1b[999C\x1b[999B");
        return try getCursorPosition();
    }
    return Size{
        .row = ws.ws_row,
        .col = ws.ws_col,
    };
}

fn getCursorPosition() !Size {
    try stdout.writeAll("\x1b[6n\r\n");
    var buf: [1]u8 = undefined;
    var read: [32]u8 = undefined;
    var i: usize = 0;
    while (i < @sizeOf(@TypeOf(read)) - 1) : (i += 1) {
        var nread = stdin.read(&buf) catch debug.panic("{s}\n", .{"read"});
        if (nread != 1) break;
        read[i] = buf[0];
        if (read[i] == 'R') {
            read[i] = ';';
            break;
        }
    }
    if (read[0] != '\x1b' or read[1] != '[') debug.panic("{s}\n", .{"read"});
    return getPosition(read[2..]);
}

fn getPosition(read: []u8) !Size {
    var fis = io.fixedBufferStream(read);
    var reader = fis.reader();
    var buf1: [5]u8 = undefined;
    var buf2: [5]u8 = undefined;
    var row_buf = try reader.readUntilDelimiter(&buf1, ';');
    var col_buf = try reader.readUntilDelimiter(&buf2, ';');
    return Size{
        .row = try fmt.parseInt(i32, row_buf[0..], 0),
        .col = try fmt.parseInt(i32, col_buf[0..], 0),
    };
}

const std = @import("std");
const os = std.os;
const io = std.io;
const debug = std.debug;

const stdin_handle = io.getStdIn().handle;

pub const Size = struct {
    row: i32,
    col: i32,
};

pub fn getWindowsSize() Size {
    var ws: os.linux.winsize = undefined;
    if (os.linux.ioctl(stdin_handle, os.linux.T.IOCGWINSZ, @ptrToInt(&ws)) == -1 or ws.ws_col == 0) {
        debug.panic("{s}\n", .{"ioctl"});
    }
    return Size{
        .row = ws.ws_row,
        .col = ws.ws_col,
    };
}

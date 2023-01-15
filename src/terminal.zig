const std = @import("std");
const os = std.os;
const io = std.io;
const debug = std.debug;
const window = @import("window_size.zig");

const stdin_handle = io.getStdIn().handle;
const VMIN = 6;
const VTIME = 5;

const Config = struct {
    original_termios: os.termios,
    size: window.Size,
};

pub var editor = Config{
    .original_termios = undefined,
    .size = undefined,
};

pub fn enableRawMode() !void {
    editor.original_termios = try os.tcgetattr(stdin_handle);
    var raw = editor.original_termios;
    raw.iflag &= ~(os.linux.BRKINT | os.linux.ICRNL | os.linux.INPCK | os.linux.ISTRIP | os.linux.IXON);
    raw.oflag &= ~(os.linux.OPOST);
    raw.cflag |= (os.linux.CS8);
    raw.lflag &= ~(os.linux.ECHO | os.linux.ICANON | os.linux.IEXTEN | os.linux.ISIG);
    raw.cc[VMIN] = 0;
    raw.cc[VTIME] = 1;
    try os.tcsetattr(stdin_handle, os.TCSA.FLUSH, raw);
}

pub fn disableRawMode() void {
    os.tcsetattr(stdin_handle, os.TCSA.FLUSH, editor.original_termios) catch {
        std.debug.print("{s}", .{"tcsetattr"});
    };
}

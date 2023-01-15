const std = @import("std");
const os = std.os;
const io = std.io;
const debug = std.debug;
const WindowSize = @import("WindowSize.zig");

const stdin_handle = io.getStdIn().handle;
const VMIN = 6;
const VTIME = 5;

const Self = @This();

original_termios: os.termios,
size: WindowSize,

pub fn enableRawMode() !Self {
    var origin = try os.tcgetattr(stdin_handle);
    var raw = origin;
    raw.iflag &= ~(os.linux.BRKINT | os.linux.ICRNL | os.linux.INPCK | os.linux.ISTRIP | os.linux.IXON);
    raw.oflag &= ~(os.linux.OPOST);
    raw.cflag |= (os.linux.CS8);
    raw.lflag &= ~(os.linux.ECHO | os.linux.ICANON | os.linux.IEXTEN | os.linux.ISIG);
    raw.cc[VMIN] = 0;
    raw.cc[VTIME] = 1;
    try os.tcsetattr(stdin_handle, os.TCSA.FLUSH, raw);
    return Self {
        .original_termios = origin,
        .size = try WindowSize.getWindowsSize(),
    };
}

pub fn disableRawMode(self: Self) void {
    os.tcsetattr(stdin_handle, os.TCSA.FLUSH, self.original_termios) catch {
        std.debug.print("{s}", .{"tcsetattr"});
    };
}

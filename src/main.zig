const std = @import("std");
const io = std.io;
const os = std.os;
const debug = std.debug;
const ascii = std.ascii;
const terminal = @import("terminal.zig");
const window_size = @import("window_size.zig");
const editor = @import("editor.zig");

const stdin = io.getStdIn().reader();
const stdout = io.getStdOut().writer();

pub fn main() !void {
    try terminal.enableRawMode();
    defer terminal.disableRawMode();
    try editor.init();
    while (true) {
        try editor.refreshScreen();
        try editor.processKeyPress();
    }
}

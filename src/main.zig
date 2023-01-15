const std = @import("std");
const Terminal = @import("Terminal.zig");
const Editor = @import("Editor.zig");
const AppendBuffer = @import("AppendBuffer.zig");

const version = "0.0.1";

pub fn main() !void {
    var ter = try Terminal.enableRawMode();
    defer ter.disableRawMode();
    const buffer = AppendBuffer.init();
    defer buffer.deinit();
    var edi = Editor.init(ter, buffer, version);
    while (true) {
        try edi.refreshScreen();
        try edi.processKeyPress();
    }
    std.debug.print("row : {d}, col : {d}\r\n", .{ter.size.row, ter.size.col});
}

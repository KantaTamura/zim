const Terminal = @import("Terminal.zig");
const Editor = @import("Editor.zig");
const AppendBuffer = @import("AppendBuffer.zig");

pub fn main() !void {
    var ter = try Terminal.enableRawMode();
    defer ter.disableRawMode();
    const buffer = AppendBuffer.init();
    defer buffer.deinit();
    var edi = Editor.init(ter, buffer);
    while (true) {
        try edi.refreshScreen();
        try edi.processKeyPress();
    }
}

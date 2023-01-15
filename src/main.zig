const std = @import("std");
const io = std.io;
const os = std.os;
const debug = std.debug;
const ascii = std.ascii;

const stdin = io.getStdIn().reader();
const stdout = io.getStdOut().writer();

pub fn main() !void {
    try enableRawMode();
    defer disableRawMode();
    try initEditor();
    while (true) {
        try editorRefreshScreen();
        try editorProcessKeyPress();
    }
}

fn editorReadkey() u8 {
    var buf: [1]u8 = undefined;
    while (true) {
        var nread = stdin.read(&buf) catch debug.panic("{s}\n", .{"read"});
        if (nread == 1) break;
    }
    return buf[0];
}

fn editorProcessKeyPress() !void {
    var c = editorReadkey();

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

fn editorRefreshScreen() !void {
    try stdout.writeAll("\x1b[2J");
    try stdout.writeAll("\x1b[H");
    try editorDrawRows();
    try stdout.writeAll("\x1b[H");
}

fn editorDrawRows() !void {
    var y: usize = 0;
    while (y < editor.size.row) : (y += 1) {
        try stdout.writeAll("~\r\n");
    }
}

fn initEditor() !void {
    editor.size = getWindowsSize();
}

// termios cc id
const VMIN = 6;
const VTIME = 5;

const editorConfig = struct {
    original_termios: os.termios,
    size: windowSize,
};

const windowSize = struct {
    row: i32,
    col: i32,
};

fn getWindowsSize() windowSize {
    var ws: os.linux.winsize = undefined;
    if (os.linux.ioctl(stdin_handle, os.linux.T.IOCGWINSZ, @ptrToInt(&ws)) == -1 or ws.ws_col == 0) {
        debug.panic("{s}\n", .{"ioctl"});
    }
    return windowSize{
        .row = ws.ws_row,
        .col = ws.ws_col,
    };
}

var editor = editorConfig{
    .original_termios = undefined,
    .size = undefined,
};

const stdin_handle = io.getStdIn().handle;

fn enableRawMode() !void {
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

fn disableRawMode() void {
    os.tcsetattr(stdin_handle, os.TCSA.FLUSH, editor.original_termios) catch |err| {
        std.debug.print("{}", .{err});
    };
}

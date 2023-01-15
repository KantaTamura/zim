const std = @import("std");
const debug = std.debug;
const ArrayList = std.ArrayList;
const allocator = std.heap.page_allocator;

const Self = @This();

memory: ArrayList(u8),

pub fn init() Self {
    return Self{
        .memory = ArrayList(u8).init(allocator),
    };
}

pub fn deinit(self: Self) void {
    self.memory.deinit();
}

pub fn append(self: Self, str: []u8) !void {
    try self.memory.appendSlice(str);
}
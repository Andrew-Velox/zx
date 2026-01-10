const std = @import("std");
const zx = @import("zx");
const Message = struct {
    text: []const u8,
    username: []const u8,
};

var messages = std.ArrayList(Message).empty;

const SocketData = struct {
    username: []const u8,
};

/// HTTP GET handler - upgrades the connection to WebSocket
pub fn GET(ctx: zx.RouteContext) !void {
    // Get username from query param
    const username = ctx.request.searchParams.get("name") orelse "Anonymous";

    try ctx.socket.upgrade(SocketData{
        .username = username,
    });
}

/// Called for each message received from the client
pub fn Socket(ctx: zx.SocketCtx(SocketData)) !void {
    // Broadcast message with username prefix
    try ctx.socket.write(try ctx.fmt(
        "{s}: {s}",
        .{ ctx.data.username, ctx.message },
    ));

    messages.append(ctx.allocator, .{
        .text = ctx.message,
        .username = ctx.data.username,
    }) catch return;
}

/// Called once when the WebSocket connection opens
pub fn SocketOpen(ctx: zx.SocketOpenCtx(SocketData)) !void {
    try ctx.socket.write(try ctx.fmt(
        "system: {s} joined the chat",
        .{ctx.data.username},
    ));

    for (messages.items) |msg| {
        try ctx.socket.write(try ctx.fmt(
            "{s}: {s}",
            .{ msg.username, msg.text },
        ));
    }
}

/// Called once when the WebSocket connection closes
pub fn SocketClose(ctx: zx.SocketCloseCtx(SocketData)) void {
    std.log.info("Chat: {s} left", .{ctx.data.username});
}

// All HTTP Method?
pub fn Route(ctx: zx.RouteContext) !void {
    ctx.response.setStatus(.ok);
    ctx.response.setHeader("Content-Type", "application/json");
    try ctx.response.json(.{
        .message = "Route",
        .method_str = ctx.request.method_str,
        .method = ctx.request.method,
    }, .{});
}
// Maybe both, if both Route and GET/POST etc exist then Route should be the default for everything else and GET/POST etc should be the specific methods.

// Separate method for HTTP Methods?
// pub fn GET(ctx: zx.RouteContext) !void {
//     ctx.response.setStatus(.ok);
//     ctx.response.setHeader("Content-Type", "application/json");
//     try ctx.response.json(.{
//         .message = "Hello, World!",
//         .method = ctx.request.method,
//     }, .{});
// }

// pub fn POST(ctx: zx.RouteContext) !void {
//     ctx.response.setStatus(.ok);
//     ctx.response.setContentType(.@"application/gzip");
//     try ctx.response.json(.{
//         .message = "Hello, World!",
//         .method = ctx.request.method,
//     }, .{});
// }

// pub fn PUT(ctx: zx.RouteContext) !void {
//     ctx.response.setStatus(.ok);
//     ctx.response.setHeader("Content-Type", "application/json");
//     try ctx.response.json(.{
//         .message = "Hello, World!",
//         .method = ctx.request.method,
//     }, .{});
// }

const zx = @import("zx");

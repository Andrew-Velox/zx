const std = @import("std");
const httpz = @import("httpz");
const Headers = @import("Headers.zig");

/// MDN Web API compliant Response wrapper around httpz.Response
/// https://developer.mozilla.org/en-US/docs/Web/API/Response
pub const Response = @This();

/// The underlying httpz response (for advanced/internal access)
inner: *httpz.Response,

/// Contains the Headers object associated with the response.
/// https://developer.mozilla.org/en-US/docs/Web/API/Response/headers
headers: Headers,

/// Creates a new Response wrapper from an httpz Response.
pub fn init(inner: *httpz.Response) Response {
    return .{
        .inner = inner,
        .headers = Headers.fromResponse(inner),
    };
}

/// Returns the response body bytes.
/// Note: This is dynamic and computed from the response state.
pub fn body(self: *const Response) ?[]const u8 {
    const buffered = self.inner.buffer.writer.buffered();
    if (buffered.len > 0) return buffered;
    if (self.inner.body.len > 0) return self.inner.body;
    return null;
}

/// Returns whether the body has been written.
pub fn bodyUsed(self: *const Response) bool {
    return self.inner.written;
}

/// Returns true if the response was successful (status 200-299).
pub fn ok(self: *const Response) bool {
    return self.inner.status >= 200 and self.inner.status <= 299;
}

/// Returns true if the response is a redirect (status 300-399).
pub fn redirected(self: *const Response) bool {
    return self.inner.status >= 300 and self.inner.status <= 399;
}

/// Returns the status code of the response.
pub fn status(self: *const Response) u16 {
    return self.inner.status;
}

/// Returns the status message for the status code.
pub fn statusText(self: *const Response) []const u8 {
    return statusCodeToText(self.inner.status);
}

/// Creates a redirect response.
pub fn redirect(self: *const Response, location: []const u8, redirect_status: ?u16) Response {
    const stat = redirect_status orelse 302;
    self.inner.status = stat;
    self.inner.header("Location", location);
    return Response.init(self.inner);
}

/// Creates a JSON response.
pub fn jsonStatic(inner: *httpz.Response, value: anytype) !Response {
    try inner.json(value, .{});
    return Response.init(inner);
}

/// Sets the response status code.
pub fn setStatus(self: *const Response, stat: u16) void {
    self.inner.status = stat;
}

/// Sets the response status using std.http.Status enum.
pub fn setHttpStatus(self: *const Response, stat: std.http.Status) void {
    self.inner.setStatus(stat);
}

/// Sets the response body directly.
pub fn setBody(self: *const Response, content: []const u8) void {
    self.inner.body = content;
}

/// Sets a header on the response.
pub fn setHeader(self: *const Response, name: []const u8, value: []const u8) void {
    self.inner.header(name, value);
}

/// Sets the Content-Type header.
pub fn setContentType(self: *const Response, content_type: httpz.ContentType) void {
    self.inner.content_type = content_type;
}

/// Writes JSON data to the response body.
pub fn json(self: *const Response, value: anytype) !void {
    try self.inner.json(value, .{});
}

/// Sets a cookie on the response.
pub fn setCookie(self: *const Response, name: []const u8, value: []const u8, opts: CookieOptions) !void {
    try self.inner.setCookie(name, value, .{
        .path = opts.path,
        .domain = opts.domain,
        .max_age = opts.max_age,
        .secure = opts.secure,
        .http_only = opts.http_only,
        .partitioned = opts.partitioned,
        .same_site = if (opts.same_site) |ss| switch (ss) {
            .lax => .lax,
            .strict => .strict,
            .none => .none,
        } else null,
    });
}

/// Gets the response writer for streaming content.
pub fn writer(self: *const Response) *std.Io.Writer {
    return self.inner.writer();
}

/// Writes a chunk for chunked transfer encoding.
pub fn chunk(self: *const Response, data: []const u8) !void {
    try self.inner.chunk(data);
}

pub const CookieOptions = struct {
    path: []const u8 = "",
    domain: []const u8 = "",
    max_age: ?i32 = null,
    secure: bool = false,
    http_only: bool = false,
    partitioned: bool = false,
    same_site: ?SameSite = null,

    pub const SameSite = enum {
        lax,
        strict,
        none,
    };
};

fn statusCodeToText(code: u16) []const u8 {
    return switch (code) {
        100 => "Continue",
        101 => "Switching Protocols",
        102 => "Processing",
        103 => "Early Hints",
        200 => "OK",
        201 => "Created",
        202 => "Accepted",
        203 => "Non-Authoritative Information",
        204 => "No Content",
        205 => "Reset Content",
        206 => "Partial Content",
        207 => "Multi-Status",
        208 => "Already Reported",
        226 => "IM Used",
        300 => "Multiple Choices",
        301 => "Moved Permanently",
        302 => "Found",
        303 => "See Other",
        304 => "Not Modified",
        305 => "Use Proxy",
        307 => "Temporary Redirect",
        308 => "Permanent Redirect",
        400 => "Bad Request",
        401 => "Unauthorized",
        402 => "Payment Required",
        403 => "Forbidden",
        404 => "Not Found",
        405 => "Method Not Allowed",
        406 => "Not Acceptable",
        407 => "Proxy Authentication Required",
        408 => "Request Timeout",
        409 => "Conflict",
        410 => "Gone",
        411 => "Length Required",
        412 => "Precondition Failed",
        413 => "Payload Too Large",
        414 => "URI Too Long",
        415 => "Unsupported Media Type",
        416 => "Range Not Satisfiable",
        417 => "Expectation Failed",
        418 => "I'm a teapot",
        421 => "Misdirected Request",
        422 => "Unprocessable Entity",
        423 => "Locked",
        424 => "Failed Dependency",
        425 => "Too Early",
        426 => "Upgrade Required",
        428 => "Precondition Required",
        429 => "Too Many Requests",
        431 => "Request Header Fields Too Large",
        451 => "Unavailable For Legal Reasons",
        500 => "Internal Server Error",
        501 => "Not Implemented",
        502 => "Bad Gateway",
        503 => "Service Unavailable",
        504 => "Gateway Timeout",
        505 => "HTTP Version Not Supported",
        506 => "Variant Also Negotiates",
        507 => "Insufficient Storage",
        508 => "Loop Detected",
        510 => "Not Extended",
        511 => "Network Authentication Required",
        else => "Unknown",
    };
}

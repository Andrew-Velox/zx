const std = @import("std");
const httpz = @import("httpz");

/// MDN Web API compliant Headers wrapper.
/// https://developer.mozilla.org/en-US/docs/Web/API/Headers
pub const Headers = @This();

response: ?*httpz.Response = null,
request: ?*httpz.Request = null,

/// Creates a read-write Headers wrapper from an httpz Response.
pub fn fromResponse(response: *httpz.Response) Headers {
    return .{ .response = response };
}

/// Creates a read-only Headers wrapper from an httpz Request.
pub fn fromRequest(request: *httpz.Request) Headers {
    return .{ .request = request };
}

/// Returns true if this Headers instance is read-only (from request).
pub fn isReadOnly(self: *const Headers) bool {
    return self.request != null;
}

/// Returns the value of the header with the specified name.
pub fn get(self: *const Headers, name: []const u8) ?[]const u8 {
    if (self.request) |req| return req.headers.get(name);
    if (self.response) |res| return res.headers.get(name);
    return null;
}

/// Returns whether a header with the specified name exists.
pub fn has(self: *const Headers, name: []const u8) bool {
    if (self.request) |req| return req.headers.has(name);
    if (self.response) |res| return res.headers.has(name);
    return false;
}

/// Returns an iterator over all key/value pairs.
pub fn entries(self: *const Headers) Iterator {
    if (self.request) |req| return req.headers.iterator();
    if (self.response) |res| return res.headers.iterator();
    unreachable;
}

/// Returns an iterator over all keys.
pub fn keys(self: *const Headers) KeyIterator {
    return .{ .inner = self.entries() };
}

/// Returns an iterator over all values.
pub fn values(self: *const Headers) ValueIterator {
    return .{ .inner = self.entries() };
}

/// Returns the value of the Set-Cookie header.
pub fn getSetCookie(self: *const Headers) ?[]const u8 {
    return self.get("set-cookie");
}

/// Appends a new value onto an existing header (response only, no-op for request).
pub fn append(self: *Headers, name: []const u8, value: []const u8) void {
    if (self.response) |res| res.header(name, value);
}

/// Sets a header value (response only, no-op for request).
pub fn set(self: *Headers, name: []const u8, value: []const u8) void {
    if (self.response) |res| res.header(name, value);
}

pub const Iterator = httpz.StringKeyValue.Iterator;

pub const KeyIterator = struct {
    inner: Iterator,

    pub fn next(self: *KeyIterator) ?[]const u8 {
        if (self.inner.next()) |entry| return entry.key;
        return null;
    }
};

pub const ValueIterator = struct {
    inner: Iterator,

    pub fn next(self: *ValueIterator) ?[]const u8 {
        if (self.inner.next()) |entry| return entry.value;
        return null;
    }
};

const std = @import("std");
const httpz = @import("httpz");
const Headers = @import("Headers.zig");

/// MDN Web API compliant Request wrapper around httpz.Request
/// https://developer.mozilla.org/en-US/docs/Web/API/Request
pub const Request = @This();

/// The underlying httpz request (for advanced/internal access)
inner: *httpz.Request,

/// Contains the URL of the request as a string.
/// https://developer.mozilla.org/en-US/docs/Web/API/Request/url
url: []const u8,

/// Contains the request's method.
/// https://developer.mozilla.org/en-US/docs/Web/API/Request/method
method: Method,
method_str: []const u8,

/// Contains the path of the request.
/// https://foo.com/bar/baz -> bar/baz
pathname: []const u8,

/// Contains the Referer header value.
/// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Referer
referrer: []const u8,

/// Contains the search portion of the URL.
/// https://foo.com/bar/baz?q=qux -> q=qux
search: []const u8,

/// Contains the search parameters of the URL.
/// https://foo.com/bar/baz?q=qux -> URLSearchParams{ .inner = inner.url.query }
searchParams: URLSearchParams,

/// Contains the headers of the request.
/// https://developer.mozilla.org/en-US/docs/Web/API/Request/headers
headers: Headers,
cookies: Cookies,

address: std.net.Address,
protocol: Protocol,

/// Creates a new Request wrapper from an httpz Request.
pub fn init(inner: *httpz.Request) Request {
    return .{
        .inner = inner,
        .url = inner.url.raw,
        .pathname = inner.url.path,
        .referrer = inner.headers.get("referer") orelse "",
        .search = inner.url.query,
        .searchParams = URLSearchParams{ .inner = inner.query() catch unreachable },
        .headers = Headers.fromRequest(@constCast(inner)),
        .cookies = Cookies{ .header_value = inner.headers.get("cookie") orelse "" },
        .method_str = inner.method_string,
        .method = switch (inner.method) {
            .GET => .GET,
            .HEAD => .HEAD,
            .POST => .POST,
            .PUT => .PUT,
            .DELETE => .DELETE,
            .CONNECT => .CONNECT,
            .OPTIONS => .OPTIONS,
            .PATCH => .PATCH,
            .OTHER => .OTHER,
        },
        .address = inner.address,
        .protocol = switch (inner.protocol) {
            .HTTP10 => .HTTP10,
            .HTTP11 => .HTTP11,
        },
    };
}

/// Returns the request body bytes.
pub fn text(self: *const Request) ?[]const u8 {
    return self.inner.body();
}

/// Parses the request body as JSON into a specific type.
pub fn json(self: *const Request, comptime T: type) !?T {
    return try @constCast(self.inner).json(T);
}

/// Returns the form data from the request body (URL-encoded).
pub fn formData(self: *const Request) !FormData {
    const inner_fd = try @constCast(self.inner).formData();
    return FormData{ .inner = inner_fd };
}

/// Returns the multipart form data from the request body.
pub fn multiFormData(self: *const Request) !MultiFormData {
    const inner_mfd = try @constCast(self.inner).multiFormData();
    return MultiFormData{ .inner = inner_mfd };
}

/// Returns a URL parameter by name (from route matching).
pub fn getParam(self: *const Request, name: []const u8) ?[]const u8 {
    return self.inner.param(name);
}

pub const Method = enum {
    GET,
    HEAD,
    POST,
    PUT,
    DELETE,
    CONNECT,
    OPTIONS,
    PATCH,
    OTHER,
};

pub const Protocol = enum {
    HTTP10,
    HTTP11,
};

/// Cookie accessor - parses cookies from the Cookie header.
pub const Cookies = struct {
    header_value: []const u8,

    /// Get a cookie value by name.
    pub fn get(self: Cookies, name: []const u8) ?[]const u8 {
        var it = std.mem.splitScalar(u8, self.header_value, ';');
        while (it.next()) |kv| {
            const trimmed = std.mem.trimLeft(u8, kv, " ");
            if (name.len >= trimmed.len) continue;
            if (!std.mem.startsWith(u8, trimmed, name)) continue;
            if (trimmed[name.len] != '=') continue;
            return trimmed[name.len + 1 ..];
        }
        return null;
    }
};

/// Query parameters wrapper.
pub const URLSearchParams = struct {
    inner: *httpz.key_value.StringKeyValue,

    pub fn get(self: URLSearchParams, name: []const u8) ?[]const u8 {
        return self.inner.get(name);
    }

    pub fn has(self: URLSearchParams, name: []const u8) bool {
        return self.inner.has(name);
    }

    pub fn iterator(self: URLSearchParams) Iterator {
        return .{ .inner = self.inner.iterator() };
    }

    pub const Iterator = struct {
        inner: httpz.key_value.StringKeyValue.Iterator,

        pub const Entry = struct {
            key: []const u8,
            value: []const u8,
        };

        pub fn next(self: *Iterator) ?Entry {
            if (self.inner.next()) |kv| {
                return .{ .key = kv.key, .value = kv.value };
            }
            return null;
        }
    };
};

/// Form data wrapper for URL-encoded form data.
pub const FormData = struct {
    inner: *httpz.key_value.StringKeyValue,

    pub fn get(self: FormData, name: []const u8) ?[]const u8 {
        return self.inner.get(name);
    }

    pub fn has(self: FormData, name: []const u8) bool {
        return self.inner.has(name);
    }

    pub fn iterator(self: FormData) Iterator {
        return .{ .inner = self.inner.iterator() };
    }

    pub const Iterator = struct {
        inner: httpz.key_value.StringKeyValue.Iterator,

        pub const Entry = struct {
            key: []const u8,
            value: []const u8,
        };

        pub fn next(self: *Iterator) ?Entry {
            if (self.inner.next()) |kv| {
                return .{ .key = kv.key, .value = kv.value };
            }
            return null;
        }
    };
};

/// Multipart form data wrapper.
pub const MultiFormData = struct {
    inner: *httpz.key_value.MultiFormKeyValue,

    pub fn get(self: MultiFormData, name: []const u8) ?Entry {
        if (self.inner.get(name)) |field| {
            return .{ .value = field.value, .filename = field.filename };
        }
        return null;
    }

    pub fn has(self: MultiFormData, name: []const u8) bool {
        return self.inner.has(name);
    }

    pub fn iterator(self: MultiFormData) Iterator {
        return .{ .inner = self.inner.iterator() };
    }

    pub const Entry = struct {
        value: []const u8,
        filename: ?[]const u8,
    };

    pub const Iterator = struct {
        inner: httpz.key_value.MultiFormKeyValue.Iterator,

        pub const IterEntry = struct {
            key: []const u8,
            value: []const u8,
            filename: ?[]const u8,
        };

        pub fn next(self: *Iterator) ?IterEntry {
            if (self.inner.next()) |kv| {
                return .{
                    .key = kv.key,
                    .value = kv.value.value,
                    .filename = kv.value.filename,
                };
            }
            return null;
        }
    };
};

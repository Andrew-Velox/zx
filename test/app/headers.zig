const std = @import("std");
const Headers = @import("zx").Headers;

test "Headers: empty headers - get returns null" {
    const headers = Headers{};
    try std.testing.expectEqual(null, headers.get("content-type"));
}

test "Headers: empty headers - has returns false" {
    const headers = Headers{};
    try std.testing.expectEqual(false, headers.has("content-type"));
}

test "Headers: isReadOnly - response headers are writable" {
    const headers = Headers{ .response = null };
    try std.testing.expectEqual(false, headers.isReadOnly());
}

test "Headers: getSetCookie delegates to get" {
    const headers = Headers{};
    try std.testing.expectEqual(null, headers.getSetCookie());
}

test "Headers: write methods are no-op on empty headers" {
    var headers = Headers{};
    headers.append("x-test", "value");
    headers.set("x-test", "value");
}

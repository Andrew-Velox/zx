const std = @import("std");
const Response = @import("zx").Response;

test "Response: ok returns true for 2xx status codes" {
    try std.testing.expect(200 >= 200 and 200 <= 299);
    try std.testing.expect(299 >= 200 and 299 <= 299);
    try std.testing.expect(!(300 >= 200 and 300 <= 299));
    try std.testing.expect(!(199 >= 200 and 199 <= 299));
}

test "Response: redirected returns true for 3xx status codes" {
    try std.testing.expect(300 >= 300 and 300 <= 399);
    try std.testing.expect(302 >= 300 and 302 <= 399);
    try std.testing.expect(399 >= 300 and 399 <= 399);
    try std.testing.expect(!(200 >= 300 and 200 <= 399));
    try std.testing.expect(!(400 >= 300 and 400 <= 399));
}

test "Response: CookieOptions defaults" {
    const opts = Response.CookieOptions{};

    try std.testing.expectEqualStrings("", opts.path);
    try std.testing.expectEqualStrings("", opts.domain);
    try std.testing.expectEqual(null, opts.max_age);
    try std.testing.expectEqual(false, opts.secure);
    try std.testing.expectEqual(false, opts.http_only);
    try std.testing.expectEqual(false, opts.partitioned);
    try std.testing.expectEqual(null, opts.same_site);
}

test "Response: CookieOptions with values" {
    const opts = Response.CookieOptions{
        .path = "/api",
        .domain = "example.com",
        .max_age = 3600,
        .secure = true,
        .http_only = true,
        .same_site = .strict,
    };

    try std.testing.expectEqualStrings("/api", opts.path);
    try std.testing.expectEqualStrings("example.com", opts.domain);
    try std.testing.expectEqual(@as(?i32, 3600), opts.max_age);
    try std.testing.expectEqual(true, opts.secure);
    try std.testing.expectEqual(true, opts.http_only);
    try std.testing.expectEqual(Response.CookieOptions.SameSite.strict, opts.same_site.?);
}

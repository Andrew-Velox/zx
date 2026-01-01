const std = @import("std");
const Request = @import("zx").Request;

test "Request: Method enum values" {
    const get = Request.Method.GET;
    const post = Request.Method.POST;
    const put = Request.Method.PUT;
    const delete = Request.Method.DELETE;

    try std.testing.expect(get != post);
    try std.testing.expect(post != put);
    try std.testing.expect(put != delete);
}

test "Request: Protocol enum values" {
    const http10 = Request.Protocol.HTTP10;
    const http11 = Request.Protocol.HTTP11;

    try std.testing.expect(http10 != http11);
}

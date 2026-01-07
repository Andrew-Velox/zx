const std = @import("std");

test {
    _ = @import("zx/ast.zig");
    _ = @import("cli/fmt.zig");
    _ = @import("cli/cli.zig");
    _ = @import("runtime/server/headers.zig");
    _ = @import("runtime/server/request.zig");
    _ = @import("runtime/server/response.zig");
    _ = @import("runtime/server/common.zig");
    _ = @import("runtime/server/routing.zig");
}

pub const std_options = std.Options{
    .log_level = .info,
    .log_scope_levels = &[_]std.log.ScopeLevel{
        .{ .scope = .zx_transpiler, .level = .info },
    },
};

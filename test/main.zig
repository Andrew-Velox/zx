const std = @import("std");

test {
    _ = @import("zx/ast.zig");
    _ = @import("cli/fmt.zig");
    _ = @import("cli/cli.zig");
    _ = @import("app/headers.zig");
    _ = @import("app/request.zig");
    _ = @import("app/response.zig");
}

pub const std_options = std.Options{
    .log_level = .info,
    .log_scope_levels = &[_]std.log.ScopeLevel{
        .{ .scope = .zx_transpiler, .level = .info },
    },
};

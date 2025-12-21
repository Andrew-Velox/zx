pub fn Page(allocator: zx.Allocator) zx.Component {
    const greeting = zx.Component{ .text = "Hello!" };

    var _zx = zx.initWithAllocator(allocator);
    return _zx.zx(
        .section,
        .{
            .allocator = allocator,
            .children = &.{
                (greeting),
                _zx.zx(
                    .p,
                    .{
                        .children = &.{
                            _zx.txt("Greeting: "),
                            _zx.expr(greeting),
                        },
                    },
                ),
                _zx.zx(
                    .div,
                    .{
                        .children = &.{
                            _zx.expr(greeting),
                        },
                    },
                ),
            },
        },
    );
}

const zx = @import("zx");

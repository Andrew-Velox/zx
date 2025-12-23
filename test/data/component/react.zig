pub fn Page(allocator: zx.Allocator) zx.Component {
    const max_count = 10;

    var _zx = zx.allocInit(allocator);
    return _zx.ele(
        .main,
        .{
            .allocator = allocator,
            .children = &.{
                _zx.client(.{ .name = "CounterComponent", .path = "test/data/component/react.tsx", .id = "zx-d21801dd93a6d316561a1f2d43a8f9a7-0" }, .{ .max_count = max_count }),
            },
        },
    );
}

const zx = @import("zx");
// const CounterComponent = @jsImport("react.tsx");

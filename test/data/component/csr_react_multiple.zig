pub fn Page(allocator: zx.Allocator) zx.Component {
    const max_count = 10;

    var _zx = zx.allocInit(allocator);
    return _zx.ele(
        .main,
        .{
            .allocator = allocator,
            .children = &.{
                _zx.client(.{ .name = "CounterComponent", .path = "test/data/component/react.tsx", .id = "zx-d21801dd93a6d316561a1f2d43a8f9a7-0" }, .{ .max_count = max_count }),
                _zx.client(.{ .name = "AnotherComponent", .path = "test/data/component/csr_react_multiple.tsx", .id = "zx-e9c79f618c4d5594d24a0aed36823b4c-1" }, .{}),
                _zx.client(.{ .name = "AnotherComponent", .path = "test/data/component/csr_react_multiple.tsx", .id = "zx-e9c79f618c4d5594d24a0aed36823b4c-2" }, .{}),
                _zx.client(.{ .name = "AnotherSameComponent", .path = "test/data/component/csr_react_multiple.tsx", .id = "zx-3401ac6fae86599b86f70018e2468df3-3" }, .{}),
            },
        },
    );
}

const zx = @import("zx");
// const CounterComponent = @jsImport("react.tsx");
// const AnotherComponent = @jsImport("csr_react_multiple.tsx");
// const AnotherSameComponent = @jsImport("csr_react_multiple.tsx");

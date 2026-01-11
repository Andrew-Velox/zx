pub fn Page(allocator: zx.Allocator) zx.Component {
    // Characters that need HTML escaping
    const double_quote = "\"quoted\"";
    const single_quote = "'single'";
    const less_than = "a < b";
    const greater_than = "a > b";
    const ampersand = "rock & roll";
    const backtick = "`template`";

    // Combinations and edge cases
    const html_tag = "<script>alert('xss')</script>";
    const html_entity = "&amp; &lt; &gt; &quot;";
    const url_with_params = "https://example.com?a=1&b=2&c=<test>";
    const json_like = "{\"key\": \"value\", \"num\": 123}";
    const js_code = "const x = \"test\"; if (a < b && c > d) {}";
    const css_value = "content: \"hello\"; url('image.png')";
    const mixed = "Say \"Hello\" & 'Goodbye' with <tags> & `code`";

    // Unicode and special chars
    const unicode = "你好 مرحبا 🎉 < emoji > test";
    const newlines = "line1\nline2\tline3";
    const null_char = "before\x00after";
    const backslash = "path\\to\\file";

    var _zx = zx.allocInit(allocator);
    return _zx.ele(
        .div,
        .{
            .allocator = allocator,
            .children = &.{
                _zx.ele(
                    .section,
                    .{
                        .attributes = _zx.attrs(.{
                            _zx.attr("id", "text-content"),
                        }),
                        .children = &.{
                            _zx.ele(
                                .h2,
                                .{
                                    .children = &.{
                                        _zx.txt("Text Content Escaping"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "double-quote"),
                                    }),
                                    .children = &.{
                                        _zx.expr(double_quote),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "single-quote"),
                                    }),
                                    .children = &.{
                                        _zx.expr(single_quote),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "less-than"),
                                    }),
                                    .children = &.{
                                        _zx.expr(less_than),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "greater-than"),
                                    }),
                                    .children = &.{
                                        _zx.expr(greater_than),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "ampersand"),
                                    }),
                                    .children = &.{
                                        _zx.expr(ampersand),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "backtick"),
                                    }),
                                    .children = &.{
                                        _zx.expr(backtick),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "html-tag"),
                                    }),
                                    .children = &.{
                                        _zx.expr(html_tag),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "html-entity"),
                                    }),
                                    .children = &.{
                                        _zx.expr(html_entity),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "url"),
                                    }),
                                    .children = &.{
                                        _zx.expr(url_with_params),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "json"),
                                    }),
                                    .children = &.{
                                        _zx.expr(json_like),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "js-code"),
                                    }),
                                    .children = &.{
                                        _zx.expr(js_code),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "css"),
                                    }),
                                    .children = &.{
                                        _zx.expr(css_value),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "mixed"),
                                    }),
                                    .children = &.{
                                        _zx.expr(mixed),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "unicode"),
                                    }),
                                    .children = &.{
                                        _zx.expr(unicode),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "newlines"),
                                    }),
                                    .children = &.{
                                        _zx.expr(newlines),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("class", "backslash"),
                                    }),
                                    .children = &.{
                                        _zx.expr(backslash),
                                    },
                                },
                            ),
                        },
                    },
                ),
                _zx.ele(
                    .section,
                    .{
                        .attributes = _zx.attrs(.{
                            _zx.attr("id", "attributes"),
                        }),
                        .children = &.{
                            _zx.ele(
                                .h2,
                                .{
                                    .children = &.{
                                        _zx.txt("Attribute Escaping"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-double", double_quote),
                                    }),
                                    .children = &.{
                                        _zx.txt("double quote in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-single", single_quote),
                                    }),
                                    .children = &.{
                                        _zx.txt("single quote in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-less", less_than),
                                    }),
                                    .children = &.{
                                        _zx.txt("less than in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-greater", greater_than),
                                    }),
                                    .children = &.{
                                        _zx.txt("greater than in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-amp", ampersand),
                                    }),
                                    .children = &.{
                                        _zx.txt("ampersand in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-backtick", backtick),
                                    }),
                                    .children = &.{
                                        _zx.txt("backtick in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-html", html_tag),
                                    }),
                                    .children = &.{
                                        _zx.txt("html tag in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-entity", html_entity),
                                    }),
                                    .children = &.{
                                        _zx.txt("html entity in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-url", url_with_params),
                                    }),
                                    .children = &.{
                                        _zx.txt("url in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-json", json_like),
                                    }),
                                    .children = &.{
                                        _zx.txt("json in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-js", js_code),
                                    }),
                                    .children = &.{
                                        _zx.txt("js code in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-css", css_value),
                                    }),
                                    .children = &.{
                                        _zx.txt("css in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-mixed", mixed),
                                    }),
                                    .children = &.{
                                        _zx.txt("mixed in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-unicode", unicode),
                                    }),
                                    .children = &.{
                                        _zx.txt("unicode in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-newlines", newlines),
                                    }),
                                    .children = &.{
                                        _zx.txt("newlines in attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-backslash", backslash),
                                    }),
                                    .children = &.{
                                        _zx.txt("backslash in attr"),
                                    },
                                },
                            ),
                        },
                    },
                ),
                _zx.ele(
                    .section,
                    .{
                        .attributes = _zx.attrs(.{
                            _zx.attr("id", "inline-attrs"),
                        }),
                        .children = &.{
                            _zx.ele(
                                .h2,
                                .{
                                    .children = &.{
                                        _zx.txt("Inline Attribute Values"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("title", "Say 'hello' & 'goodbye'"),
                                    }),
                                    .children = &.{
                                        _zx.txt("inline escaped"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-value", "<script>test</script>"),
                                    }),
                                    .children = &.{
                                        _zx.txt("inline html"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-query", "?a=1&b=2"),
                                    }),
                                    .children = &.{
                                        _zx.txt("inline query"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .input,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("type", "text"),
                                        _zx.attr("placeholder", "Enter 'value' here"),
                                    }),
                                },
                            ),
                            _zx.ele(
                                .a,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("href", "https://example.com?q=a<b&x=1"),
                                    }),
                                    .children = &.{
                                        _zx.txt("url attr"),
                                    },
                                },
                            ),
                            _zx.expr(null_char),
                        },
                    },
                ),
                _zx.ele(
                    .section,
                    .{
                        .attributes = _zx.attrs(.{
                            _zx.attr("id", "pre-code"),
                        }),
                        .children = &.{
                            _zx.ele(
                                .h2,
                                .{
                                    .children = &.{
                                        _zx.txt("Pre/Code Elements"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .code,
                                .{
                                    .children = &.{
                                        _zx.txt("\"quote\" &  'single'"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .pre,
                                .{
                                    .escaping = .none,
                                    .children = &.{
                                        _zx.txt("                    \n"),
                                        _zx.expr(
                                            \\const x = "test";
                                            \\if (a < b && c > d) {
                                            \\    console.log('hello');
                                            \\}
                                        ),
                                        _zx.txt("                "),
                                    },
                                },
                            ),
                            _zx.ele(
                                .code,
                                .{
                                    .children = &.{
                                        _zx.expr(html_tag),
                                    },
                                },
                            ),
                            _zx.ele(
                                .pre,
                                .{
                                    .children = &.{
                                        _zx.expr(js_code),
                                    },
                                },
                            ),
                        },
                    },
                ),
                _zx.ele(
                    .section,
                    .{
                        .attributes = _zx.attrs(.{
                            _zx.attr("id", "edge-cases"),
                        }),
                        .children = &.{
                            _zx.ele(
                                .h2,
                                .{
                                    .children = &.{
                                        _zx.txt("Edge Cases"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-empty", ""),
                                    }),
                                    .children = &.{
                                        _zx.txt("empty attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-space", " "),
                                    }),
                                    .children = &.{
                                        _zx.txt("space attr"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-only-special", "<>&\'"),
                                    }),
                                    .children = &.{
                                        _zx.txt("only special chars"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .children = &.{
                                        _zx.expr("<>&\"'"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .children = &.{
                                        _zx.txt("Text with \"quotes\" in the middle"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .children = &.{
                                        _zx.txt("Multiple: \" \" \" quotes \" \" \""),
                                    },
                                },
                            ),
                            _zx.ele(
                                .p,
                                .{
                                    .children = &.{
                                        _zx.txt("&amp;&lt;&gt; - raw entities"),
                                    },
                                },
                            ),
                            _zx.ele(
                                .div,
                                .{
                                    .attributes = _zx.attrs(.{
                                        _zx.attr("data-nested", "{'inner': 'value'}"),
                                    }),
                                    .children = &.{
                                        _zx.txt("nested json attr"),
                                    },
                                },
                            ),
                        },
                    },
                ),
            },
        },
    );
}

const zx = @import("zx");

const httpz = @import("httpz");
const std = @import("std");
const Request = @import("app/Request.zig");
const Response = @import("app/Response.zig");

/// Base context structure that provides access to request/response objects and allocators.
/// This is the foundation for both PageContext and LayoutContext, providing common functionality
/// for handling HTTP requests and managing memory allocation.
pub const BaseContext = struct {
    /// The HTTP request object (MDN Web API compliant wrapper)
    /// Provides access to headers, body, query params, form data, cookies, etc.
    /// Use `.inner` to access the underlying httpz.Request for advanced usage.
    request: Request,
    /// The HTTP response object (MDN Web API compliant wrapper)
    /// Used to set status, headers, body, and cookies.
    /// Use `.inner` to access the underlying httpz.Response for advanced usage.
    response: Response,
    /// Global allocator passed from the app, only cleared when the app is deinitialized.
    /// Should be used for allocating memory that needs to persist across requests.
    /// Make sure to free the memory on your own that is allocated with this allocator.
    allocator: std.mem.Allocator,
    /// Allocator for allocating memory that needs to be freed after the request is processed.
    /// This allocator is cleared automatically when the request is processed, so you don't need
    /// to manually free memory allocated with this allocator. Use this for temporary allocations
    /// that are only needed during request processing.
    arena: std.mem.Allocator,
    /// Optional parent context, used for nested layouts or hierarchical context passing
    parent_ctx: ?*BaseContext = null,

    /// Initialize a new BaseContext with the given request, response, and allocator.
    /// Accepts either httpz types (*httpz.Request/*httpz.Response) or wrapper types (Request/Response).
    /// The arena allocator is automatically set from the request's arena.
    pub fn init(req: anytype, res: anytype, alloc: std.mem.Allocator) BaseContext {
        const ReqType = @TypeOf(req);
        const ResType = @TypeOf(res);

        // Handle Request wrapper type
        const request: Request = if (ReqType == Request)
            req
        else if (ReqType == *httpz.Request)
            Request.init(req)
        else
            @compileError("Expected Request or *httpz.Request, got " ++ @typeName(ReqType));

        // Handle Response wrapper type
        const response: Response = if (ResType == Response)
            res
        else if (ResType == *httpz.Response)
            Response.init(res)
        else
            @compileError("Expected Response or *httpz.Response, got " ++ @typeName(ResType));

        return .{
            .request = request,
            .response = response,
            .allocator = alloc,
            .arena = request.inner.arena,
        };
    }

    /// Deinitialize the context, freeing any resources allocated with the global allocator.
    /// Note: The arena allocator is automatically cleaned up by the request handler.
    pub fn deinit(self: *BaseContext) void {
        self.allocator.destroy(self);
    }
};

/// Context passed to page components. Provides access to the current HTTP request and response,
/// as well as allocators for memory management.
///
/// Usage in a page component:
/// ```zig
/// pub fn Page(ctx: zx.PageContext) zx.Component {
///     const allocator = ctx.arena; // Use arena for temporary allocations
///     // Access request data via MDN-compliant API
///     const method = ctx.request.method();
///     const url = ctx.request.url();
///     // Or access underlying httpz types directly
///     const path = ctx.request.inner.url.path;
///     // Render component
///     return <div>Hello</div>;
/// }
/// ```
pub const PageContext = BaseContext;

/// Context passed to layout components. Provides access to the current HTTP request and response,
/// as well as allocators for memory management. Layouts wrap page components and can be nested.
///
/// Usage in a layout component:
/// ```zig
/// pub fn Layout(ctx: zx.LayoutContext, children: zx.Component) zx.Component {
///     return (
///         <html>
///             <head><title>My App</title></head>
///             <body>{children}</body>
///         </html>
///     );
/// }
/// ```
pub const LayoutContext = BaseContext;
pub const NotFoundContext = BaseContext;

pub const ErrorContext = struct {
    /// The HTTP request object (MDN Web API compliant wrapper)
    request: Request,
    /// The HTTP response object (MDN Web API compliant wrapper)
    response: Response,
    /// Global allocator
    allocator: std.mem.Allocator,
    /// Arena allocator for request-scoped allocations
    arena: std.mem.Allocator,
    /// The error that occurred
    err: anyerror,

    pub fn init(req: *httpz.Request, res: *httpz.Response, alloc: std.mem.Allocator, err: anyerror) ErrorContext {
        return .{
            .request = Request.init(req),
            .response = Response.init(res),
            .allocator = alloc,
            .arena = req.arena,
            .err = err,
        };
    }

    pub fn deinit(self: *ErrorContext) void {
        self.allocator.destroy(self);
    }
};

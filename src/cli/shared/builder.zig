const std = @import("std");
const tui = @import("../../tui/main.zig");
const Colors = tui.Colors;
const log = std.log.scoped(.cli);

const RESTART_COOLDOWN_NS = std.time.ns_per_ms * 10;

pub const BuildWatcher = struct {
    allocator: std.mem.Allocator,
    builder_stderr: std.fs.File,
    should_restart: bool,
    mutex: std.Thread.Mutex,
    first_build_done: bool,
    restart_pending: bool,
    last_restart_time_ns: i128,
    binary_path: []const u8,
    last_binary_mtime: i128,
    build_completed: bool,
    writer: *std.Io.Writer,
    show_rebuild_messages: bool, // Whether to print "Rebuilding..." messages

    pub fn init(
        allocator: std.mem.Allocator,
        builder_stderr: std.fs.File,
        binary_path: []const u8,
        initial_mtime: i128,
        writer: *std.Io.Writer,
        show_rebuild_messages: bool,
    ) BuildWatcher {
        return .{
            .allocator = allocator,
            .builder_stderr = builder_stderr,
            .should_restart = false,
            .mutex = .{},
            .first_build_done = false,
            .restart_pending = false,
            .last_restart_time_ns = 0,
            .binary_path = binary_path,
            .last_binary_mtime = initial_mtime,
            .build_completed = false,
            .writer = writer,
            .show_rebuild_messages = show_rebuild_messages,
        };
    }

    pub fn shouldRestart(self: *BuildWatcher) bool {
        self.mutex.lock();
        defer self.mutex.unlock();
        const result = self.should_restart;
        self.should_restart = false;
        self.build_completed = false;
        return result;
    }

    pub fn markRestartComplete(self: *BuildWatcher, new_mtime: i128) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.restart_pending = false;
        self.last_restart_time_ns = std.time.nanoTimestamp();
        self.last_binary_mtime = new_mtime;
    }
};

pub fn watchBuildOutput(watcher: *BuildWatcher) !void {
    var buf: [8192]u8 = undefined;
    var pattern_buf = std.ArrayList(u8).empty;
    defer pattern_buf.deinit(watcher.allocator);

    log.debug("Build watcher thread started", .{});

    while (true) {
        const bytes_read = watcher.builder_stderr.read(&buf) catch |err| {
            if (err == error.EndOfStream) break;
            log.debug("Error reading stderr: {any}", .{err});
            continue;
        };
        if (bytes_read == 0) break;

        // Print rebuild message when we first receive data (only if enabled)
        watcher.mutex.lock();
        const should_print_start = watcher.show_rebuild_messages and watcher.first_build_done and !watcher.build_completed;
        watcher.mutex.unlock();

        if (should_print_start) {
            watcher.writer.print("{s}Rebuilding ZX App...{s}", .{ Colors.cyan, Colors.reset }) catch {};
            log.debug("Build started", .{});
        }

        // Accumulate to detect "Build Summary:"
        try pattern_buf.appendSlice(watcher.allocator, buf[0..bytes_read]);

        if (pattern_buf.items.len > 1024) {
            const keep_from = pattern_buf.items.len - 512;
            std.mem.copyForwards(u8, pattern_buf.items[0..512], pattern_buf.items[keep_from..]);
            pattern_buf.shrinkRetainingCapacity(512);
        }

        // Detect build completion
        if (std.mem.indexOf(u8, pattern_buf.items, "Build Summary:") != null) {
            const now = std.time.nanoTimestamp();

            log.debug("Build Summary detected", .{});

            const stat = std.fs.cwd().statFile(watcher.binary_path) catch |err| {
                log.debug("Failed to stat binary: {any}", .{err});
                pattern_buf.clearRetainingCapacity();
                continue;
            };

            watcher.mutex.lock();

            const binary_changed = stat.mtime != watcher.last_binary_mtime;
            const already_handled = watcher.build_completed;
            const should_print = watcher.first_build_done;

            if (!already_handled and watcher.first_build_done) {
                if (binary_changed and !watcher.restart_pending) {
                    const time_since_last_restart = now - watcher.last_restart_time_ns;

                    if (time_since_last_restart >= RESTART_COOLDOWN_NS) {
                        watcher.should_restart = true;
                        watcher.restart_pending = true;
                        watcher.last_binary_mtime = stat.mtime;
                        watcher.build_completed = true;
                        log.debug("Build completed, triggering restart", .{});
                    }
                }
            } else if (!watcher.first_build_done) {
                watcher.first_build_done = true;
                watcher.last_binary_mtime = stat.mtime;
                watcher.last_restart_time_ns = std.time.nanoTimestamp();
                log.debug("First build detected", .{});
            }

            watcher.mutex.unlock();

            // Print completion message (only if enabled)
            if (should_print and watcher.show_rebuild_messages) {
                watcher.writer.print("\r{s}Rebuilding ZX App... {s}done{s}\x1b[K\n", .{ Colors.cyan, Colors.green, Colors.reset }) catch {};
            }

            pattern_buf.clearRetainingCapacity();
        }
    }
}

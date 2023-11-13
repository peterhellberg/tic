# tic :zap:

A small Zig ⚡ module meant for my own experiments with [TIC-80](https://tic80.com/) 🎮 (based on the [tic80.zig template](https://github.com/nesbox/TIC-80/blob/main/templates/zig/src/tic80.zig))

## Usage

Create a `build.zig.zon` that looks something like this:
```zig
.{
    .name = "tic80-zig-game",
    .version = "0.0.1",
    .paths = .{""},
    .dependencies = .{
        .tic = .{
            .url = "https://github.com/peterhellberg/tic/archive/561f1781861a87ed3e97d5a454632702faeb052a.tar.gz",
            .hash = "1220cd872564f9f56d46bb7477195be8f5b90549c3ce13faf32d5651097dee2d736f",
        },
    },
}
```

> [!NOTE]
> If you leave out the hash then `zig build` will tell you that it is missing the hash, and what it is.

And then you can add the module in your `build.zig` like this:
```zig
// Add the tic module to the executable
exe.addModule("tic", b.dependency("tic", .{}).module("tic"));
```

## Example `build.zig`

> [!IMPORTANT]
> Make sure that you `exe.export_symbol_names` the [TIC-80 Callbacks](https://github.com/nesbox/TIC-80/wiki/API#callbacks) you are using.

```zig
const std = @import("std");

pub fn build(b: *std.Build) !void {
    const exe = b.addExecutable(.{
        .name = "cart",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = .{ .cpu_arch = .wasm32, .os_tag = .wasi },
        .optimize = .ReleaseSmall,
    });

    // Add the tic module to the executable
    exe.addModule("tic", b.dependency("tic", .{}).module("tic"));

    // Add the zlm (Zig Linear Mathemathics) module to the executable
    exe.addModule("zlm", b.dependency("zlm", .{}).module("zlm"));

    // No entry point in the WASM
    exe.entry = .disabled;

    // All the memory below 96kb is reserved for TIC
    // and memory mapped I/O so our own usage must
    // start above the 96kb mark
    exe.global_base = 96 * 1024;
    exe.stack_size = 8192;

    // Four WASM memory pages
    const memory: u64 = 65536 * 4;
    exe.initial_memory = memory;
    exe.max_memory = memory;
    exe.import_memory = true;

    // Export symbols for use by TIC
    exe.export_symbol_names = &[_][]const u8{
        "TIC",
        "BDR",
        "BOOT",
    };

    // Move the cart to the root of the repo
    const move_cart = b.addSystemCommand(&[_][]const u8{
        "mv",
        "zig-out/bin/cart.wasm",
        "cart.wasm",
    });

    move_cart.step.dependOn(b.getInstallStep());

    b.default_step = &move_cart.step;

    b.installArtifact(exe);
}
```

## Links

- https://github.com/nesbox/TIC-80/blob/main/templates/zig/src/tic80.zig
- https://github.com/nesbox/TIC-80
- https://tic80.com/
- https://ziglang.org/

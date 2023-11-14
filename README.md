# tic :zap:

A small [Zig](https://ziglang.org/) ⚡ module, primarily meant for my own experiments with [TIC-80](https://tic80.com/) 🎮

Based on the [tic80.zig template](https://github.com/nesbox/TIC-80/blob/main/templates/zig/src/tic80.zig), with a few small fixes here and there. :bug:

## Usage

You can have `zig build` retrieve the `tic` module if you specify it as a dependency.

### Create a `build.zig.zon` that looks something like this:
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

### Then you can add the module in your `build.zig` like this:
```zig
// Add the tic module to the executable
exe.addModule("tic", b.dependency("tic", .{}).module("tic"));
```

In your `src/main.zig` you should now be able to:
```zig
const tic = @import("tic");
const std = @import("std");

export fn BDR(row: i32) void {
    const v = tic.time() / 99 + @as(f32, @floatFromInt(row)) / 2;
    tic.poke(0x3ff9, @intFromFloat(2 + std.math.sin(v) * 1.2));
}

export fn TIC() void {
    tic.rect(0, 13, 92, 57, 4);
    tic.rect(107, 13, 50, 11, 12);
    tic.rect(107, 60, 49, 11, 12);
    tic.rect(164, 14, 12, 56, 12);
    tic.elli(214, 42, 32, 30, 12);
    tic.elli(214, 42, 18, 18, 0);
    tic.tri(223, 40, 240, 19, 240, 40, 0);
    tic.tri(209, 40, 236, 40, 236, 56, 12);
    tic.rect(236, 40, 4, 25, 0);
    tic.rect(226, 48, 4, 9, 12);
    tic.tri(141, 22, 107, 61, 124, 60, 12);
    tic.tri(124, 60, 139, 22, 157, 24, 12);
    tic.tri(18, 27, 28, 13, 22, 28, 0);
    tic.tri(28, 13, 22, 28, 33, 13, 0);
    tic.tri(19, 57, 8, 70, 13, 70, 0);
    tic.tri(19, 57, 13, 70, 24, 57, 0);
    tic.rect(15, 27, 66, 31, 0);
    tic.tri(3, 83, 49, 26, 43, 56, 4);
    tic.tri(43, 56, 51, 16, 87, 0, 4);
    tic.tri(73, 27, 84, 13, 77, 13, 0);
    tic.tri(77, 13, 64, 31, 73, 27, 0);
    tic.tri(76, 57, 64, 72, 70, 57, 0);
    tic.tri(70, 57, 65, 70, 60, 70, 0);
    if (tic.btn(4)) tic.exit();
}
```

![TIC-80 Zig Example](https://i.imgur.com/TAQVUVE.gif)

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

## Example `cart.wasmp`

> [!IMPORTANT]
> You can only use the `wasmp` format if you run the [TIC-80 Pro Version](https://github.com/nesbox/TIC-80#pro-version)

```lua
-- desc:   TIC-80 Zig Example
-- script: wasm
"
Code is compiled from src/main.zig
into zig-out/bin/cart.wasm

Load it like this:

import binary zig-out/bin/cart.wasm
run

"
-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
```

## Example file structure

<img width="60%" src="https://github.com/peterhellberg/tic/assets/565124/eadbdf7c-18ed-426b-8438-813be3a99aee" />

## Links

- https://github.com/nesbox/TIC-80/blob/main/templates/zig/src/tic80.zig
- https://github.com/nesbox/TIC-80
- https://tic80.com/
- https://ziglang.org/

## License (MIT)

Since **TIC-80** itself is [licensed under MIT](https://github.com/nesbox/TIC-80/blob/main/LICENSE)
it almost goes without saying that this project should be so as well :clipboard:

### TIC-80 License
```
Copyright (c) 2017 Vadim Grigoruk

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the "Software"),
to deal in the Software without restriction, including without limitation
the rights to use, copy, modify, merge, publish, distribute, sublicense,
and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

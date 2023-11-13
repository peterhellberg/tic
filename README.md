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
            .url = "https://github.com/peterhellberg/tic/archive/4174676d28ad432f4caf795be367a1202c9b0476.tar.gz",
        },
    },
}
```

And then you can add the module in your `build.zig` like this:
```zig
// Add the tic module to the executable
exe.addModule("tic", b.dependency("tic", .{}).module("tic"));
```

## Links

- https://github.com/nesbox/TIC-80/blob/main/templates/zig/src/tic80.zig
- https://github.com/nesbox/TIC-80
- https://tic80.com/
- https://ziglang.org/

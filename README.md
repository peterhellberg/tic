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

## Links

- https://github.com/nesbox/TIC-80/blob/main/templates/zig/src/tic80.zig
- https://github.com/nesbox/TIC-80
- https://tic80.com/
- https://ziglang.org/

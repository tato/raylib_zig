```
git submodule add https://github.com/tato/raylib_zig raylib
git submodule update --init --recursive
```

```zig
const raylib = @import("raylib/build.zig");
exe.addPackage(raylib.raylib_pkg);
exe.linkLibrary(raylib.getRaylib(b, mode, target));
```

const std = @import("std");

pub const raylib_pkg = std.build.Pkg{
    .name = "raylib",
    .source = .{ .path = src_dir ++ "/raylib.zig" },
};
pub const raygui_pkg = std.build.Pkg{
    .name = "raygui",
    .source = .{ .path = src_dir ++ "/raygui.zig" },
    .dependencies = &.{raylib_pkg},
};

const raylib_flags = &[_][]const u8{
    "-std=gnu99",
    "-DPLATFORM_DESKTOP",
    "-DGL_SILENCE_DEPRECATION=199309L",
};

pub fn getRaylib(b: *std.build.Builder, mode: std.builtin.Mode, target: std.zig.CrossTarget) *std.build.LibExeObjStep {
    const raylib = b.addStaticLibrary("raylib", raylib_dir ++ "/raylib.h");
    raylib.setBuildMode(mode);
    raylib.setTarget(target);
    raylib.linkLibC();

    raylib.addIncludeDir(raylib_dir);
    raylib.addIncludeDir(raylib_dir ++ "/external/glfw/include");

    raylib.addCSourceFiles(&.{
        raylib_dir ++ "/raudio.c",
        raylib_dir ++ "/rcore.c",
        raylib_dir ++ "/rmodels.c",
        raylib_dir ++ "/rshapes.c",
        raylib_dir ++ "/rtext.c",
        raylib_dir ++ "/rtextures.c",
        raylib_dir ++ "/utils.c",
        src_dir ++ "/raylib.c",
    }, raylib_flags);

    switch (raylib.target.toTarget().os.tag) {
        .windows => {
            raylib.addCSourceFiles(&.{raylib_dir ++ "/rglfw.c"}, raylib_flags);
            raylib.linkSystemLibrary("winmm");
            raylib.linkSystemLibrary("gdi32");
            raylib.linkSystemLibrary("opengl32");
            raylib.addIncludeDir("external/glfw/deps/mingw");
        },
        .linux => {
            raylib.addCSourceFiles(&.{raylib_dir ++ "/rglfw.c"}, raylib_flags);
            raylib.linkSystemLibrary("GL");
            raylib.linkSystemLibrary("rt");
            raylib.linkSystemLibrary("dl");
            raylib.linkSystemLibrary("m");
            raylib.linkSystemLibrary("X11");
        },
        .freebsd, .openbsd, .netbsd, .dragonfly => {
            raylib.addCSourceFiles(&.{raylib_dir ++ "/rglfw.c"}, raylib_flags);
            raylib.linkSystemLibrary("GL");
            raylib.linkSystemLibrary("rt");
            raylib.linkSystemLibrary("dl");
            raylib.linkSystemLibrary("m");
            raylib.linkSystemLibrary("X11");
            raylib.linkSystemLibrary("Xrandr");
            raylib.linkSystemLibrary("Xinerama");
            raylib.linkSystemLibrary("Xi");
            raylib.linkSystemLibrary("Xxf86vm");
            raylib.linkSystemLibrary("Xcursor");
        },
        .macos => {
            // On macos rglfw.c include Objective-C files.
            const raylib_flags_extra_macos = &[_][]const u8{
                "-ObjC",
            };
            raylib.addCSourceFiles(
                &.{raylib_dir ++ "/rglfw.c"},
                raylib_flags ++ raylib_flags_extra_macos,
            );
            raylib.linkFramework("Foundation");
        },
        else => {
            @panic("Unsupported OS");
        },
    }

    return raylib;
}

pub fn getRaygui(b: *std.build.Builder, mode: std.builtin.Mode, target: std.zig.CrossTarget) *std.build.LibExeObjStep {
    const raygui = b.addStaticLibrary("raylib", null);
    raygui.setBuildMode(mode);
    raygui.setTarget(target);
    raygui.linkLibC();

    raygui.addIncludePath(raylib_dir);
    raygui.addIncludePath(raygui_dir);
    raygui.addCSourceFiles(&.{src_dir ++ "/raygui.c"}, raylib_flags);

    return raygui;
}

pub fn build(b: *std.build.Builder) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);

    const mode = b.standardReleaseOptions();
    const target = b.standardTargetOptions(.{});

    const raylib_lib = getRaylib(b, mode, target);
    const raygui_lib = getRaygui(b, mode, target);

    const d = try std.fs.openIterableDirAbsolute(example_dir, .{});
    var di = d.iterate();
    while (try di.next()) |entry| {
        const example_name = entry.name[0 .. entry.name.len - 4];
        const exe_name = try std.fmt.allocPrint(arena.allocator(), "{s}_example", .{example_name});
        const full_name = try std.fmt.allocPrint(arena.allocator(), example_dir ++ "/{s}", .{entry.name});
        const step_name = try std.fmt.allocPrint(arena.allocator(), "run-{s}", .{example_name});

        const exe = b.addExecutable(exe_name, full_name);
        exe.setBuildMode(mode);
        exe.setTarget(target);
        exe.linkLibrary(raylib_lib);
        exe.linkLibrary(raygui_lib);
        exe.addPackage(raylib_pkg);
        exe.addPackage(raygui_pkg);
        const exe_run = exe.run();

        b.step(step_name, "Run the example").dependOn(&exe_run.step);
    }
}

fn getSrcDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse ".";
}
const src_dir = getSrcDir();
const raylib_dir = getSrcDir() ++ "/raylib/src";
const raygui_dir = getSrcDir() ++ "/raygui/src";
const example_dir = getSrcDir() ++ "/examples";

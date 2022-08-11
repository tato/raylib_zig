const rl = @import("raylib");
const rg = @import("raygui");

pub fn main() void {
    rl.InitWindow(800, 600, "hello");
    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);

        _ = rg.GuiWindowBox(.{ .x = 10, .y = 10, .width = 100, .height = 100 }, "grasse bort");
        rl.EndDrawing();
    }
}

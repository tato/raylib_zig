const rl = @import("raylib");

pub fn main() void {
    rl.InitWindow(800, 600, "hello");
    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        rl.ClearBackground(rl.RAYWHITE);
        rl.DrawText("grasse bort se hiso un tatu", 10, 10, 28, rl.BLUE);
        rl.EndDrawing();
    }
}

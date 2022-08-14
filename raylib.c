
#include <raylib.h>

void GetMousePositionZigHack(Vector2 *pos)
{
    *pos = GetMousePosition();
}

void GetMouseDeltaPtr(Vector2 *delta)
{
    *delta = GetMouseDelta();
}
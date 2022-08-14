
#include <raylib.h>

void GetMousePositionZigHack(Vector2 *pos)
{
    *pos = GetMousePosition();
}

void GetMouseDeltaPtr(Vector2 *delta)
{
    *delta = GetMouseDelta();
}

void MeasureTextExPtr(Font font, const char *text, float fontSize, float spacing, Vector2 *result)
{
    *result = MeasureTextEx(font, text, fontSize, spacing);
}
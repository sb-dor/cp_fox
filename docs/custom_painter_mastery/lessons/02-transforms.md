# Lesson 02 — Save, Transform, Restore

## Goal

Use transformations to express repeated radial geometry without manually calculating every rotated endpoint.

Create `lib/custom_painter_lessons/lesson_02_transforms.dart`.

## What to draw

Draw a compass face with:

- a background disc;
- 12 evenly spaced tick marks;
- four longer cardinal tick marks;
- a triangular needle above the ticks;
- a small center cap.

## Coordinate system

Start in the normal top-left coordinate system. Save the canvas, translate the origin to `size.center(Offset.zero)`, draw the radial content around `(0, 0)`, then restore.

## Back-to-front draw order

1. Background disc.
2. Short and cardinal tick marks.
3. Needle.
4. Center cap.

The center cap is last because it hides the needle's join.

## Geometry

- Outer radius is a fraction of `min(size.width, size.height)`.
- Angular step is `2π / 12`.
- Each tick can be drawn at the top of the translated coordinate system, followed by one angular rotation.
- Needle dimensions are fractions of radius.

Use a loop, one tick definition, and transforms. Do not hard-code 12 endpoint pairs.

## Architecture and repaint

This remains static. `shouldRepaint` returns `false`. Every `save()` must have a matching `restore()` so transforms do not leak to later layers.

## Acceptance checklist

- Ticks are evenly spaced and rotate around the exact center.
- Cardinal marks are distinguishable.
- Needle is drawn above the ticks and below its cap.
- The widget still looks correct in a non-square parent.
- Canvas state is restored before `paint()` ends.
- You can explain why translating the origin simplifies the math.

## Verification and submission

Run with square, wide, and tall constraints. In your submission, identify the canvas state before translation, during radial drawing, and after restore.

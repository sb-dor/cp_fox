# Lesson 01 — Primitives and Draw Order

## Goal

Learn to translate a sketch into canvas coordinates and to predict which pixels remain visible after shapes overlap.

Create `lib/custom_painter_lessons/lesson_01_primitives.dart` as a standalone Flutter app.

## What to draw

Draw a centered badge containing:

- a dark rounded-rectangle shadow offset down and right;
- a colored rounded-rectangle face;
- a thin light border inside the face;
- one centered circle.

No animation or input is required.

## Coordinate system

The canvas origin is its top-left corner. Positive x moves right; positive y moves down. Define the badge rectangle from margins proportional to `size.width` and `size.height`, not fixed screen coordinates.

## Back-to-front draw order

1. Shadow, because it must appear behind everything.
2. Colored face.
3. Inner border.
4. Center circle.

Before coding, predict what changes if the shadow is drawn last.

## Geometry

- `marginX = size.width * 0.12`
- `marginY = size.height * 0.20`
- The face uses the remaining rectangle.
- The shadow offset is based on the smaller canvas dimension.
- Circle center equals the face rectangle's center.
- Circle radius is a fraction of the face rectangle's shortest side.

Keep every value meaningful by naming it. Clamp dimensions if your formulas could become negative on a tiny canvas.

## Architecture and repaint

Use one immutable `CustomPainter`. It has no external state, so `shouldRepaint` can return `false`. Place it in a sized widget so its canvas dimensions are deliberate.

## Acceptance checklist

- Resizing preserves the composition and relative margins.
- Shadow never covers the face.
- Border is visibly inside or centered on the intended edge; you can explain which.
- Circle is centered from geometry, not visual guessing.
- No unexplained screenshot-specific coordinates appear.
- You can state every canvas command in execution order.

## Verification and submission

Format and analyze the file, then run it at both a wide and a narrow window size. Submit using the rubric template and explain why `shouldRepaint` is false.

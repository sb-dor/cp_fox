# Lesson 05 — Measuring and Painting Text

## Goal

Place text from measured metrics instead of estimating where glyphs will land.

Create `lib/custom_painter_lessons/lesson_05_canvas_text.dart`.

## What to draw

Draw an instrument label containing a rounded plate, a large numeric value, a smaller unit, and a caption aligned below them. Add crosshair guides through the plate's geometric center for learning; provide a boolean that can hide the guides.

## Coordinate system

The plate is derived from `Size`. Text uses its own measured width, height, and baseline behavior. A text position is the top-left offset passed to `TextPainter.paint`, not the visual center of its glyphs.

## Back-to-front draw order

1. Plate and border.
2. Optional alignment guides.
3. Numeric value.
4. Unit and caption.

## Geometry

- Create and lay out each `TextPainter` before reading its size.
- Center a text block with `left = centerX - textWidth / 2`.
- Treat the value and unit as either two measured blocks or one styled span; explain your choice.
- Derive vertical gaps from the plate height or text metrics.

## Architecture and repaint

Make value, unit, caption, and guide visibility immutable painter fields. `shouldRepaint` compares every field that can alter pixels. No animation is needed.

## Acceptance checklist

- The numeric value remains optically understandable with one and four digits.
- Unit placement is based on measurements.
- Caption does not collide with the main value.
- Toggling guides changes repaint configuration.
- Text direction is set explicitly.
- You can explain why text must be laid out before painting.

## Verification and submission

Try values `7`, `100`, and `2048`, then resize. Explain what is geometrically centered and what, if anything, you adjusted for optical balance.

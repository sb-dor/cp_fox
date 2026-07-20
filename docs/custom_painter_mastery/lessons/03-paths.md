# Lesson 03 — Paths and Bézier Curves

## Goal

Build one coherent silhouette from path segments and understand how control points shape a curve.

Create `lib/custom_painter_lessons/lesson_03_paths.dart`.

## What to draw

Draw a leaf emblem:

- a closed, filled leaf made from two cubic Bézier curves;
- a curved central vein;
- three smaller side veins;
- a subtle outline around the leaf.

## Coordinate system

Describe key points in normalized coordinates from 0 to 1, then map each point to the canvas using width and height. Treat the leaf tip, base, widest points, and control points as distinct concepts.

## Back-to-front draw order

1. Filled closed leaf path.
2. Leaf outline using the same silhouette.
3. Central vein.
4. Side veins.

## Geometry

- Begin at the leaf base with `moveTo`.
- Curve to the tip along one side using a cubic segment.
- Curve back to the base along the other side.
- Close the silhouette before filling.
- Place vein endpoints by interpolating between known points rather than scattering literals.

Change one control point at a time and record whether it affects the curve's departure, arrival, or bulge.

## Architecture and repaint

Use a static painter. You may create helper methods that map normalized points and build the silhouette. Keep path construction separate from paint styling so the same silhouette can be filled and stroked.

## Acceptance checklist

- The fill has no accidental gap at the base.
- Both sides form a smooth leaf rather than sharp unintended corners.
- Outline and fill share the same geometric path.
- Veins stay inside the silhouette at the tested sizes.
- Normalized coordinates make resizing predictable.
- You can identify the role of all four points in one cubic curve.

## Verification and submission

Test at two aspect ratios. Include a short explanation of `moveTo`, cubic control points, and `close` in your review request.

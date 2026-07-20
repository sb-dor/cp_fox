# Lesson 06 — Hit Testing from Shared Geometry

## Goal

Make the interactive region agree with a non-rectangular painted shape.

Create `lib/custom_painter_lessons/lesson_06_hit_testing.dart`.

## What to draw

Draw three circular targets. Clicking a target selects it, changing its fill and drawing an outer selection ring. Clicking between circles must not select one.

## Coordinate system

Calculate centers and radii from the current `Size`. Pointer positions arrive in the same local coordinates used by `paint` when the gesture region and `CustomPaint` share bounds.

## Back-to-front draw order

1. Neutral background.
2. All target discs.
3. Selection ring above the selected target.
4. Optional center dots for debugging.

## Geometry

A point is inside a circle when the squared distance satisfies:

`(px - cx)² + (py - cy)² <= radius²`

Use one geometry function or model to supply circles to both painting and hit testing. Do not maintain separate guessed hit rectangles.

## Architecture and repaint

Widget state owns the selected index and pointer handling. The painter receives the immutable selected index plus shared geometry inputs. Rebuild when selection changes; `shouldRepaint` compares selected index and other visual configuration.

This lesson intentionally uses widget state. Lesson 07 moves frequent visual changes to a repaint controller.

## Acceptance checklist

- Each visible disc can be selected at its center and near its edge.
- Empty gaps do not select a target.
- Selection appearance is always drawn last.
- Resize does not desynchronize input and paint geometry.
- The selection update occurs only when the selected target actually changes.
- You can explain why squared distance avoids an unnecessary square root.

## Verification and submission

Test centers, exact boundaries, just-outside points, and gaps. Describe where your single source of geometric truth lives.

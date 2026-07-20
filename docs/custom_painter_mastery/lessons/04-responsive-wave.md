# Lesson 04 — Responsive Wave Geometry

## Goal

Turn a mathematical wave into a closed, fillable, size-relative shape.

Create `lib/custom_painter_lessons/lesson_04_responsive_wave.dart`.

## What to draw

Draw a panel with:

- a solid dark background;
- a filled colored region whose top edge is a smooth wave;
- a thin contrasting stroke following only the wave edge;
- two small markers showing the wave baseline and one peak.

## Coordinate system

Use x from `0` to `size.width`. Define the baseline as a proportion of `size.height`. Canvas y grows downward, so adding a sine displacement moves a point visually down and subtracting moves it up.

## Back-to-front draw order

1. Background.
2. Closed colored wave region.
3. Wave-edge stroke.
4. Diagnostic markers.

The fill path must travel along the wave, then to the lower corners, then close. The stroke path should not include the lower rectangle edges.

## Geometry

For normalized progress `t = x / width`:

`y = baseline + amplitude * sin(2π * cycles * t + phase)`

- Derive amplitude from height.
- Use one or two complete cycles.
- Sample enough x positions for a smooth curve, but do not tie the count to one screen resolution.
- Derive the known peak marker from the formula rather than eyeballing it.

## Architecture and repaint

Keep `phase` as immutable painter configuration for now. `shouldRepaint` returns whether the old and new phase differ. There is no ticker yet; a parent may rebuild with another phase for manual experiments.

## Acceptance checklist

- The filled area always reaches both bottom corners.
- The contrast stroke covers only the mathematical wave edge.
- Amplitude remains subtle and proportional after resizing.
- Markers match the formula.
- `shouldRepaint` compares the actual visual configuration.
- You can explain the sign of vertical displacement in canvas coordinates.

## Verification and submission

Try phases `0`, `π / 2`, and `π`, plus two canvas sizes. Explain the difference between frequency/cycles, amplitude, and phase.

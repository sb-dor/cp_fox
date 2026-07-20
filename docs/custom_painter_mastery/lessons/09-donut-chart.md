# Lesson 09 — Polar Geometry and a Donut Chart

## Goal

Convert data into angular spans and keep chart geometry, labels, and selection layers coherent.

Create `lib/custom_painter_lessons/lesson_09_donut_chart.dart` with focused geometry tests.

## What to draw

Draw a donut chart with four positive values:

- colored segments separated by small angular gaps;
- one selected segment offset slightly outward;
- labels near segment mid-angles;
- a center disc with total value text.

## Coordinate system

Use the canvas center as the polar origin. Flutter arc angle zero points right; choose and document a start-angle offset if the first segment should begin at the top. Positive sweep follows the canvas arc convention.

## Back-to-front draw order

1. Optional chart shadow.
2. Unselected segments.
3. Selected segment.
4. Center disc.
5. Total text and labels.

Drawing the selected segment after the others prevents its offset edge from being visually buried.

## Geometry

- `total = sum(values)`
- `rawSweep = value / total * 2π`
- `visibleSweep = max(0, rawSweep - gapAngle)`
- `midAngle = startAngle + rawSweep / 2`
- Label and selection offsets use `cos(midAngle)` and `sin(midAngle)`.

Advance the next start angle by the raw sweep, not the reduced visible sweep. Define behavior for an empty list, zero total, and negative input.

## Architecture and repaint

Use immutable chart data and selection as painter configuration for this lesson. Create a small segment-geometry model so paint, labels, tests, and later hit testing share computed angles. `shouldRepaint` must detect meaningful data, color, and selection changes rather than relying only on list identity.

## Acceptance checklist

- Segment proportions match data.
- Gaps are visually even and do not accumulate into wrong start angles.
- Selected segment moves along its own mid-angle.
- Labels sit near the correct segments.
- Empty and zero-total data do not divide by zero.
- Tests verify total sweep, mid-angles, and edge-case policy.
- You can explain start angle, sweep angle, and mid-angle separately.

## Verification and submission

Try equal, highly unequal, empty, and zero-total datasets. Describe your invalid-data policy and how the geometry model prevents duplicated math.

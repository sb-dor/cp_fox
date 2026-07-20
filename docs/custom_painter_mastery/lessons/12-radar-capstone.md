# Lesson 12 — Animated Radar Capstone

## Goal

Design a complete custom-painted component that combines normalized geometry, static/dynamic layers, time-based motion, hit testing, labels, accessibility, and tests.

Create `lib/custom_painter_lessons/lesson_12_radar_capstone.dart` plus focused tests.

## What to draw

Draw an interactive radar display:

- static dark circular field, concentric range rings, crosshairs, and cardinal labels;
- a rotating sweep line and translucent sweep wedge;
- several blips at normalized polar positions;
- fading pulse rings around the selected blip;
- selecting a blip by pointer reveals a measured label;
- pause/resume control works by pointer, keyboard, and semantics.

## Coordinate system

Center the radar on the shortest canvas dimension. Store blips as normalized radius from 0 to 1 and angle in radians, then map to Cartesian canvas points. Use one mapping function for paint, label placement, and hit testing.

## Back-to-front draw order

Static painter:

1. Field background.
2. Range rings.
3. Crosshairs and tick marks.
4. Cardinal labels.

Dynamic painter:

1. Sweep wedge.
2. Sweep line.
3. Unselected blips.
4. Selected pulse rings and blip.
5. Selected label and leader line.

If you alter this order, document the visual reason.

## Geometry and time

- Sweep angle advances from angular velocity times elapsed delta.
- Wedge uses the current sweep angle and a small trailing angular span.
- Blip position uses normalized radius times radar radius.
- Hit testing uses distance to the mapped blip center with a documented minimum target radius.
- Pulse radius and opacity derive from a normalized repeating phase.
- Label placement clamps or flips to remain inside canvas bounds.

## Architecture and repaint

- State owns ticker, focus, controller, and cached painters.
- Controller owns sweep angle, pulse phase, pause state, and selected blip, and notifies only for visible changes.
- Static painter has no animation listener.
- Dynamic painter uses `super(repaint: controller)`.
- Ticker advances by elapsed delta, stops while paused or not needed, and is disposed safely.
- `shouldRepaint` compares immutable configuration such as colors and blip data.
- Semantics exposes radar status, selected target, and pause/resume action.

Do not use a shader. The capstone is about mastering Canvas and painter architecture.

## Required tests

- Polar-to-Cartesian mapping at cardinal angles.
- Sweep advancement with known elapsed deltas and wraparound.
- Pause prevents advancement; resume continues without a jump.
- Hit testing selects near a blip and rejects empty space.
- Static painter is independent of animation notifications.
- Semantics exposes status and pause/resume action.
- Controller and ticker lifecycle is safe.

## Acceptance checklist

- Static rings remain crisp and do not participate in animation repaint.
- Sweep speed is frame-rate independent.
- Selection, pulse, and label share one source of geometry.
- Pausing truly stops time advancement.
- Resize preserves all normalized relationships.
- The component is usable without a pointer.
- Tests cover math, controller behavior, interaction, and semantics.
- You can draw the ownership/repaint flow from memory.

## Final explanation

Submit the normal review template plus a short architecture note answering:

1. What rebuilds, what repaints, and what never changes during one animation frame?
2. Why are there separate static and dynamic painters?
3. Which formulas are shared across painting and input?
4. What starts and stops the ticker?
5. What would a shader change, and why is it unnecessary here?

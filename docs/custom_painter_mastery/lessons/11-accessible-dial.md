# Lesson 11 — Accessible Interactive Dial

## Goal

Turn a painted control into a complete interaction: pointer, keyboard, focus, and semantics all operate on the same value.

Create `lib/custom_painter_lessons/lesson_11_accessible_dial.dart` with widget tests.

## What to draw

Draw a rotary dial with:

- static track and tick marks;
- active arc from minimum angle to current value;
- rotating indicator;
- focus ring when keyboard-focused;
- centered value text.

Support pointer drag, arrow keys, and an accessible increase/decrease action.

## Coordinate system

Use the dial center as polar origin. Convert pointer position to angle with `atan2(dy, dx)`, normalize into the dial's allowed angular range, then map angle to a value from 0 to 1. Explicitly handle the range's discontinuity if it crosses `-π`/`π`.

## Back-to-front draw order

1. Focus ring, when visible.
2. Inactive track and ticks.
3. Active arc.
4. Indicator.
5. Center cover and measured value text.

## Geometry

- `angle = startAngle + value * sweepRange`
- Indicator endpoint uses cosine and sine at that angle.
- Hit area may be more generous than the visible ring, but its rule must be documented.
- Keyboard increments clamp to the same normalized range as pointer input.

## Architecture and repaint

State owns focus and the value controller. Frequent value changes notify the dynamic painter through `super(repaint: controller)`. Focus changes may rebuild the lightweight composition or notify a visual controller; justify the choice. Wrap the control in `Semantics` with label, current value, enabled state, and increase/decrease actions.

## Acceptance checklist

- Pointer movement, arrows, and semantic actions update the same value.
- Values clamp at both ends.
- Focus is visibly clear.
- Semantics exposes label, value, and actions in a widget test.
- Paint hit geometry and interaction geometry cannot drift after resize.
- Repaint strategy avoids rebuilding for every drag sample.
- You can explain why painted pixels alone are not an accessible control.

## Verification and submission

Test mouse/touch, keyboard focus, both arrow directions, semantic actions, bounds, and resize. Include the semantics contract in your explanation.

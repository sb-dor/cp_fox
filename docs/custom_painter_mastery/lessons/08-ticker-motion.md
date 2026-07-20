# Lesson 08 — Time-Based Motion with a Ticker

## Goal

Animate at a stable speed using elapsed time, with a complete start/stop/dispose lifecycle.

Create `lib/custom_painter_lessons/lesson_08_ticker_motion.dart` and focused controller tests.

## What to draw

Draw a circular orbit with a marker moving around it. Include a static orbit ring and crosshairs, plus a dynamic marker and short fading-looking trail made from several progressively smaller/less opaque circles.

## Coordinate system

Center the orbit in the canvas. For angle `θ`:

- `x = centerX + radius * cos(θ)`
- `y = centerY + radius * sin(θ)`

Remember that positive sine moves downward on a Flutter canvas.

## Back-to-front draw order

Static painter:

1. Background.
2. Crosshairs.
3. Orbit ring.

Dynamic painter:

1. Oldest trail point through newest trail point.
2. Marker glow/shadow.
3. Marker face.

## Geometry and time

Express speed as radians per second. On each tick, compute the elapsed-time delta and advance:

`angle = (angle + angularVelocity * deltaSeconds) mod 2π`

Do not add a fixed angle per frame; that makes speed depend on frame rate.

## Architecture and repaint

- State owns the ticker, controller, and cached painters.
- Controller owns angle and angular velocity and notifies on advancement.
- Ticker reads elapsed duration and calculates deltas.
- Start on an explicit lifecycle event, stop when not visible or not needed, and dispose ticker/controller.
- Dynamic painter uses `super(repaint: controller)`.
- No frame-by-frame `setState`.

## Acceptance checklist

- Motion speed is approximately unchanged at different frame rates.
- The first tick cannot produce a huge jump from an uninitialized timestamp.
- Angle stays bounded.
- Trail follows rather than leads the marker.
- Static ring does not repaint because the angle changed.
- Tests advance the controller with known deltas and verify expected angles.
- You can explain ticker elapsed time versus frame count.

## Verification and submission

Test start, stop, resume, and disposal. In the review request, describe who owns time, who owns visual state, and who listens for repaint.

# Lesson 10 — Soft Hover-Waving Button

## Goal

Reconstruct the reference button while isolating static white geometry from a softly animated colored face.

Create `lib/custom_painter_lessons/lesson_10_waving_button.dart` and widget/controller tests. Do not copy `lib/fox_waving_button.dart`; use it only after your first review if you need comparison.

## What to draw

Draw a wide skewed button inspired by the reference image:

- dark page background;
- white lower/right backing shape that never waves;
- magenta-to-blue colored face with slanted ends;
- centered white label;
- only the colored face develops a subtle continuous wave while hovered;
- leaving hover settles smoothly to the resting shape rather than snapping.

## Coordinate system

Express the silhouette as normalized control points mapped through `Size`. Reserve independent geometry for the white backing and colored face. The face wave is a small y displacement applied only to selected face-edge samples; it must not mutate backing points.

## Back-to-front draw order

Static painter:

1. White backing/shadow geometry.

Dynamic face painter:

1. Colored face path and gradient.
2. Optional restrained face highlight.
3. Label, if it is intentionally part of the animated layer; otherwise place the label in a stable foreground widget and explain why.

## Geometry and motion

Combine a low-amplitude spatial wave with a slowly changing phase:

`displacement = amplitudeEnvelope * sin(spatialFrequency * t + phase)`

- Wave amplitude must be subtle relative to button height.
- Hover target ramps toward 1; exit target ramps toward 0.
- Phase keeps advancing while the hover influence is visible.
- Use elapsed-time deltas so timing is frame-rate independent.
- Define which face edges wave and keep corners joined without gaps.

## Architecture and repaint

- State owns `Ticker`, hover controller, and cached static/dynamic painters.
- `MouseRegion` changes the controller's hover target.
- Controller owns phase and smoothed hover amount and extends `ChangeNotifier`.
- Dynamic painter passes controller to `super(repaint: controller)`.
- Static backing painter does not listen and `shouldRepaint` is false when configuration is unchanged.
- Stop the ticker after the exit envelope reaches rest; restart on hover.

## Acceptance checklist

- Hover produces continuous soft motion, not one wave followed by a stop.
- Motion is neither fast nor vertically excessive.
- White backing remains perfectly static.
- Exit settles smoothly and ticker eventually stops.
- Face and backing never expose accidental seams.
- No per-frame `setState` occurs.
- Tests verify amplitude bounds, backing independence, hover continuation, and settling.
- You can trace a hover event all the way to a repaint.

## Verification and submission

Test rapid enter/exit, long hover, resizing, and disposal while active. State your duration/speed/amplitude choices and describe how each affects the feeling of the wave.

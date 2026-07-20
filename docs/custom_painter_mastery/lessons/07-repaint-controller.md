# Lesson 07 — Repaint Controllers

## Goal

Update canvas pixels through a `Listenable` without rebuilding the widget tree for every value change.

Create `lib/custom_painter_lessons/lesson_07_repaint_controller.dart` and a focused test under `test/custom_painter_lessons/`.

## What to draw

Draw an interactive horizontal meter:

- static track, tick marks, and labels;
- dynamic filled progress and thumb;
- pointer dragging changes the normalized value from 0 to 1.

## Coordinate system

Define a track rectangle from `Size`. Convert local pointer x to normalized progress:

`value = ((x - trackLeft) / trackWidth).clamp(0, 1)`

Convert value back to a thumb x using the inverse relationship.

## Back-to-front draw order

Static painter:

1. Track background.
2. Tick marks.
3. Labels.

Dynamic painter:

1. Filled progress.
2. Thumb shadow.
3. Thumb face.

Place the painters in one `CustomPaint` foreground/background arrangement or a stack, and explain the choice.

## Architecture and repaint

- Widget state creates and disposes a `MeterController extends ChangeNotifier`.
- The controller exposes a read-only value and notifies only when the clamped value actually changes.
- Cache both painter instances in state.
- Pass the controller to the dynamic painter and to `super(repaint: controller)`.
- The static painter never listens to the controller.
- `shouldRepaint` remains about immutable delegate configuration; controller notifications drive live frames.

Do not call `setState` for every drag update.

## Acceptance checklist

- Dragging updates pixels smoothly from 0 through 1.
- Values clamp outside the track.
- Widget build count does not rise on every pointer move.
- Static geometry is not repainted by controller notifications.
- Controller ownership and disposal are correct.
- A test verifies clamping and “notify only on change.”
- You can distinguish rebuild, layout, and repaint.

## Verification and submission

Run format, analysis, the focused test, and the app. Explain exactly how `notifyListeners()` reaches `paint()`.

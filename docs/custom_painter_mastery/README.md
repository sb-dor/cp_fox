# CustomPainter Mastery

This is a practical course in drawing Flutter interfaces from a blank Dart file. You write every exercise; the reviewer teaches with questions and hints before offering code.

## Reference architecture

The course follows the structure demonstrated by `lib/fox_animated_custom_painter_1.dart` and the PlugFox examples:

- Widget state owns objects with lifecycles: tickers, controllers, focus nodes, and cached painters.
- A controller extends `ChangeNotifier` and exposes meaningful animation state.
- The painter receives that controller through `super(repaint: controller)` so a frame can repaint without rebuilding or laying out the widget tree.
- Static and animated layers become separate painters when they have different repaint needs.
- Geometry is derived from `Size`, usually with normalized values, instead of being tied to one screenshot size.
- `paint()` draws back-to-front. Later commands cover earlier pixels.
- `shouldRepaint` compares immutable painter configuration; it is not the animation clock.

The shader example is used only to compare architecture. Shader programming is optional and is not required for this course.

## Working agreement

Create exercises under `lib/custom_painter_lessons/` with the exact filename shown in each brief. Start each file blank. Do not copy the existing finished button.

Run one lesson directly with:

```sh
flutter run -t lib/custom_painter_lessons/lesson_01_primitives.dart
```

When ready, send the file path and say `Review lesson 01`. The first review will not edit your work. It will return:

1. `Pass`, `Revise`, or `Blocked`.
2. A reconstruction of your actual draw order.
3. Geometry, lifecycle, repaint, performance, and readability findings.
4. Hint-first corrections, from smallest hint to strongest hint.
5. Exact checks to run and the next revision target.

Code is patched only when you explicitly ask for an implementation or a worked solution.

## The painter's mental model

For every picture, answer these questions before writing code:

1. What pixels should exist in the final image?
2. Where is the origin, and which way do the axes grow?
3. What is drawn first, second, and last?
4. Which points come directly from `Size`, and which come from formulas?
5. Which values are immutable configuration, interactive state, or time-varying animation state?
6. What event requests a repaint, and what stops it?
7. Which parts need hit testing or semantics beyond the painted pixels?

## Course map

| Lesson | Subject | Drawing result | Architectural focus |
|---|---|---|---|
| 01 | Primitives | Framed badge | Coordinates and paint order |
| 02 | Transforms | Repeated compass marks | `save`, transform, `restore` |
| 03 | Paths | Leaf emblem | Lines, Béziers, closure |
| 04 | Responsive wave | Wave panel | Sampling a size-relative curve |
| 05 | Canvas text | Instrument label | Measure first, then place |
| 06 | Hit testing | Selectable target | Same geometry for paint and input |
| 07 | Repaint controller | Interactive meter | `ChangeNotifier` and cached painter |
| 08 | Ticker motion | Orbiting marker | Time, velocity, lifecycle |
| 09 | Donut chart | Data visualization | Polar geometry and layers |
| 10 | Waving button | Hover interaction | Static/animated layer separation |
| 11 | Accessible dial | Keyboard-ready control | Semantics and interaction |
| 12 | Radar capstone | Animated radar | Complete painter architecture |

## Recommended rhythm

Each lesson is designed for 30–60 minutes:

- 5 minutes: sketch the image and label coordinates.
- 10 minutes: write geometry as formulas before Dart.
- 20–35 minutes: implement in small visible stages.
- 5 minutes: verify, then explain your decisions in plain language.

Do not continue merely because the image looks close. A lesson is complete when its acceptance checklist passes and you can explain why the geometry and repaint strategy work.

## Verification ladder

For every lesson:

```sh
dart format lib/custom_painter_lessons/lesson_XX_name.dart
dart analyze lib/custom_painter_lessons/lesson_XX_name.dart
flutter run -t lib/custom_painter_lessons/lesson_XX_name.dart
```

From Lesson 07 onward, add focused painter/controller tests. Prefer recording or inspecting canvas operations when exact pixels would make tests fragile.

Start with [Lesson 01](lessons/01-primitives.md). The assessment rules are in [the review rubric](review-rubric.md).

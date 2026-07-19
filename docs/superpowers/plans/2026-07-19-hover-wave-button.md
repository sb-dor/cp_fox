# Hover Wave Button Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a standalone Flutter CustomPainter button that matches the neon `ВОЙТИ` reference, waves continuously on hover, and smoothly settles on exit.

**Architecture:** A stateful `WavingButton` owns a `Ticker`, a private `ChangeNotifier` animation controller, and one cached painter. Pointer events only change controller targets; the painter listens through `CustomPainter(repaint: controller)` and constructs normalized gradient, accent, glow, and text paths without rebuilding widgets.

**Tech Stack:** Flutter widgets/rendering, Dart `Ticker`, `ChangeNotifier`, `CustomPainter`, `Canvas`, and `flutter_test`.

## Global Constraints

- Create the complete runnable example in `lib/fox_waving_button.dart` with its own top-level `main()`.
- Leave `lib/main.dart` and `lib/fox_animated_custom_painter_1.dart` unchanged.
- Follow the controller, cached painter, and `CustomPaint(painter: _painter)` pattern from `lib/fox_animated_custom_painter_1.dart`.
- Use no new package dependency or image asset.
- Settle to an exact zero-amplitude resting path after pointer exit.

---

### Task 1: Standalone accessible button shell

**Files:**
- Create: `lib/fox_waving_button.dart`
- Create: `test/fox_waving_button_test.dart`

**Interfaces:**
- Produces: `void main()`, `class WavingButton extends StatefulWidget`, and `const WavingButton({VoidCallback? onPressed, Key? key})`.
- Consumes: Flutter's `MouseRegion`, `Semantics`, `GestureDetector`, and `CustomPaint` widgets.

- [ ] **Step 1: Write the failing shell and tap tests**

```dart
testWidgets('standalone app shows an accessible painted login button', (tester) async {
  await tester.pumpWidget(const WavingButtonExampleApp());
  expect(find.byType(CustomPaint), findsWidgets);
  expect(find.bySemanticsLabel('ВОЙТИ'), findsOneWidget);
});

testWidgets('button invokes onPressed when tapped', (tester) async {
  var taps = 0;
  await tester.pumpWidget(Directionality(
    textDirection: TextDirection.ltr,
    child: Center(child: WavingButton(onPressed: () => taps++)),
  ));
  await tester.tap(find.byType(WavingButton));
  expect(taps, 1);
});
```

- [ ] **Step 2: Run the focused tests and verify RED**

Run: `flutter test test/fox_waving_button_test.dart`

Expected: compilation fails because `lib/fox_waving_button.dart`, `WavingButtonExampleApp`, and `WavingButton` do not exist.

- [ ] **Step 3: Add the minimal standalone shell**

Create the top-level app with a navy `ColoredBox`, centered constrained `WavingButton`, `Semantics(button: true, label: 'ВОЙТИ')`, clickable `MouseRegion`, tap handler, `AspectRatio`, and a cached placeholder painter passed directly to `CustomPaint`.

- [ ] **Step 4: Run the focused tests and verify GREEN**

Run: `flutter test test/fox_waving_button_test.dart`

Expected: both shell tests pass.

### Task 2: Hover controller lifecycle

**Files:**
- Modify: `lib/fox_waving_button.dart`
- Modify: `test/fox_waving_button_test.dart`

**Interfaces:**
- Produces: `_WavingButtonController.onTick(Duration delta)`, `.setHovered(bool hovered)`, `.amplitude`, `.phase`, and `.isAnimating`.
- Consumes: the state-owned `Ticker` callback and `MouseRegion` enter/exit events.

- [ ] **Step 1: Write failing hover and settle tests**

```dart
testWidgets('hover animates the painted button', (tester) async {
  await tester.pumpWidget(const _TestHost(child: WavingButton()));
  final before = await _captureButton(tester);
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));
  await tester.pump(const Duration(milliseconds: 180));
  final during = await _captureButton(tester);
  expect(during, isNot(equals(before)));
});

testWidgets('pointer exit settles to the original painting', (tester) async {
  await tester.pumpWidget(const _TestHost(child: WavingButton()));
  final resting = await _captureButton(tester);
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));
  await tester.pump(const Duration(milliseconds: 180));
  await mouse.moveTo(const Offset(1, 1));
  await tester.pumpAndSettle();
  expect(await _captureButton(tester), equals(resting));
});
```

The helper wraps the button in a fixed-size `RepaintBoundary` and compares its `ui.Image` byte data, so the test observes real painted output.

- [ ] **Step 2: Run the hover tests and verify RED**

Run: `flutter test test/fox_waving_button_test.dart --plain-name 'hover animates the painted button'`

Expected: failure because hovering does not yet change the painting.

- [ ] **Step 3: Implement controller and ticker behavior**

Create the controller with target amplitude `0` or `1`, exponential easing toward the target based on elapsed seconds, continuously advancing phase while amplitude is nonzero, `notifyListeners()` on visual changes, and an `isAnimating` result that becomes false only after a non-hovered amplitude snaps exactly to `0`. Wire enter/exit to restart the ticker with a reset previous elapsed duration; dispose both ticker and controller.

- [ ] **Step 4: Run hover lifecycle tests and verify GREEN**

Run: `flutter test test/fox_waving_button_test.dart`

Expected: the hover image differs, the post-exit image exactly matches rest, and shell tests remain green.

### Task 3: Reference-quality painter

**Files:**
- Modify: `lib/fox_waving_button.dart`
- Modify: `test/fox_waving_button_test.dart`

**Interfaces:**
- Produces: `_WavingButtonPainter.paint(Canvas canvas, Size size)` using controller amplitude and phase.
- Consumes: normalized dimensions, `_WavingButtonController`, and the stable `CustomPaint` shell from Tasks 1–2.

- [ ] **Step 1: Add a failing visual-structure painter test**

```dart
testWidgets('button renders nontransparent gradient, accent, and center pixels', (tester) async {
  await tester.pumpWidget(const _TestHost(child: WavingButton()));
  final image = await _captureButtonImage(tester);
  expect(await _pixel(image, 20, 60), isNot(const Color(0x00000000)));
  expect(await _pixel(image, 210, 85), equals(const Color(0xFFFFFFFF)));
  expect((await _pixel(image, 120, 55)).alpha, greaterThan(0));
});
```

- [ ] **Step 2: Run the painter test and verify RED**

Run: `flutter test test/fox_waving_button_test.dart --plain-name 'button renders nontransparent gradient, accent, and center pixels'`

Expected: failure because the placeholder painter does not draw all required layers.

- [ ] **Step 3: Implement the final painter**

Build sampled wave paths with `Path.moveTo/lineTo`, using a sine offset multiplied by controller amplitude. Paint a blurred violet glow, the offset white accent, and the magenta-violet-blue face with `LinearGradient.createShader`. Lay out `ВОЙТИ` as a bold white `ui.Paragraph`, center it on the face, and keep its movement subtle. Return `false` from `shouldRepaint` and `shouldRebuildSemantics` because the controller drives repainting.

- [ ] **Step 4: Run all tests and analyze**

Run: `dart format lib/fox_waving_button.dart test/fox_waving_button_test.dart docs/superpowers/plans/2026-07-19-hover-wave-button.md`

Run: `flutter analyze`

Run: `flutter test`

Expected: formatting succeeds, analysis reports no issues, and all tests pass.

- [ ] **Step 5: Run the standalone target for manual inspection**

Run: `flutter run -d macos -t lib/fox_waving_button.dart`

Expected: the centered neon `ВОЙТИ` button matches the supplied composition, waves continuously while hovered, settles smoothly on exit, and responds to clicks.

### Task 4: Keep the white accent rigid

**Files:**
- Modify: `lib/fox_waving_button.dart`
- Modify: `test/fox_waving_button_test.dart`

**Interfaces:**
- Consumes: `_WavingButtonPainter._buildFacePath`, controller amplitude and phase, and the existing ordered painter layers.
- Produces: a white accent path whose geometry is invariant across controller animation frames, while the colored face and glow retain animated geometry.

- [ ] **Step 1: Write a failing path-invariance test**

Add a `_PathRecordingCanvas extends TestRecordingCanvas` that copies the path
drawn with white paint into `whitePath` and the path drawn with a shader into
`gradientPath`. Add `_pathSignature(Path path)`, which samples tangent positions
at fixed fractions of the path metric. Paint once at rest, hover for 180 ms,
paint again, and assert:

```dart
expect(_pathSignature(animated.whitePath!), _pathSignature(resting.whitePath!));
expect(
  _pathSignature(animated.gradientPath!),
  isNot(_pathSignature(resting.gradientPath!)),
);
```

- [ ] **Step 2: Run the focused test and verify RED**

Run: `flutter test test/fox_waving_button_test.dart --plain-name 'white accent stays rigid while colored face waves'`

Expected: failure because the current accent path uses `amplitude * 0.82` and a changing phase.

- [ ] **Step 3: Make only the accent path static**

Change the accent path construction to:

```dart
final accent = _buildFacePath(
  size: logicalSize,
  amplitude: 0,
  phase: 0,
  offset: const Offset(7, 9),
);
```

Keep the glow and gradient face drawing the animated `face` path.

- [ ] **Step 4: Run verification**

Run: `dart format lib/fox_waving_button.dart test/fox_waving_button_test.dart`

Run: `flutter test test/fox_waving_button_test.dart`

Run: `flutter analyze`

Expected: all button tests pass; the changed files introduce no analyzer issues.

### Task 5: Use continuous slow soft waving

**Files:**
- Modify: `lib/fox_waving_button.dart`
- Modify: `test/fox_waving_button_test.dart`

**Interfaces:**
- Consumes: `_WavingButtonState._setHovered`, `_WavingButtonController.onTick`, and `_WavingButtonPainter._wave`.
- Produces: `_WavingButtonController.setHovered(bool)` with a 2.8-second phase cycle and eased amplitude target.

- [ ] **Step 1: Write failing continuous-hover behavior tests**

Replace the one-shot tests with a test that remains hovered for more than one
second and verifies positive amplitude, an active ticker, and changing painted
face geometry. Add `debugWavePhase` to the wished-for state API and assert that
700 milliseconds advances approximately one quarter of the 2.8-second cycle.
Retain the recording-canvas test requiring sampled animated gradient points to
move no more than 2.5 logical pixels vertically from rest.

- [ ] **Step 2: Run the focused tests and verify RED**

Run: `flutter test test/fox_waving_button_test.dart --plain-name 'wave continues softly for the full hover'`

Expected: failure because the one-shot controller has already returned to zero
and stopped after 420 milliseconds.

- [ ] **Step 3: Implement continuous slow easing**

Replace `startBurst()` and `stopBurst()` with `setHovered(bool)`. While hovered,
`onTick()` advances phase at `1 / 2.8` cycles per second and exponentially eases
amplitude toward one with rate `8`. On exit, it eases amplitude toward zero,
snaps to exact zero below `0.01`, and returns false so state stops the ticker.
Preserve phase when hover state changes. State starts the ticker on enter and
lets it continue through the exit ease-out.

Keep the logical top and bottom maximum offsets at `0.025` and `0.020` of height,
text displacement at `0.4`, and the accent path at zero amplitude.

- [ ] **Step 4: Run verification**

Run: `dart format lib/fox_waving_button.dart test/fox_waving_button_test.dart`

Run: `flutter test`

Run: `flutter analyze`

Expected: all tests pass; only the existing unrelated info notices in
`lib/pie_chart.dart` remain.

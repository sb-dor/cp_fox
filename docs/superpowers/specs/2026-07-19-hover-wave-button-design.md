# Hover Wave Button Design

## Goal

Create a standalone Flutter CustomPainter example matching the supplied neon
"ВОЙТИ" button. The button begins waving when hovered and smoothly returns to
its exact resting silhouette when the pointer leaves.

## Scope and entry point

- Add `lib/fox_waving_button.dart` as a new, self-contained runnable example.
- Define a top-level `main()` in that file so it can be launched directly with
  `flutter run -t lib/fox_waving_button.dart`.
- Leave `lib/main.dart` and `lib/fox_animated_custom_painter_1.dart` unchanged.
- Expose the painted interaction as a reusable `WavingButton` widget with an
  optional tap callback.

## Visual design

The example uses a near-black navy background and centers a wide button with a
responsive aspect ratio. The painter draws:

1. A soft violet glow behind the button.
2. An offset white lower/right accent shape.
3. A skewed main face filled with a left-to-right magenta, violet, and electric
   blue gradient.
4. Centered white `ВОЙТИ` text in a heavy, angular-looking style using available
   Flutter typography.

All geometry is normalized against the available canvas size so the button
scales without changing proportions.

## Architecture

The implementation follows the lifecycle and repaint pattern in
`lib/fox_animated_custom_painter_1.dart`:

- `_WavingButtonState` uses `SingleTickerProviderStateMixin` and owns one
  `Ticker`.
- State creates one `_WavingButtonController` and one `_WavingButtonPainter` in
  `initState`.
- The painter is passed directly to `CustomPaint(painter: _painter)`.
- `_WavingButtonPainter` calls `super(repaint: controller)` and returns `false`
  from `shouldRepaint`, so animation repaints do not rebuild the widget tree.
- The controller mixes in `ChangeNotifier`, stores animation values, advances
  them on every tick, and notifies the painter.
- State disposes the ticker and controller.

## Interaction and animation

`MouseRegion` reports pointer enter and exit. While the pointer remains hovered,
the controller continuously advances a slow wave phase with one cycle taking
about 2.8 seconds. Amplitude eases from zero to its full subtle value over about
600 milliseconds. Pointer exit changes the target amplitude to zero; the ticker
continues only until the face eases back to its exact resting geometry, then
stops. Phase is preserved through entry and exit transitions to avoid jumps.

The painter samples sine waves along the long edges of the colored button face.
The violet glow follows that animated face. The offset white lower/right accent
always uses zero-amplitude geometry, so it remains completely rigid while the
colored layer waves above it. At the 500-by-100 logical canvas size, vertical
face displacement is limited to about 2.5 pixels and text displacement to about
0.4 pixels. The resting amplitude is exactly zero, producing stable reference
geometry with no residual distortion. Hover transitions are eased and do not
jump when the pointer rapidly re-enters or exits.

`GestureDetector` or `Listener` supplies the optional tap behavior without
coupling it to the painting controller.

## Accessibility and resilience

- Wrap the interactive region in `Semantics(button: true, label: 'ВОЙТИ')`.
- Show a clickable cursor over the button.
- Return an empty widget when layout constraints cannot produce a usable size.
- Keep the text readable while the surrounding face waves; only a subtle
  vertical motion may be applied to the text as a whole.

## Teaching documentation

`lib/fox_waving_button.dart` includes concise teaching-style comments rather
than literal per-line narration. Comments explain the standalone entry point,
widget API, ownership of the ticker/controller/cached painter, hover lifecycle,
ordered paint layers, normalized 500-by-100 coordinate system, sampled sine
paths, anchored wave ends, amplitude and phase, controller easing and exact
settling, and why controller-driven repainting allows `shouldRepaint` to return
false. Documentation must not change visual or interactive behavior.

## Verification

Widget tests will launch the standalone app/widget and verify:

- The resting button and `CustomPaint` are present.
- Pointer entry starts animation and changes controller/painter animation state.
- Animation remains active and continues changing phase for the full hover.
- Pointer exit returns the controller to zero amplitude and stops animated
  movement after the soft ease-out.
- The white accent path is identical at rest and during hover animation, while
  the colored face path changes.
- Tapping invokes the supplied callback.

Run `dart format`, `flutter analyze`, and `flutter test` before completion.

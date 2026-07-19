import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:customer_painter_fox/fox_waving_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('standalone app shows an accessible painted login button', (
    tester,
  ) async {
    await tester.pumpWidget(const WavingButtonExampleApp());

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.bySemanticsLabel('ВОЙТИ'), findsOneWidget);
  });

  testWidgets('button invokes onPressed when tapped', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: WavingButton(onPressed: () => taps++)),
      ),
    );

    await tester.tap(find.byType(WavingButton));

    expect(taps, 1);
  });

  testWidgets('hover animates the painted button', (tester) async {
    await tester.pumpWidget(const _TestHost(child: WavingButton()));
    final dynamic state = tester.state(find.byType(WavingButton));
    expect(state.debugWaveAmplitude, 0);
    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);

    await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));

    expect(state.debugWaveAmplitude, greaterThan(0));
    expect(state.debugIsAnimating, isTrue);
    await mouse.removePointer();
  });

  testWidgets('pointer exit settles to the original painting', (tester) async {
    await tester.pumpWidget(const _TestHost(child: WavingButton()));
    final dynamic state = tester.state(find.byType(WavingButton));
    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));

    await mouse.moveTo(const Offset(1, 1));
    await tester.pumpAndSettle();

    expect(state.debugWaveAmplitude, 0);
    expect(state.debugIsAnimating, isFalse);
    await mouse.removePointer();
  });

  testWidgets('wave continues softly for the full hover', (tester) async {
    await tester.pumpWidget(const _TestHost(child: WavingButton()));
    final dynamic state = tester.state(find.byType(WavingButton));
    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(state.debugWaveAmplitude, greaterThan(0.9));
    expect(state.debugIsAnimating, isTrue);
    await mouse.removePointer();
  });

  testWidgets('hover wave uses a slow 2.8 second phase cycle', (tester) async {
    await tester.pumpWidget(const _TestHost(child: WavingButton()));
    final dynamic state = tester.state(find.byType(WavingButton));
    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));

    expect(state.debugWavePhase, closeTo(math.pi / 2, 0.01));
    await mouse.removePointer();
  });

  testWidgets('button paints gradient face and white offset accent', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestHost(child: WavingButton()));
    final paintedButton = find.descendant(
      of: find.byType(WavingButton),
      matching: find.byType(CustomPaint),
    );

    expect(
      paintedButton,
      paints
        ..path(hasMaskFilter: true)
        ..path(color: const Color(0xFFFFFFFF))
        ..something(
          (method, arguments) =>
              method == #drawPath && (arguments[1] as Paint).shader != null,
        )
        ..paragraph(),
    );
  });

  testWidgets('white accent stays rigid while colored face waves', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestHost(child: WavingButton()));
    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(WavingButton),
        matching: find.byType(CustomPaint),
      ),
    );
    final resting = _PathRecordingCanvas();
    customPaint.painter!.paint(resting, const Size(500, 100));

    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 180));

    final animated = _PathRecordingCanvas();
    customPaint.painter!.paint(animated, const Size(500, 100));

    expect(
      _pathSignature(animated.whitePath!),
      _pathSignature(resting.whitePath!),
    );
    expect(
      _pathSignature(animated.gradientPath!),
      isNot(_pathSignature(resting.gradientPath!)),
    );
    await mouse.removePointer();
  });

  testWidgets('colored face wave stays within subtle displacement limit', (
    tester,
  ) async {
    await tester.pumpWidget(const _TestHost(child: WavingButton()));
    final customPaint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(WavingButton),
        matching: find.byType(CustomPaint),
      ),
    );
    final resting = _PathRecordingCanvas();
    customPaint.painter!.paint(resting, const Size(500, 100));

    final mouse = await tester.createGesture(kind: ui.PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byType(WavingButton)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 210));
    final animated = _PathRecordingCanvas();
    customPaint.painter!.paint(animated, const Size(500, 100));

    final restingPoints = _pathSignature(resting.gradientPath!);
    final animatedPoints = _pathSignature(animated.gradientPath!);
    final largestVerticalMovement = List.generate(
      restingPoints.length,
      (index) => (animatedPoints[index].dy - restingPoints[index].dy).abs(),
    ).reduce(math.max);

    expect(largestVerticalMovement, lessThanOrEqualTo(2.5));
    await mouse.removePointer();
  });
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: ColoredBox(
      color: const Color(0xFF020329),
      child: Center(
        child: RepaintBoundary(
          key: const ValueKey('button-boundary'),
          child: SizedBox(width: 500, height: 100, child: child),
        ),
      ),
    ),
  );
}

class _PathRecordingCanvas extends TestRecordingCanvas {
  Path? whitePath;
  Path? gradientPath;

  @override
  void drawPath(Path path, Paint paint) {
    if (paint.color == const Color(0xFFFFFFFF)) {
      whitePath = Path.from(path);
    }
    if (paint.shader != null) {
      gradientPath = Path.from(path);
    }
    super.drawPath(path, paint);
  }
}

List<Offset> _pathSignature(Path path) {
  final metric = path.computeMetrics().single;
  return List.generate(11, (index) {
    return metric.getTangentForOffset(metric.length * index / 10)!.position;
  });
}

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(const WavingButtonExampleApp());

class WavingButtonExampleApp extends StatelessWidget {
  const WavingButtonExampleApp({super.key});

  @override
  Widget build(BuildContext context) => const Directionality(
    textDirection: TextDirection.ltr,
    child: ColoredBox(
      color: Color(0xFF020329),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: RepaintBoundary(child: WavingButton()),
        ),
      ),
    ),
  );
}

class WavingButton extends StatefulWidget {
  const WavingButton({this.onPressed, super.key});

  final VoidCallback? onPressed;

  @override
  State<WavingButton> createState() => _WavingButtonState();
}

class _WavingButtonState extends State<WavingButton> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final _WavingButtonController _controller;
  late final CustomPainter _painter;
  Duration? _previousElapsed;

  double get debugWaveAmplitude => _controller.amplitude;
  double get debugWavePhase => _controller.phase;
  bool get debugIsAnimating => _ticker.isTicking;

  @override
  void initState() {
    super.initState();
    final controller = _controller = _WavingButtonController();
    _ticker = createTicker((elapsed) {
      final delta = elapsed - (_previousElapsed ?? Duration.zero);
      if (!controller.onTick(delta)) {
        _ticker.stop();
        _previousElapsed = null;
        return;
      }
      _previousElapsed = elapsed;
    })..stop();
    _painter = _WavingButtonPainter(controller: controller);
  }

  void _setHovered(bool hovered) {
    _controller.setHovered(hovered);
    if (!_ticker.isTicking) {
      _previousElapsed = null;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 1000),
    child: AspectRatio(
      aspectRatio: 5,
      child: Semantics(
        button: true,
        label: 'ВОЙТИ',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => _setHovered(true),
          onExit: (_) => _setHovered(false),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onPressed,
            child: CustomPaint(painter: _painter),
          ),
        ),
      ),
    ),
  );
}

class _WavingButtonPainter extends CustomPainter {
  const _WavingButtonPainter({required _WavingButtonController controller})
    : _controller = controller,
      super(repaint: controller);

  final _WavingButtonController _controller;

  static final Paint _glowPaint = Paint()
    ..color = const Color(0x994A16FF)
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

  static final Paint _accentPaint = Paint()
    ..color = const Color(0xFFFFFFFF)
    ..style = PaintingStyle.fill;

  static final ui.Paragraph _label =
      (ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                fontFamily: 'Arial',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            )
            ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF), letterSpacing: 1.5))
            ..addText('ВОЙТИ'))
          .build();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    const logicalSize = Size(500, 100);
    final amplitude = _controller.amplitude;
    final phase = _controller.phase;
    final face = _buildFacePath(size: logicalSize, amplitude: amplitude, phase: phase);
    final accent = _buildFacePath(
      size: logicalSize,
      amplitude: 0,
      phase: 0,
      offset: const Offset(7, 9),
    );
    final facePaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFF000F5), Color(0xFFB20CFF), Color(0xFF302BFF)],
        stops: [0, 0.48, 1],
      ).createShader(const Rect.fromLTWH(0, 0, 500, 100));

    canvas
      ..save()
      ..scale(size.width / logicalSize.width, size.height / logicalSize.height)
      ..drawPath(face, _glowPaint)
      ..drawPath(accent, _accentPaint)
      ..drawPath(face, facePaint);

    _label.layout(const ui.ParagraphConstraints(width: 500));
    canvas.drawParagraph(
      _label,
      Offset(0, (logicalSize.height - _label.height) / 2 - 7 + math.sin(phase) * amplitude * 0.4),
    );
    canvas.restore();
  }

  Path _buildFacePath({
    required Size size,
    required double amplitude,
    required double phase,
    Offset offset = Offset.zero,
  }) {
    const segments = 28;
    final path = Path();

    for (var index = 0; index <= segments; index++) {
      final t = index / segments;
      final point =
          Offset(
            _lerp(size.width * 0.055, size.width * 0.985, t),
            size.height * 0.16 + _wave(t, phase, amplitude, size.height * 0.025),
          ) +
          offset;
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    for (var index = segments; index >= 0; index--) {
      final t = index / segments;
      final point =
          Offset(
            _lerp(size.width * 0.005, size.width * 0.945, t),
            size.height * 0.73 + _wave(t, phase + math.pi * 0.7, amplitude, size.height * 0.020),
          ) +
          offset;
      path.lineTo(point.dx, point.dy);
    }

    return path..close();
  }

  double _wave(double t, double phase, double amplitude, double maximumOffset) {
    final anchoredEnds = math.sin(math.pi * t);
    return math.sin(phase + t * math.pi * 3) * anchoredEnds * amplitude * maximumOffset;
  }

  double _lerp(double start, double end, double t) => start + (end - start) * t;

  @override
  bool shouldRepaint(_WavingButtonPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_WavingButtonPainter oldDelegate) => false;
}

final class _WavingButtonController with ChangeNotifier {
  static const double _easingRate = 8;
  static const double _settledThreshold = 0.01;
  static const double _waveCyclesPerSecond = 1 / 2.8;

  double get amplitude => _amplitude;
  double _amplitude = 0;

  double get phase => _phase;
  double _phase = 0;

  bool _hovered = false;

  void setHovered(bool hovered) {
    _hovered = hovered;
  }

  bool onTick(Duration delta) {
    final seconds = delta.inMicroseconds / Duration.microsecondsPerSecond;
    final target = _hovered ? 1.0 : 0.0;
    final easing = 1 - math.exp(-_easingRate * seconds);
    _amplitude += (target - _amplitude) * easing;

    if (!_hovered && _amplitude <= _settledThreshold) {
      _amplitude = 0;
      notifyListeners();
      return false;
    }

    _phase = (_phase + seconds * math.pi * 2 * _waveCyclesPerSecond) % (math.pi * 2);
    notifyListeners();
    return true;
  }
}

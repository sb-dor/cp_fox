/*
 * Animated Custom Painter
 * https://gist.github.com/PlugFox/5a0d067bb945057ed2c8adf5702ed893
 * https://dartpad.dev?id=5a0d067bb945057ed2c8adf5702ed893
 * Mike Matiunin <plugfox@gmail.com>, 19 June 2024
 */

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

void main() => runApp(
  const ColoredBox(
    color: Color(0xFF000000),
    child: Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: RepaintBoundary(child: SizedBox.square(dimension: 256, child: AnimatedPainter())),
      ),
    ),
  ),
);

class AnimatedPainter extends StatefulWidget {
  const AnimatedPainter({
    this.duration = const Duration(milliseconds: 500),
    super.key, // ignore: unused_element
  });

  /// The duration of the animation.
  final Duration duration;

  @override
  State<AnimatedPainter> createState() => _AnimatedPainterState();
}

/// State for widget AnimatedPainter.
class _AnimatedPainterState extends State<AnimatedPainter> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final _AnimatedPainterController _controller;
  late final CustomPainter _painter;
  Duration? prevElapsed;

  @override
  void initState() {
    super.initState();
    final controller = _controller = _AnimatedPainterController();
    prevElapsed;
    _ticker = createTicker((elapsed) {
      // elapsed - the elapsed time since the start of the ticker
      final progress = elapsed - (prevElapsed ?? Duration.zero);
      controller.onTick(
        (elapsed.inMicroseconds / widget.duration.inMicroseconds).clamp(0.0, 1.0),
        (progress.inMicroseconds / widget.duration.inMicroseconds).clamp(0.0, 1.0),
        _ticker.stop,
      );
      prevElapsed = elapsed;
    })..stop();
    _painter = _AnimatedPainter(controller: controller);
  }

  void _setPosition(double dx, double dy) {
    _controller.setCoordinate(dx, dy);
    if (_ticker.isTicking) _ticker.stop();
    prevElapsed = null;
    _ticker.start();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1,
    child: LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.biggest.isEmpty) {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTapDown: (details) => _setPosition(
            details.localPosition.dx / constraints.maxWidth,
            details.localPosition.dy / constraints.maxHeight,
          ),
          child: CustomPaint(painter: _painter),
        );
      },
    ),
  );
}

class _AnimatedPainter extends CustomPainter {
  const _AnimatedPainter({required _AnimatedPainterController controller})
    : _controller = controller,
      super(repaint: controller);

  static final Paint _background = Paint()
    ..color = const Color.fromARGB(255, 43, 38, 60)
    ..style = PaintingStyle.fill;

  static final Paint _circle = Paint()
    ..color = const Color(0xFF00FF00)
    ..strokeWidth = 6
    ..style = PaintingStyle.stroke;

  static final ui.Paragraph _text =
      (ui.ParagraphBuilder(
              ui.ParagraphStyle(
                textAlign: TextAlign.center,
                fontSize: 20,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
                textDirection: TextDirection.ltr,
                height: 1,
                textHeightBehavior: const ui.TextHeightBehavior(
                  leadingDistribution: ui.TextLeadingDistribution.even,
                ),
                maxLines: 5,
                ellipsis: '...',
              ),
            )
            ..pushStyle(ui.TextStyle(color: const Color(0xFFFFFFFF)))
            ..addText('Click to move the circle'))
          .build();

  final _AnimatedPainterController _controller;

  @override
  void paint(Canvas canvas, Size size) {
    _text.layout(ui.ParagraphConstraints(width: math.min(size.width, 256)));
    canvas
      ..drawRect(Offset.zero & size, _background)
      ..drawParagraph(
        _text,
        Offset((size.width - _text.width) / 2, (size.height - _text.height) / 2),
      )
      ..drawCircle(
        Offset(_controller.offset.dx * size.width, _controller.offset.dy * size.height),
        16,
        _circle,
      );
  }

  @override
  bool shouldRepaint(_AnimatedPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(_AnimatedPainter oldDelegate) => false;
}

final class _AnimatedPainterController with ChangeNotifier {
  _AnimatedPainterController({double? dx, double? dy})
    : _offset = Offset(dx?.clamp(0, 1) ?? .5, dy?.clamp(0, 1) ?? .5);

  Offset get offset => _offset;
  Offset _offset = Offset.zero;
  bool Function(double elapsed, double progress) _updateCallback = (elapsed, progress) => false;

  void onTick(double elapsed, double progress, void Function() stop) {
    if (elapsed == 0.0) return;
    if (_updateCallback(elapsed, progress)) {
      stop();
    }
    notifyListeners();
  }

  void setCoordinate(double dx, double dy) {
    dx = dx.clamp(0, 1); // ignore: parameter_assignments
    dy = dy.clamp(0, 1); // ignore: parameter_assignments
    final deltaX = (dx - _offset.dx).abs();
    final deltaY = (dy - _offset.dy).abs();
    _updateCallback = (elapsed, progress) {
      if (dx == _offset.dx || dy == _offset.dy) return true;
      _offset = Offset(
        _offset.dx < dx
            ? math.min(_offset.dx + deltaX * progress, dx)
            : math.max(_offset.dx - deltaX * progress, dx),
        _offset.dy < dy
            ? math.min(_offset.dy + deltaY * progress, dy)
            : math.max(_offset.dy - deltaY * progress, dy),
      );
      return false;
    };
    notifyListeners();
  }
}

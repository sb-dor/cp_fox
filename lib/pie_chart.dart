import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(App());
}

typedef PieChartItems = List<PieChartItem>;

class PieChartItem implements Comparable<PieChartItem> {
  const PieChartItem({required this.id, required this.value, required this.color})
    : assert(value >= 0, "Value should be greater or equal to zero");

  final String id;

  final double value;

  final Color color;

  @override
  int compareTo(PieChartItem other) => value.compareTo(other.value);

  PieChartItem copyWith({String? id, double? value, Color? color}) {
    return PieChartItem(id: id ?? this.id, value: value ?? this.value, color: color ?? this.color);
  }

  @override
  String toString() => 'PieChartItem(id: $id, value: $value, color: $color)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PieChartItem && other.id == id && other.value == value && other.color == color;
  }

  @override
  int get hashCode => id.hashCode ^ value.hashCode ^ color.hashCode;
}

class _PieChartController with ChangeNotifier {
  _PieChartController(this._pieChartItems);

  PieChartItems _pieChartItems;

  PieChartItems get current => _pieChartItems;

  double get total => _pieChartItems.fold(0, (total, item) => total += item.value);

  void apply(PieChartItems items) {
    _pieChartItems = items;
    notifyListeners();
  }
}

/// {@template pi_chart}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro pi_chart}
  const App({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<App> createState() => _AppState();
}

/// State for widget App.
class _AppState extends State<App> {
  /* #region Lifecycle */

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      appBar: AppBar(title: Text("Pi Chart")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: PiChart.value(
            items: [
              PieChartItem(id: '1', value: 1, color: Colors.red),
              PieChartItem(id: '2', value: 2, color: Colors.green),
              PieChartItem(id: '3', value: 3, color: Colors.blue),
            ],
          ),
        ),
      ),
    ),
  );
}

/// {@template pi_chart}
/// PiChart widget.
/// {@endtemplate}
class PiChart extends StatefulWidget {
  //
  const PiChart.value({super.key, this.items, this.innerRadius, this.gap, this.labelFormatter})
    : listenable = null;

  const PiChart.listenable({
    super.key,
    this.listenable,
    this.innerRadius,
    this.gap,
    this.labelFormatter,
  }) : items = null;

  final PieChartItems? items;

  final ValueListenable<PieChartItems>? listenable;

  final double? innerRadius;

  final double? gap;

  final String Function(PieChartItem item, double total)? labelFormatter;

  @override
  State<PiChart> createState() => _PiChartState();
}

/// State for widget PiChart.
class _PiChartState extends State<PiChart> {
  //
  PieChartItems get items => widget.items ?? widget.listenable?.value ?? [];

  late final _PieChartController _controller = _PieChartController(items);

  late final ValueNotifier<PiChart> _configuration = ValueNotifier(widget);

  final ValueNotifier<ThemeData> _themeData = ValueNotifier(ThemeData.light());

  late final _pieChartPainter = PieChartPainter(
    controller: _controller,
    configuration: _configuration,
    theme: _themeData,
  );

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    widget.listenable?.addListener(_update);
    _update();
  }

  @override
  void didUpdateWidget(PiChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.listenable, oldWidget.listenable)) {
      oldWidget.listenable?.removeListener(_update);
      widget.listenable?.addListener(_update);
    }
    _configuration.value = widget;
    _update();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _themeData.value = Theme.of(context);
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
    _controller.dispose();
    _configuration.dispose();
    _themeData.dispose();
  }
  /* #endregion */

  void _update() {
    if (!mounted) return;
    _controller.apply(items);
  }

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(child: CustomPaint(painter: _pieChartPainter));
}

/// {@template pi_chart}
/// PiChartPainter.
/// {@endtemplate}
class PieChartPainter extends CustomPainter {
  /// {@macro pi_chart}
  PieChartPainter({required this.controller, required this.configuration, required this.theme})
    : super(repaint: Listenable.merge([configuration, theme]));

  final _PieChartController controller;
  final ValueNotifier<PiChart> configuration;
  final ValueNotifier<ThemeData> theme;

  static Color contrastingTextColor(Color color) {
    final brightness = (299 * color.red + 587 * color.green + 114 * color.blue) / 100;
    return brightness > 128 ? Colors.black : Colors.white;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final total = controller.total;
    final sections = controller.current;
    final widget = configuration.value;
    final themeData = theme.value;

    final diameter = size.shortestSide;
    final radius = diameter / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final innerRadius = radius * (widget.innerRadius?.clamp(0, 1) ?? .6);
    final strokeWidth = radius - innerRadius;
    final gap = (widget.gap?.clamp(0, 64) ?? 4) / 2 / radius;
    var startAngle = -math.pi / 2;
    final labelFormatter =
        widget.labelFormatter ??
        (item, total) => '${(item.value / total * 100).toStringAsFixed(1)}%';

    final paint = Paint();

    if (sections.isEmpty) return;

    for (final item in sections) {
      final sweepAngle = (item.value / total) * 2 * math.pi - gap;
      if (sweepAngle <= 0) continue;

      paint
        ..style = PaintingStyle.fill
        ..color = item.color;

      final section = Path()
        ..addArc(
          Rect.fromCircle(center: center, radius: innerRadius),
          startAngle + gap / 2,
          sweepAngle,
        )
        ..lineTo(
          center.dx + math.cos(startAngle + sweepAngle) * radius,
          center.dy + math.sin(startAngle + sweepAngle) * radius,
        )
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + sweepAngle - gap / 2,
          -sweepAngle,
          false,
        )
        ..lineTo(
          center.dx + math.cos(startAngle) * innerRadius,
          center.dy + math.sin(startAngle) * innerRadius,
        )
        ..close();

      canvas.drawPath(section, paint);

      final textRadius = innerRadius + strokeWidth / 2;
      final sectionCenter =
          center +
          Offset(
            math.cos(startAngle + sweepAngle / 2) * textRadius,
            math.sin(startAngle + sweepAngle / 2) * textRadius,
          );

      final text = labelFormatter(item, total);

      if (text.isNotEmpty) {}
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: themeData.textTheme.labelMedium?.copyWith(
            height: 1,
            color: contrastingTextColor(item.color),
          ),
        ),
        textDirection: .ltr,
        textAlign: .center,
        maxLines: 1,
      )..layout();

      final arcLength = innerRadius * sweepAngle;

      if (textPainter.width < arcLength) {
        textPainter.paint(
          canvas,
          sectionCenter - Offset(textPainter.width / 2, textPainter.height / 2),
        );
      }

      startAngle += sweepAngle + gap;
    }
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) => false;

  @override
  bool shouldRebuildSemantics(covariant PieChartPainter oldDelegate) => false;
}

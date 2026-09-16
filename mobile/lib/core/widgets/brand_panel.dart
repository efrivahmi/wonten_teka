import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Original architectural linework, drawn locally without bitmap downloads.
class BrandPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const BrandPanel(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.all(24)});

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: ColoredBox(
          color: AppColors.primary,
          child: CustomPaint(
              painter: _BrandLines(),
              child: Padding(padding: padding, child: child)),
        ),
      );
}

/// Shared branded backdrop for every mobile route. Content surfaces remain
/// readable while the dashboard banner linework continues across the app.
class BrandPageBackground extends StatelessWidget {
  final Widget child;
  const BrandPageBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE5F5E8), Color(0xFFF7F8F5), Color(0xFFEEF6E8)],
          ),
        ),
        child: CustomPaint(
          painter: const _BrandPageLines(),
          child: child,
        ),
      );
}

class _BrandPageLines extends CustomPainter {
  const _BrandPageLines();

  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = AppColors.primary.withValues(alpha: .055)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (var i = 0; i < 10; i++) {
      final inset = i * 34.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width * .48 + inset, -120 + inset, size.width * .9,
              size.height * .75),
          const Radius.circular(110),
        ),
        pen,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BrandPageLines oldDelegate) => false;
}

class _BrandLines extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final pen = Paint()
      ..color = AppColors.primaryFixed.withValues(alpha: .16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    for (var i = 0; i < 9; i++) {
      final inset = i * 19.0;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(size.width * .62 + inset, -70 + inset,
                  size.width * .65, size.height + 140),
              const Radius.circular(80)),
          pen);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BrandLines oldDelegate) => false;
}

/// One-shot entrance; respects accessibility and pauses when app is inactive.
class ViewEntrance extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double offset;
  const ViewEntrance({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 12,
  });
  @override
  State<ViewEntrance> createState() => _ViewEntranceState();
}

class _ViewEntranceState extends State<ViewEntrance>
    with WidgetsBindingObserver {
  bool _active = true;
  bool _visible = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future<void>.delayed(widget.delay, () {
      if (mounted) setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) setState(() => _active = state == AppLifecycleState.resumed);
  }

  @override
  Widget build(BuildContext context) => TickerMode(
        enabled: _active && TickerMode.valuesOf(context).enabled,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: _visible ? 1 : 0),
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 360),
          curve: Curves.easeOutCubic,
          child: widget.child,
          builder: (_, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                  offset: Offset(0, widget.offset * (1 - value)),
                  child: Transform.scale(
                      scale: .98 + (.02 * value), child: child))),
        ),
      );
}

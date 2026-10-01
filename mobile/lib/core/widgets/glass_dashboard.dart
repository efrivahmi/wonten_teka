import 'dart:ui';

import 'package:flutter/material.dart';

abstract final class DashboardColors {
  static const cyan = Color(0xFF34C982);
  static const cyanDeep = Color(0xFF087A4B);
  static const magenta = Color(0xFF0B8F58);
  static const magentaDeep = Color(0xFF075B3D);
  static const ink = Color(0xFF153B2A);
  static const muted = Color(0xFF5A7666);
  static const glassBorder = Color(0xA6FFFFFF);
}

class DashboardCanvas extends StatelessWidget {
  final Widget child;
  const DashboardCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD9FBE8), Color(0xFFB9F0D0), Color(0xFFE7FAEE)],
          ),
        ),
        child: Stack(fit: StackFit.expand, children: [
          const Positioned(
            top: -110,
            right: -70,
            child: _GlowOrb(size: 270, color: Color(0x350B8F58)),
          ),
          const Positioned(
            left: -140,
            bottom: 80,
            child: _GlowOrb(size: 300, color: Color(0x3216A34A)),
          ),
          child,
        ]),
      );
}

class GlassDashboardPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color tint;
  final bool blur;

  const GlassDashboardPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 24,
    this.tint = const Color(0xCCFFFFFF),
    this.blur = true,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: shape,
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: blur ? 18 : 0,
          sigmaY: blur ? 18 : 0,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: shape,
            border: Border.all(color: DashboardColors.glassBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16044E62),
                blurRadius: 26,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

class DashboardMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final String? note;
  final VoidCallback? onTap;

  const DashboardMetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = GlassDashboardPanel(
      padding: const EdgeInsets.all(15),
      radius: 21,
      tint: Color.lerp(Colors.white, accent, .055)!.withValues(alpha: .91),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Expanded(
              child: Text(label.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: DashboardColors.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.05,
                  )),
            ),
            Icon(icon, color: accent, size: 20),
          ]),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutBack,
            switchOutCurve: Curves.easeIn,
            child: Text(value,
                key: ValueKey(value),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: DashboardColors.ink,
                  fontSize: value.length > 13 ? 17 : 23,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                )),
          ),
          if (note != null) ...[
            const SizedBox(height: 5),
            Text(note!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: DashboardColors.muted, fontSize: 10)),
          ],
        ],
      ),
    );
    return onTap == null
        ? card
        : Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(21),
              child: card,
            ),
          );
  }
}

class DashboardSectionHeading extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  const DashboardSectionHeading({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: const TextStyle(
                    color: DashboardColors.ink,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  )),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!,
                    style: const TextStyle(
                      color: DashboardColors.muted,
                      fontSize: 12,
                      height: 1.35,
                    )),
              ],
            ]),
          ),
          if (action != null) ...[const SizedBox(width: 8), action!],
        ],
      );
}

class DashboardEntrance extends StatelessWidget {
  final Widget child;
  const DashboardEntrance({super.key, required this.child});

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
        child: child,
        builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 16 * (1 - value)),
            child: child,
          ),
        ),
      );
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            boxShadow: [
              BoxShadow(color: color, blurRadius: 70, spreadRadius: 25)
            ],
          ),
        ),
      );
}

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double blur;

  /// Primary tint color. If [tintGradient] is provided, this is ignored.
  final Color tint;
  final double opacity;
  final double? width;
  final double? height;

  /// Optional gradient tint. When provided, replaces the flat [tint] color.
  /// Example:
  ///   tintGradient: LinearGradient(
  ///     colors: [Colors.white.withValues(alpha: 0.25), Colors.white.withValues(alpha: 0.05)],
  ///     begin: Alignment.topLeft,
  ///     end: Alignment.bottomRight,
  ///   )
  final Gradient? tintGradient;

  /// Shadow intensity. Defaults to 0.18 for visible depth (was 0.05 — nearly invisible).
  final double shadowOpacity;

  /// When true, flips defaults for a dark-background-friendly tint.
  /// When false (default), assumes a colorful or dark backdrop.
  /// You can also pass a fully custom [tint] / [tintGradient] regardless of this flag.
  final bool adaptToDarkMode;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 20,
    this.blur = 20,
    this.tint = Colors.white,
    this.opacity = 0.1,
    this.width,
    this.height,
    this.tintGradient,
    this.shadowOpacity = 0.18,
    this.adaptToDarkMode = false,
  });

  /// Resolves the effective tint color, respecting dark-mode adaptation.
  Color _resolvedTint(BuildContext context) {
    if (tintGradient != null) return Colors.transparent; // gradient takes over
    if (adaptToDarkMode) {
      final brightness = Theme.of(context).brightness;
      return brightness == Brightness.dark
          ? Colors.white
          : Colors.black; // dark tint on light backgrounds
    }
    return tint;
  }

  /// Resolves the effective opacity, slightly higher on light backgrounds.
  double _resolvedOpacity(BuildContext context) {
    if (!adaptToDarkMode) return opacity;
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? opacity : opacity * 0.6;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTint = _resolvedTint(context);
    final effectiveOpacity = _resolvedOpacity(context);

    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              // Gradient tint OR flat tint
              gradient: tintGradient ??
                  LinearGradient(
                    colors: [
                      effectiveTint.withValues(alpha: effectiveOpacity + 0.08),
                      effectiveTint.withValues(alpha: effectiveOpacity),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border(
                // Highlight edge: brighter on top-left
                top: BorderSide(
                  color: effectiveTint.withValues(alpha: 0.55),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                left: BorderSide(
                  color: effectiveTint.withValues(alpha: 0.45),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                // Dimmer on bottom-right — light appears to come from top-left
                bottom: BorderSide(
                  color: effectiveTint.withValues(alpha: 0.15),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                right: BorderSide(
                  color: effectiveTint.withValues(alpha: 0.15),
                  width: 1.5,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
              ),
              // Visible shadow (was 0.05, now meaningful)
              boxShadow: [
                BoxShadow(
                  color: effectiveTint.withValues(alpha: shadowOpacity),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

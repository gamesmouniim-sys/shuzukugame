import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlassCard extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? glowColor;
  final bool enableGradient;
  final double blurSigma;

  const GlassCard({
    Key? key,
    required this.child,
    this.borderRadius = 20,
    this.padding,
    this.margin,
    this.onTap,
    this.glowColor,
    this.enableGradient = false,
    this.blurSigma = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cardWidget = Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            decoration: BoxDecoration(
              gradient: enableGradient
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFFFFFFF),
                        Color(0xFFF7F9FC),
                      ],
                    )
                  : null,
              color: !enableGradient ? const Color(0xFFFFFFFF) : null,
              border: Border.all(
                color: const Color(0xFFE1E4E8),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: (glowColor ?? const Color(0x14000000)).withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: padding,
            child: child,
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardWidget,
      );
    }

    return cardWidget;
  }
}

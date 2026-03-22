import 'package:flutter/material.dart';
import 'glass_card.dart';

class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final bool isHighlighted;
  final Color color;

  const StatChip({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    this.isHighlighted = false,
    this.color = const Color(0xFF00FFB2),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      glowColor: isHighlighted ? color : null,
      blurSigma: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isHighlighted ? color : Colors.white.withOpacity(0.6),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: double.parse(
                value.replaceAll(RegExp(r'[^0-9.]'), ''),
              ),
              end: double.parse(
                value.replaceAll(RegExp(r'[^0-9.]'), ''),
              ),
            ),
            duration: const Duration(milliseconds: 600),
            builder: (context, animatedValue, child) {
              return Text(
                '${animatedValue.toStringAsFixed(0)}$unit',
                style: TextStyle(
                  color: isHighlighted ? color : Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

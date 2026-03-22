import 'package:flutter/material.dart';
import '../providers/boost_provider.dart';

class BoostButton extends StatefulWidget {
  final BoostState boostState;
  final VoidCallback onTap;

  const BoostButton({
    Key? key,
    required this.boostState,
    required this.onTap,
  }) : super(key: key);

  @override
  State<BoostButton> createState() => _BoostButtonState();
}

class _BoostButtonState extends State<BoostButton>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _ringController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ringAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _ringController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() {
    if (widget.boostState != BoostState.idle) {
      _pulseController.repeat();
      _ringController.repeat();
    } else {
      _pulseController.stop();
      _ringController.stop();
    }
  }

  @override
  void didUpdateWidget(BoostButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.boostState != widget.boostState) {
      _startAnimations();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const buttonSize = 160.0;
    const accentColor = Color(0xFF00FFB2);

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.boostState != BoostState.idle)
            AnimatedBuilder(
              animation: _ringAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _ringAnimation.value,
                  child: Container(
                    width: buttonSize,
                    height: buttonSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: accentColor.withOpacity(
                          _pulseAnimation.value * 0.5,
                        ),
                        width: 2,
                      ),
                    ),
                  ),
                );
              },
            ),
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accentColor.withOpacity(0.2),
                  accentColor.withOpacity(0.1),
                ],
              ),
              border: Border.all(
                color: accentColor.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accentColor.withOpacity(0.6),
                  blurRadius: widget.boostState == BoostState.active ? 30 : 20,
                  spreadRadius: 2,
                  offset: Offset.zero,
                ),
                if (widget.boostState == BoostState.active)
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 50,
                    spreadRadius: 8,
                    offset: Offset.zero,
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.boostState == BoostState.idle)
                  const Icon(
                    Icons.flash_on,
                    color: accentColor,
                    size: 48,
                  )
                else if (widget.boostState == BoostState.boosting)
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(accentColor),
                      strokeWidth: 3,
                    ),
                  )
                else
                  const Icon(
                    Icons.check_circle,
                    color: accentColor,
                    size: 48,
                  ),
                const SizedBox(height: 8),
                Text(
                  widget.boostState == BoostState.boosting
                      ? 'Boosting...'
                      : widget.boostState == BoostState.active
                          ? 'Active ✓'
                          : 'BOOST',
                  style: TextStyle(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

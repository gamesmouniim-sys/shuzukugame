import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/boost_provider.dart';
import '../providers/navigation_provider.dart';
import '../theme/app_theme.dart';
import '../utils/ad_action_gate.dart';
import '../widgets/glass_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BoostProvider>(
      builder: (context, boostProvider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Shizuku',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => AdActionGate.run(
                        context,
                        action: () {
                          context.read<NavigationProvider>().setTab(3);
                        },
                      ),
                      icon: const Icon(Icons.settings_outlined),
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _StatusCard(
                  icon: Icons.verified_rounded,
                  iconBackground: Color(0xFFE5F2FF),
                  iconColor: AppColors.accentBlue,
                  title: 'Booster profile is active',
                  subtitle: 'Simulation mode for iPhone gaming',
                ),
                const SizedBox(height: 14),
                const _StatusCard(
                  icon: Icons.settings_applications_rounded,
                  iconBackground: Color(0xFFEEF0FF),
                  iconColor: AppColors.accentPurple,
                  title: 'Configured simulation tools',
                  subtitle: 'Open the Shizuku tab to tune each profile',
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.auto_graph_rounded,
                  iconBackground: const Color(0xFFE4FBFF),
                  iconColor: const Color(0xFF20A9C7),
                  title: 'Performance simulation',
                  body:
                      'Use this app to simulate how your preferred graphics, FPS, memory, and network profile would feel during gameplay on iPhone.',
                  actions: [
                    _CardAction(
                      icon: Icons.tune,
                      label: 'Open tools',
                      onTap: () => AdActionGate.run(
                        context,
                        action: () {
                          context.read<NavigationProvider>().setTab(2);
                        },
                      ),
                    ),
                    _CardAction(
                      icon: Icons.play_arrow,
                      label: boostProvider.isBoostActive ? 'Running' : 'Start',
                      onTap: () => AdActionGate.run(
                        context,
                        action: () async {
                          if (boostProvider.isBoostActive) {
                            boostProvider.deactivateBoost();
                          } else {
                            await boostProvider.activateBoost();
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.gps_fixed_rounded,
                  iconBackground: const Color(0xFFE9FBF4),
                  iconColor: const Color(0xFF1EA672),
                  title: 'Shooting training drill',
                  body:
                      'Tap moving targets and test the responsiveness of the configuration you already made in the Shizuku tab.',
                  actions: [
                    _CardAction(
                      icon: Icons.play_circle_outline,
                      label: 'Start drill',
                      onTap: () => AdActionGate.run(
                        context,
                        action: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReactionDrillScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _ActionCard(
                  icon: Icons.thermostat_auto_rounded,
                  iconBackground: const Color(0xFFFFF4DE),
                  iconColor: AppColors.accentOrange,
                  title: 'Thermal balance test',
                  body:
                      'Run an animated thermal simulation and watch heat, stability, and battery load react over time.',
                  actions: [
                    _CardAction(
                      icon: Icons.play_arrow,
                      label: 'Run test',
                      onTap: () => AdActionGate.run(
                        context,
                        action: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ThermalBalanceScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const _StatusCard(
                  icon: Icons.info_outline_rounded,
                  iconBackground: Color(0xFFF2F4F8),
                  iconColor: Color(0xFF7B8794),
                  title: 'Simulation only',
                  subtitle:
                      'This app is an iOS simulation inspired by Shizuku workflows. It does not control the real Shizuku service.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ReactionDrillScreen extends StatefulWidget {
  const ReactionDrillScreen({super.key});

  @override
  State<ReactionDrillScreen> createState() => _ReactionDrillScreenState();
}

class _ReactionDrillScreenState extends State<ReactionDrillScreen> {
  final Random _random = Random();
  Offset _target = const Offset(0.5, 0.3);
  int _hits = 0;
  int _misses = 0;
  int _timeLeft = 20;
  Timer? _timer;
  int _fps = 90;
  int _ping = 28;
  double _ramUsage = 4.3;

  @override
  void initState() {
    super.initState();
    _moveTarget();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        _fps = 82 + _random.nextInt(22);
        _ping = 18 + _random.nextInt(24);
        _ramUsage = 3.8 + _random.nextDouble() * 1.7;
        if (_timeLeft <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _moveTarget() {
    _target = Offset(
      0.15 + _random.nextDouble() * 0.7,
      0.2 + _random.nextDouble() * 0.6,
    );
  }

  void _restartDrill() {
    _timer?.cancel();
    setState(() {
      _hits = 0;
      _misses = 0;
      _timeLeft = 20;
      _fps = 90;
      _ping = 28;
      _ramUsage = 4.3;
      _moveTarget();
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _timeLeft--;
        _fps = 82 + _random.nextInt(22);
        _ping = 18 + _random.nextInt(24);
        _ramUsage = 3.8 + _random.nextDouble() * 1.7;
        if (_timeLeft <= 0) {
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Shooting Drill')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Hits: $_hits',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Misses: $_misses',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text('Time: ${_timeLeft}s',
                          style: const TextStyle(fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('FPS: $_fps',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      Text('Ping: ${_ping}ms',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      Text('RAM: ${_ramUsage.toStringAsFixed(1)} GB',
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GlassCard(
                padding: const EdgeInsets.all(12),
                child: _timeLeft > 0
                    ? LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              setState(() {
                                _misses++;
                              });
                            },
                            child: Stack(
                              children: [
                                const Center(
                                  child: Text(
                                    'Tap the moving target',
                                    style: TextStyle(
                                        color: AppColors.textSecondary),
                                  ),
                                ),
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 280),
                                  curve: Curves.easeInOut,
                                  left: constraints.maxWidth * _target.dx - 28,
                                  top: constraints.maxHeight * _target.dy - 28,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _hits++;
                                        _moveTarget();
                                      });
                                    },
                                    child: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: AppColors.accentRed
                                            .withValues(alpha: 0.12),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.accentRed,
                                            width: 2),
                                      ),
                                      child: const Icon(Icons.gps_fixed,
                                          color: AppColors.accentRed),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Drill Complete',
                              style: TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 16),
                            Text('Total Hits: $_hits'),
                            Text('Total Misses: $_misses'),
                            Text(
                                'Accuracy: ${((_hits / ((_hits + _misses) == 0 ? 1 : (_hits + _misses))) * 100).toStringAsFixed(0)}%'),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () => AdActionGate.run(
                                context,
                                action: _restartDrill,
                              ),
                              child: const Text('Restart'),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThermalBalanceScreen extends StatefulWidget {
  const ThermalBalanceScreen({super.key});

  @override
  State<ThermalBalanceScreen> createState() => _ThermalBalanceScreenState();
}

class _ThermalBalanceScreenState extends State<ThermalBalanceScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Thermal Balance Test')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final heat = 36 + (_controller.value * 8);
            final stability = 92 - (_controller.value * 18);
            final battery = 18 + (_controller.value * 30);
            return Column(
              children: [
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              const Color(0xFFFFD7C2),
                              Color.lerp(
                                const Color(0xFFFFB07A),
                                const Color(0xFFE25555),
                                _controller.value,
                              )!,
                            ],
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${heat.toStringAsFixed(1)}°C',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _MetricRow(
                          label: 'Stability',
                          value: '${stability.toStringAsFixed(0)}%'),
                      const SizedBox(height: 10),
                      _MetricRow(
                          label: 'Battery Load',
                          value: '${battery.toStringAsFixed(0)}%'),
                      const SizedBox(height: 10),
                      _MetricRow(
                          label: 'Verdict',
                          value: heat < 41 ? 'Balanced' : 'Warming up'),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _LeadingIcon(
              icon: icon, background: iconBackground, color: iconColor),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.35,
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

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.actions,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String body;
  final List<_CardAction> actions;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 14,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LeadingIcon(
                  icon: icon, background: iconBackground, color: iconColor),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 18),
                    Text(
                      body,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          for (final action in actions)
            InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Icon(action.icon, color: AppColors.accent, size: 22),
                    const SizedBox(width: 16),
                    Text(
                      action.label,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _LeadingIcon extends StatelessWidget {
  const _LeadingIcon({
    required this.icon,
    required this.background,
    required this.color,
  });

  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 28),
    );
  }
}

class _CardAction {
  const _CardAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

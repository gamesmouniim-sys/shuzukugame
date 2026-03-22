import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/shizuku_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/adb_terminal.dart';
import '../models/game_model.dart';
import '../theme/app_theme.dart';
import '../utils/ad_action_gate.dart';

class ShizukuCoreScreen extends StatefulWidget {
  const ShizukuCoreScreen({Key? key}) : super(key: key);

  @override
  State<ShizukuCoreScreen> createState() => _ShizukuCoreScreenState();
}

class _ShizukuCoreScreenState extends State<ShizukuCoreScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShizukuStatusCard(context, provider),
              const SizedBox(height: 24),
              _buildPairedAppsSection(context, provider),
              const SizedBox(height: 24),
              _buildAdbShellSection(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShizukuStatusCard(
      BuildContext context, ShizukuProvider provider) {
    final isRunning = provider.isRunning;

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Simulation Hub',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.2)
                    .animate(_pulseController),
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: isRunning ? Colors.green[400] : Colors.red[400],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isRunning
                            ? Colors.green.withValues(alpha: 0.6)
                            : Colors.red.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isRunning ? 'Shizuku Running' : 'Shizuku Stopped',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isRunning ? Colors.green[300] : Colors.red[300],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Mode', 'Interactive iPhone gaming simulation'),
          const SizedBox(height: 12),
          _buildInfoRow('Version', 'Profile Engine v1.0'),
          const SizedBox(height: 12),
          _buildInfoRow('Scope', 'Graphics, FPS, memory, and network'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: provider.isRestartingOrTransitioning
                      ? null
                      : () => AdActionGate.run(
                            context,
                            action: () => _handleRestartShizuku(
                              context,
                              provider,
                            ),
                          ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.accent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: provider.isRestartingOrTransitioning
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accent.withValues(alpha: 0.8),
                            ),
                          ),
                        )
                      : const Text(
                          'Restart Shizuku',
                          style: TextStyle(color: AppColors.accent),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: isRunning
                      ? () => AdActionGate.runRewardedShizukuAction(
                            context,
                            action: () => _handleStopShizuku(
                              context,
                              provider,
                            ),
                          )
                      : () => AdActionGate.runRewardedShizukuAction(
                            context,
                            action: () => _handleStartShizuku(
                              context,
                              provider,
                            ),
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isRunning ? Colors.red[600] : Colors.green[600],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isRunning ? 'Stop Shizuku' : 'Start Shizuku',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPairedAppsSection(
      BuildContext context, ShizukuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Simulation Tools',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.pairedApps.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final app = provider.pairedApps[index];
            return GlassCard(
              onTap: () => AdActionGate.run(
                context,
                action: () => _openMiniApp(context, app),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      app.icon,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          app.description,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => AdActionGate.run(
                      context,
                      action: () => _showAppInfoDialog(context, app),
                    ),
                    icon: const Icon(
                      Icons.info_outline,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.9,
                    child: Switch(
                      value: app.isActive,
                      onChanged: (value) {
                        provider.toggleApp(app.id);
                        AdActionGate.run(
                          context,
                          action: () {},
                        );
                      },
                      activeColor: AppColors.accent,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdbShellSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ADB Shell Simulator',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: const AdbTerminal(),
        ),
      ],
    );
  }

  void _showAppInfoDialog(BuildContext context, PairedApp app) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          app.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              app.description,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Status: ${app.isActive ? "Active" : "Inactive"}',
              style: TextStyle(
                color: app.isActive ? Colors.green[300] : Colors.red[300],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Profile ID: ${app.packageName}',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  void _openMiniApp(BuildContext context, PairedApp app) {
    Widget screen;

    switch (app.id) {
      case 'gfx_tool':
        screen = const GfxToolScreen();
        break;
      case 'fps_unlocker':
        screen = const FpsUnlockerScreen();
        break;
      case 'training_drills':
        screen = const TrainingDrillsScreen();
        break;
      case 'color_blendr':
        screen = const ColorBlendrScreen();
        break;
      case 'darq':
        screen = const DarQScreen();
        break;
      case 'ram_manager':
        screen = const RamManagerScreen();
        break;
      case 'network_optimizer':
        screen = const NetworkOptimizerScreen();
        break;
      case 'ping_tester':
        screen = const PingTesterScreen();
        break;
      default:
        screen = const Scaffold(
          body: Center(
            child: Text('Unknown app'),
          ),
        );
    }

    Navigator.of(context).push(
      CupertinoPageRoute(builder: (context) => screen),
    );
  }

  void _handleRestartShizuku(
      BuildContext context, ShizukuProvider provider) async {
    await provider.restartShizuku();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Shizuku restarted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _handleStopShizuku(BuildContext context, ShizukuProvider provider) {
    provider.stopShizuku();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shizuku stopped'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleStartShizuku(BuildContext context, ShizukuProvider provider) {
    provider.startShizuku();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Shizuku started'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}

class GfxToolScreen extends StatefulWidget {
  const GfxToolScreen({Key? key}) : super(key: key);

  @override
  State<GfxToolScreen> createState() => _GfxToolScreenState();
}

class _GfxToolScreenState extends State<GfxToolScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'GFX Tool',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resolution',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildResolutionChip('720p', '720p'),
                    const SizedBox(width: 12),
                    _buildResolutionChip('1080p', '1080p'),
                    const SizedBox(width: 12),
                    _buildResolutionChip('2K', '2K'),
                  ],
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Shadow Quality',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: provider.gfxShadowQuality,
                        onChanged: (value) {
                          provider.setGfxShadowQuality(value);
                        },
                        activeColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Anti-aliasing',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: provider.gfxAntiAliasing,
                        onChanged: (value) {
                          provider.setGfxAntiAliasing(value);
                        },
                        activeColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Texture Quality',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Slider(
                        value: provider.gfxTextureQuality,
                        onChanged: (value) {
                          provider.setGfxTextureQuality(value);
                        },
                        min: 0.0,
                        max: 1.0,
                        activeColor: AppColors.accent,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(provider.gfxTextureQuality * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.applyGfxSettings();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Graphics profile updated'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Apply Graphics Profile',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResolutionChip(String label, String value) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          context.read<ShizukuProvider>().setGfxResolution(value);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: context.watch<ShizukuProvider>().gfxResolution == value
                ? AppColors.accent
                : Colors.transparent,
            border: Border.all(color: AppColors.accent),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.watch<ShizukuProvider>().gfxResolution == value
                  ? Colors.white
                  : AppColors.accent,
            ),
          ),
        ),
      ),
    );
  }
}

class FpsUnlockerScreen extends StatefulWidget {
  const FpsUnlockerScreen({Key? key}) : super(key: key);

  @override
  State<FpsUnlockerScreen> createState() => _FpsUnlockerScreenState();
}

class _FpsUnlockerScreenState extends State<FpsUnlockerScreen>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'FPS Unlocker',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Target FPS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [60, 90, 120, 144, 165].map((fps) {
                    final isSelected = provider.fpsUnlockerTarget == fps;
                    return GestureDetector(
                      onTap: () {
                        provider.setFpsUnlockerTarget(fps);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$fps',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppColors.accent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Refresh Rate Sync',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: provider.fpsRefreshRateSync,
                        onChanged: (value) {
                          provider.setFpsRefreshRateSync(value);
                        },
                        activeColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Frame Pacing',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: provider.fpsFramePacing,
                        onChanged: (value) {
                          provider.setFpsFramePacing(value);
                        },
                        activeColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.08)
                      .animate(_glowController),
                  child: SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          if (_glowController.isAnimating)
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.6),
                              blurRadius: 16,
                              spreadRadius: 4,
                            ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          _glowController.forward().then((_) {
                            _glowController.reverse();
                          });
                          provider.applyFpsUnlock();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'FPS unlocked to ${provider.fpsUnlockerTarget}!',
                              ),
                              backgroundColor: Colors.green,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Apply FPS Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class TrainingDrillsScreen extends StatefulWidget {
  const TrainingDrillsScreen({Key? key}) : super(key: key);

  @override
  State<TrainingDrillsScreen> createState() => _TrainingDrillsScreenState();
}

class _TrainingDrillsScreenState extends State<TrainingDrillsScreen> {
  String selectedDrill = 'Reaction';
  int selectedDuration = 3;

  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Training Drills',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Drill Type',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ['Reaction', 'Tracking', 'Endurance'].map((drill) {
                    final isSelected = selectedDrill == drill;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDrill = drill),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          drill,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Duration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: [2, 3, 5].map((minutes) {
                    final isSelected = selectedDuration == minutes;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDuration = minutes),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$minutes min',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Graphics: ${provider.gfxResolution}\nFPS target: ${provider.fpsUnlockerTarget}\nMemory auto-clean: ${provider.ramAutoClean ? "On" : "Off"}\nNetwork preset: ${provider.networkDns}',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '$selectedDrill drill started for $selectedDuration minutes',
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start Drill',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ColorBlendrScreen extends StatefulWidget {
  const ColorBlendrScreen({Key? key}) : super(key: key);

  @override
  State<ColorBlendrScreen> createState() => _ColorBlendrScreenState();
}

class _ColorBlendrScreenState extends State<ColorBlendrScreen> {
  double red = 53;
  double green = 106;
  double blue = 230;

  Color get currentColor =>
      Color.fromARGB(255, red.round(), green.round(), blue.round());

  String get hexCode =>
      '#${red.round().toRadixString(16).padLeft(2, '0')}${green.round().toRadixString(16).padLeft(2, '0')}${blue.round().toRadixString(16).padLeft(2, '0')}'
          .toUpperCase();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('ColorBlendr')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: currentColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(hexCode,
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700)),
                      TextButton(
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: hexCode));
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Color code copied')),
                          );
                        },
                        child: const Text('Copy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _ColorSlider(
                label: 'Red',
                value: red,
                activeColor: Colors.red,
                onChanged: (v) => setState(() => red = v)),
            _ColorSlider(
                label: 'Green',
                value: green,
                activeColor: Colors.green,
                onChanged: (v) => setState(() => green = v)),
            _ColorSlider(
                label: 'Blue',
                value: blue,
                activeColor: Colors.blue,
                onChanged: (v) => setState(() => blue = v)),
          ],
        ),
      ),
    );
  }
}

class DarQScreen extends StatelessWidget {
  const DarQScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        final colors = [
          AppColors.accent,
          AppColors.accentBlue,
          AppColors.accentPurple,
          AppColors.accentOrange,
          AppColors.accentPink,
        ];
        final themes = ['Dark', 'AMOLED Black', 'Purple Dark'];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(title: const Text('DarQ')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'App Theme',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: themes.map((theme) {
                    final selected = provider.selectedTheme == theme;
                    return ChoiceChip(
                      label: Text(theme),
                      selected: selected,
                      onSelected: (_) => provider.setSelectedTheme(theme),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Main Button Color',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: colors.map((color) {
                    final selected =
                        provider.selectedAccent.toARGB32() == color.toARGB32();
                    return GestureDetector(
                      onTap: () => provider.setSelectedAccent(color),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('DarQ appearance updated')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: provider.selectedAccent,
                      minimumSize: const Size(double.infinity, 52),
                    ),
                    child: const Text('Preview Main Button',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class PingTesterScreen extends StatefulWidget {
  const PingTesterScreen({Key? key}) : super(key: key);

  @override
  State<PingTesterScreen> createState() => _PingTesterScreenState();
}

class _PingTesterScreenState extends State<PingTesterScreen> {
  final Random _random = Random();
  String selectedRegion = 'EU';
  int ping = 42;
  bool testing = false;

  Future<void> _runTest() async {
    setState(() => testing = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      if (selectedRegion == 'EU') {
        ping = 18 + _random.nextInt(18);
      } else if (selectedRegion == 'US') {
        ping = 70 + _random.nextInt(25);
      } else if (selectedRegion == 'Asia') {
        ping = 120 + _random.nextInt(40);
      } else {
        ping = 45 + _random.nextInt(20);
      }
      testing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Ping Tester')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              children: ['EU', 'US', 'Asia'].map((region) {
                return ChoiceChip(
                  label: Text(region),
                  selected: selectedRegion == region,
                  onSelected: (_) => setState(() => selectedRegion = region),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text('$ping ms',
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Selected region: $selectedRegion',
                      style: const TextStyle(color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: testing ? null : _runTest,
                child: Text(testing ? 'Testing...' : 'Run Ping Test'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorSlider extends StatelessWidget {
  const _ColorSlider({
    required this.label,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  final String label;
  final double value;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${value.round()}'),
          Slider(
            value: value,
            max: 255,
            activeColor: activeColor,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class RamManagerScreen extends StatefulWidget {
  const RamManagerScreen({Key? key}) : super(key: key);

  @override
  State<RamManagerScreen> createState() => _RamManagerScreenState();
}

class _RamManagerScreenState extends State<RamManagerScreen>
    with TickerProviderStateMixin {
  late AnimationController _ramAnimationController;

  @override
  void initState() {
    super.initState();
    _ramAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _ramAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'RAM Manager',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 200,
                    child: CustomPaint(
                      painter: RamGaugePainter(
                        ramUsage: provider.simulatedRamUsage,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${(provider.simulatedRamUsage * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${(provider.simulatedRamUsage * 8).toStringAsFixed(1)} / 8 GB',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _ramAnimationController.forward().then((_) {
                        provider.cleanRam();
                        _ramAnimationController.reset();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('RAM cleaned successfully'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Clean RAM',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Auto-clean RAM',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Switch(
                        value: provider.ramAutoClean,
                        onChanged: (value) {
                          provider.setRamAutoClean(value);
                        },
                        activeColor: AppColors.accent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.ramAutoClean) ...[
                  const Text(
                    'Clean Interval',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    children: [15, 30, 60].map((minutes) {
                      final isSelected = provider.ramCleanInterval == minutes;
                      return GestureDetector(
                        onTap: () {
                          provider.setRamCleanInterval(minutes);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${minutes}m',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected ? Colors.black : AppColors.accent,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class RamGaugePainter extends CustomPainter {
  final double ramUsage;

  RamGaugePainter({required this.ramUsage});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.surface
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;

    final gaugePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 20;

    canvas.drawCircle(center, radius, paint);

    final startAngle = -3.14159 * 0.75;
    const sweepAngle = 3.14159 * 1.5;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * ramUsage,
      false,
      gaugePaint,
    );
  }

  @override
  bool shouldRepaint(RamGaugePainter oldDelegate) =>
      oldDelegate.ramUsage != ramUsage;
}

class NetworkOptimizerScreen extends StatefulWidget {
  const NetworkOptimizerScreen({Key? key}) : super(key: key);

  @override
  State<NetworkOptimizerScreen> createState() => _NetworkOptimizerScreenState();
}

class _NetworkOptimizerScreenState extends State<NetworkOptimizerScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Network Optimizer',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'DNS Server',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  children: ['Google', 'Cloudflare', 'Custom'].map((dns) {
                    final isSelected = provider.networkDns == dns;
                    return GestureDetector(
                      onTap: () {
                        provider.setNetworkDns(dns);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.accent
                                : AppColors.border,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          dns,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.black : AppColors.accent,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        'Network Ping',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${provider.networkPing}',
                        style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'ms',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.optimizeNetwork().then((_) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Network optimized! Ping: ${provider.networkPing} ms',
                            ),
                            backgroundColor: Colors.green,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Optimize Network',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

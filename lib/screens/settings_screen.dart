import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/shizuku_provider.dart';
import '../widgets/glass_card.dart';
import '../theme/app_theme.dart';
import '../utils/ad_action_gate.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: 'Gamer');
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ShizukuProvider>(
      builder: (context, provider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GlassCard(
                borderRadius: 14,
                padding: const EdgeInsets.all(16),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.accent,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'This app is a UI simulation inspired by the Shizuku app. It does not provide real Shizuku management on iOS.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildProfileSection(context),
              const SizedBox(height: 32),
              _buildPerformanceSection(context, provider),
              const SizedBox(height: 24),
              _buildDisplaySection(context, provider),
              const SizedBox(height: 24),
              _buildShizukuSection(context, provider),
              const SizedBox(height: 24),
              _buildAboutSection(context, provider),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accent,
                  AppColors.accentPurple,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.gamepad,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gamer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Active Profile',
                  style: TextStyle(
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
              action: () => _showRenameDialog(context),
            ),
            icon: const Icon(
              Icons.edit,
              color: AppColors.accent,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceSection(
      BuildContext context, ShizukuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Performance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Auto-boost on game launch',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: provider.autoBoostOnLaunch,
                onChanged: (value) {
                  provider.setAutoBoostOnLaunch(value);
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
                'Background optimization',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: provider.backgroundOptimization,
                onChanged: (value) {
                  provider.setBackgroundOptimization(value);
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
                'Aggressive mode',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: provider.aggressiveMode,
                onChanged: (value) {
                  if (value) {
                    _showAggressiveModeWarning(context, provider);
                  } else {
                    provider.setAggressiveMode(false);
                  }
                },
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplaySection(BuildContext context, ShizukuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Display',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Theme',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildThemeChip('Dark', provider),
                  const SizedBox(width: 12),
                  _buildThemeChip('AMOLED Black', provider),
                  const SizedBox(width: 12),
                  _buildThemeChip('Purple Dark', provider),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Accent Color',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildColorCircle(
                    const Color(0xFF00FFB2),
                    provider.selectedAccent.value == 0xFF00FFB2,
                    () => provider.setSelectedAccent(const Color(0xFF00FFB2)),
                  ),
                  _buildColorCircle(
                    const Color(0xFF00B4FF),
                    provider.selectedAccent.value == 0xFF00B4FF,
                    () => provider.setSelectedAccent(const Color(0xFF00B4FF)),
                  ),
                  _buildColorCircle(
                    const Color(0xFF7B5EA7),
                    provider.selectedAccent.value == 0xFF7B5EA7,
                    () => provider.setSelectedAccent(const Color(0xFF7B5EA7)),
                  ),
                  _buildColorCircle(
                    const Color(0xFFFF6B35),
                    provider.selectedAccent.value == 0xFFFF6B35,
                    () => provider.setSelectedAccent(const Color(0xFFFF6B35)),
                  ),
                  _buildColorCircle(
                    const Color(0xFFFF3CAC),
                    provider.selectedAccent.value == 0xFFFF3CAC,
                    () => provider.setSelectedAccent(const Color(0xFFFF3CAC)),
                  ),
                ],
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
                'Show FPS overlay',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: provider.showFpsOverlay,
                onChanged: (value) {
                  provider.setShowFpsOverlay(value);
                },
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeChip(String label, ShizukuProvider provider) {
    final isSelected = provider.selectedTheme == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          provider.setSelectedTheme(label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 3,
          ),
        ),
      ),
    );
  }

  Widget _buildShizukuSection(BuildContext context, ShizukuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Simulation',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Auto-start performance session',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Switch(
                value: provider.autoStart,
                onChanged: (value) {
                  provider.setAutoStart(value);
                },
                activeColor: AppColors.accent,
              ),
            ],
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Simulation profile',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${provider.selectedTheme} / Performance Ready',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () => AdActionGate.run(
                      context,
                      action: () {
                        Clipboard.setData(
                          ClipboardData(
                            text:
                                '${provider.selectedTheme} / Performance Ready',
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Simulation profile copied'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                    icon: const Icon(
                      Icons.copy,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdbMethodChip(String label, ShizukuProvider provider) {
    final isSelected = provider.adbMethod == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          provider.setAdbMethod(label);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accent : Colors.transparent,
            border: Border.all(
              color: isSelected ? AppColors.accent : AppColors.border,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.black : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, ShizukuProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'App Version',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '1.0.0',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
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
                'Shizuku Core',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '13.5.4',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => _shareApp(context),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Share App',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.ios_share,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: _rateApp,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rate App',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(
                  Icons.star_outline,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => AdActionGate.run(
              context,
              action: () => _openUrl(
                'https://games-apps-store.blogspot.com/p/privacy-policy.html',
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            onTap: () => AdActionGate.run(
              context,
              action: () => _openUrl(
                'https://games-apps-store.blogspot.com/p/terms-of-use.html',
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showRenameDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Rename Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _usernameController,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter new name',
            hintStyle: const TextStyle(color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _shareApp(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    await Share.share(
      'Shizuku Game Booster\nhttps://apps.apple.com/app/6760973343',
      sharePositionOrigin:
          box == null ? null : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  Future<void> _rateApp() async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) {
      await review.requestReview();
      return;
    }
    await review.openStoreListing(appStoreId: '6760973343');
  }

  Future<void> _openUrl(String url) async {
    await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
  }

  void _showAggressiveModeWarning(
      BuildContext context, ShizukuProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          '⚠️ Aggressive Mode',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Aggressive mode may cause heating and battery drain. Continue?',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.accent),
            ),
          ),
          TextButton(
            onPressed: () {
              provider.setAggressiveMode(true);
              Navigator.pop(context);
            },
            child: const Text(
              'Enable',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCheckUpdatesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: SizedBox(
          height: 100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
              const SizedBox(height: 16),
              const Text(
                'Checking for updates...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPolicyBottomSheet(BuildContext context, String title) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.surface,
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    title == 'Privacy Policy'
                        ? _getPrivacyPolicyText()
                        : _getTermsOfServiceText(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        content: SizedBox(
          height: 80,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accent),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading $title...',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      Navigator.pop(context);
    });
  }

  String _getPrivacyPolicyText() {
    return 'Privacy Policy\n\n'
        'Last Updated: March 2026\n\n'
        'Shizuku Game Booster ("we" or "us") respects your privacy. This Privacy Policy explains how we collect, use, and protect your information.\n\n'
        'Information Collection\n'
        'We collect information about your device performance metrics, app usage patterns, and game preferences to optimize performance.\n\n'
        'Data Usage\n'
        'Your data is used solely to improve the app experience and provide better optimization recommendations. We do not sell your data.\n\n'
        'Security\n'
        'We implement industry-standard security measures to protect your information from unauthorized access.\n\n'
        'Contact Us\n'
        'If you have questions about this Privacy Policy, please contact us at privacy@shizuku-booster.app';
  }

  String _getTermsOfServiceText() {
    return 'Terms of Service\n\n'
        'Last Updated: March 2026\n\n'
        'These Terms of Service ("Terms") govern your use of the Shizuku Game Booster application.\n\n'
        'License Grant\n'
        'We grant you a limited, non-exclusive license to use this application for personal, non-commercial purposes.\n\n'
        'Restrictions\n'
        'You may not reverse engineer, decompile, or attempt to gain unauthorized access to the application or Shizuku services.\n\n'
        'Disclaimer\n'
        'The application is provided "as is" without warranties of any kind. We are not liable for any damages resulting from app use.\n\n'
        'Modification\n'
        'We reserve the right to modify these Terms at any time. Your continued use constitutes acceptance of modifications.\n\n'
        'Governing Law\n'
        'These Terms are governed by applicable local laws.';
  }
}

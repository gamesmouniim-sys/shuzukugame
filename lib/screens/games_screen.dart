import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/game_model.dart';
import '../theme/app_theme.dart';
import '../utils/ad_action_gate.dart';
import '../widgets/glass_card.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  late List<GameModel> games;

  @override
  void initState() {
    super.initState();
    games = GameModel.defaultGames();
  }

  void _updateGame(int index, GameModel updatedGame) {
    setState(() {
      games[index] = updatedGame;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Game Library',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${games.length} games configured',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: games.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GameCard(
                    game: games[index],
                    onOptimize: () {
                      AdActionGate.run(
                        context,
                        action: () {
                          final updated =
                              games[index].copyWith(isOptimized: true);
                          _updateGame(index, updated);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Optimizing ${games[index].name}...',
                                style: GoogleFonts.inter(),
                              ),
                              backgroundColor: AppColors.accentPurple,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                      );
                    },
                    onSettings: () {
                      AdActionGate.run(
                        context,
                        action: () {
                          _showGameSettingsSheet(context, index);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _showGameSettingsSheet(BuildContext context, int gameIndex) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      builder: (context) {
        return GameSettingsSheet(
          game: games[gameIndex],
          onApply: (updatedGame) {
            _updateGame(gameIndex, updatedGame);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '✓ Settings applied via Shizuku for ${updatedGame.name}',
                  style: GoogleFonts.inter(),
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}

class GameCard extends StatelessWidget {
  final GameModel game;
  final VoidCallback onOptimize;
  final VoidCallback onSettings;

  const GameCard({
    Key? key,
    required this.game,
    required this.onOptimize,
    required this.onSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: game.iconColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  game.icon,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                game.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              game.isOptimized
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Optimized ✓',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: onOptimize,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Tap to Optimize',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
              const SizedBox(height: 8),
              Text(
                'Recommended: ${game.recommendedFps} FPS',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                Icons.settings,
                color: AppColors.textSecondary,
                size: 18,
              ),
              onPressed: onSettings,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }
}

class GameSettingsSheet extends StatefulWidget {
  final GameModel game;
  final Function(GameModel) onApply;

  const GameSettingsSheet({
    Key? key,
    required this.game,
    required this.onApply,
  }) : super(key: key);

  @override
  State<GameSettingsSheet> createState() => _GameSettingsSheetState();
}

class _GameSettingsSheetState extends State<GameSettingsSheet> {
  late int selectedFps;
  late String selectedGraphicsQuality;
  late bool antiLagEnabled;
  late bool networkPriorityEnabled;

  @override
  void initState() {
    super.initState();
    selectedFps = widget.game.selectedFps;
    selectedGraphicsQuality = widget.game.graphicsQuality;
    antiLagEnabled = widget.game.antiLag;
    networkPriorityEnabled = widget.game.networkPriority;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: AppColors.surface,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.game.name,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'FPS Selector',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [30, 60, 90, 120, 144].map((fps) {
                  final isSelected = selectedFps == fps;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFps = fps;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$fps',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Graphics Quality',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Low', 'Medium', 'High', 'Ultra'].map((quality) {
                  final isSelected = selectedGraphicsQuality == quality;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedGraphicsQuality = quality;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.accent
                              : AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          quality,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.background
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
            _buildToggleRow('Anti-Lag', antiLagEnabled, (value) {
              setState(() {
                antiLagEnabled = value;
              });
            }),
            const SizedBox(height: 16),
            _buildToggleRow('Network Priority', networkPriorityEnabled,
                (value) {
              setState(() {
                networkPriorityEnabled = value;
              });
            }),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => AdActionGate.run(
                  context,
                  action: () {
                    final updatedGame = widget.game.copyWith(
                      selectedFps: selectedFps,
                      graphicsQuality: selectedGraphicsQuality,
                      antiLag: antiLagEnabled,
                      networkPriority: networkPriorityEnabled,
                      isOptimized: true,
                    );
                    widget.onApply(updatedGame);
                  },
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Apply with Shizuku',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.background,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleRow(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accent,
          inactiveThumbColor: AppColors.textMuted,
        ),
      ],
    );
  }
}

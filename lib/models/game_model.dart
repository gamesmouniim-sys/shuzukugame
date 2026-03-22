import 'package:flutter/material.dart';

class GameModel {
  final String id;
  final String name;
  final Color iconColor;
  final Color iconColorSecondary;
  final IconData icon;
  final int recommendedFps;
  bool isOptimized;
  int selectedFps;
  String graphicsQuality;
  bool antiLag;
  bool networkPriority;

  GameModel({
    required this.id,
    required this.name,
    required this.iconColor,
    required this.iconColorSecondary,
    required this.icon,
    required this.recommendedFps,
    this.isOptimized = false,
    this.selectedFps = 60,
    this.graphicsQuality = 'High',
    this.antiLag = true,
    this.networkPriority = false,
  });

  GameModel copyWith({
    String? id,
    String? name,
    Color? iconColor,
    Color? iconColorSecondary,
    IconData? icon,
    int? recommendedFps,
    bool? isOptimized,
    int? selectedFps,
    String? graphicsQuality,
    bool? antiLag,
    bool? networkPriority,
  }) {
    return GameModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconColor: iconColor ?? this.iconColor,
      iconColorSecondary: iconColorSecondary ?? this.iconColorSecondary,
      icon: icon ?? this.icon,
      recommendedFps: recommendedFps ?? this.recommendedFps,
      isOptimized: isOptimized ?? this.isOptimized,
      selectedFps: selectedFps ?? this.selectedFps,
      graphicsQuality: graphicsQuality ?? this.graphicsQuality,
      antiLag: antiLag ?? this.antiLag,
      networkPriority: networkPriority ?? this.networkPriority,
    );
  }

  static List<GameModel> defaultGames() {
    return [
      GameModel(
        id: 'pubg',
        name: 'PUBG Mobile',
        iconColor: const Color(0xFFF5A623),
        iconColorSecondary: const Color(0xFFD4800B),
        icon: Icons.gps_fixed,
        recommendedFps: 90,
        isOptimized: true,
        selectedFps: 90,
        graphicsQuality: 'High',
      ),
      GameModel(
        id: 'freefire',
        name: 'Free Fire',
        iconColor: const Color(0xFFFF4444),
        iconColorSecondary: const Color(0xFFCC0000),
        icon: Icons.local_fire_department,
        recommendedFps: 60,
        isOptimized: false,
        selectedFps: 60,
        graphicsQuality: 'Medium',
      ),
      GameModel(
        id: 'ml',
        name: 'Mobile Legends',
        iconColor: const Color(0xFF00B4FF),
        iconColorSecondary: const Color(0xFF0080CC),
        icon: Icons.shield,
        recommendedFps: 60,
        isOptimized: true,
        selectedFps: 60,
        graphicsQuality: 'High',
      ),
      GameModel(
        id: 'codm',
        name: 'Call of Duty',
        iconColor: const Color(0xFF4CAF50),
        iconColorSecondary: const Color(0xFF2E7D32),
        icon: Icons.military_tech,
        recommendedFps: 120,
        isOptimized: false,
        selectedFps: 60,
        graphicsQuality: 'Medium',
      ),
      GameModel(
        id: 'genshin',
        name: 'Genshin Impact',
        iconColor: const Color(0xFF7B5EA7),
        iconColorSecondary: const Color(0xFF5C4080),
        icon: Icons.auto_awesome,
        recommendedFps: 60,
        isOptimized: true,
        selectedFps: 60,
        graphicsQuality: 'Ultra',
      ),
      GameModel(
        id: 'aov',
        name: 'Arena of Valor',
        iconColor: const Color(0xFFFFD700),
        iconColorSecondary: const Color(0xFFB8860B),
        icon: Icons.emoji_events,
        recommendedFps: 60,
        isOptimized: false,
        selectedFps: 60,
        graphicsQuality: 'High',
      ),
      GameModel(
        id: 'fortnite',
        name: 'Fortnite',
        iconColor: const Color(0xFF00FFB2),
        iconColorSecondary: const Color(0xFF00CC8E),
        icon: Icons.storm,
        recommendedFps: 144,
        isOptimized: false,
        selectedFps: 60,
        graphicsQuality: 'Medium',
      ),
      GameModel(
        id: 'apex',
        name: 'Apex Legends',
        iconColor: const Color(0xFFFF6B35),
        iconColorSecondary: const Color(0xFFCC4400),
        icon: Icons.whatshot,
        recommendedFps: 90,
        isOptimized: false,
        selectedFps: 60,
        graphicsQuality: 'High',
      ),
    ];
  }
}

class PairedApp {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  bool isActive;

  PairedApp({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.isActive = true,
  });

  String get packageName => 'simulation.$id';

  static List<PairedApp> defaultApps() {
    return [
      PairedApp(
        id: 'gfx_tool',
        name: 'Graphics Tuner',
        description: 'Tune frame rendering, texture, and display quality',
        icon: Icons.tune,
        isActive: true,
      ),
      PairedApp(
        id: 'fps_unlocker',
        name: 'FPS Tuner',
        description: 'Adjust target frame rate and pacing',
        icon: Icons.speed,
        isActive: true,
      ),
      PairedApp(
        id: 'ram_manager',
        name: 'Memory Manager',
        description: 'Simulate memory cleanup and performance balance',
        icon: Icons.memory,
        isActive: true,
      ),
      PairedApp(
        id: 'training_drills',
        name: 'Training Drills',
        description: 'Test your selected configuration in short drills',
        icon: Icons.sports_esports,
        isActive: false,
      ),
      PairedApp(
        id: 'color_blendr',
        name: 'ColorBlendr',
        description: 'Pick colors and copy hex codes for your HUD theme',
        icon: Icons.palette_outlined,
        isActive: true,
      ),
      PairedApp(
        id: 'darq',
        name: 'DarQ',
        description: 'Change app appearance and main action button color',
        icon: Icons.dark_mode_outlined,
        isActive: true,
      ),
      PairedApp(
        id: 'network_optimizer',
        name: 'Network Optimizer',
        description: 'Simulate lower latency and steadier online play',
        icon: Icons.network_check,
        isActive: true,
      ),
      PairedApp(
        id: 'ping_tester',
        name: 'Ping Tester',
        description: 'Run quick latency checks for different game regions',
        icon: Icons.speed_outlined,
        isActive: true,
      ),
    ];
  }
}

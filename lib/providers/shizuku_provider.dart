import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';

enum ShizukuStatus { running, stopped, restarting }

class ShizukuProvider extends ChangeNotifier {
  ShizukuStatus _status = ShizukuStatus.running;
  List<PairedApp> _pairedApps = PairedApp.defaultApps();

  // Settings
  bool _autoStart = true;
  bool _autoBoostOnLaunch = false;
  bool _backgroundOptimization = true;
  bool _aggressiveMode = false;
  bool _showFpsOverlay = false;

  // Display
  String _selectedTheme = 'Dark';
  Color _selectedAccent = const Color(0xFF00FFB2);

  // ADB
  String _adbMethod = 'Wireless';
  final String _pairingCode = '847291';

  // GFX Tool Pro settings
  String gfxResolution = '1080p';
  bool gfxShadowQuality = true;
  bool gfxAntiAliasing = true;
  double gfxTextureQuality = 0.7;

  // FPS Unlocker settings
  int fpsUnlockerTarget = 120;
  bool fpsRefreshRateSync = true;
  bool fpsFramePacing = true;

  // Device Spoofer settings
  String spoofDevice = 'Samsung Galaxy S24 Ultra';
  String spoofRam = '12GB';
  String spoofGpu = 'Adreno 750';

  // RAM Manager
  bool ramAutoClean = false;
  int ramCleanInterval = 30;
  double simulatedRamUsage = 0.72;

  // Network Optimizer
  String networkDns = 'Google';
  int networkPing = 68;
  bool networkOptimized = false;

  final Random _random = Random();

  ShizukuStatus get status => _status;
  bool get isRunning => _status == ShizukuStatus.running;
  bool get isRestartingOrTransitioning =>
      _status == ShizukuStatus.restarting;
  List<PairedApp> get pairedApps => _pairedApps;

  bool get autoStart => _autoStart;
  bool get autoBoostOnLaunch => _autoBoostOnLaunch;
  bool get backgroundOptimization => _backgroundOptimization;
  bool get aggressiveMode => _aggressiveMode;
  bool get showFpsOverlay => _showFpsOverlay;

  String get selectedTheme => _selectedTheme;
  Color get selectedAccent => _selectedAccent;

  String get adbMethod => _adbMethod;
  String get pairingCode => _pairingCode;

  ShizukuProvider() {
    _loadPrefs();
    _simulateRamFluctuation();
  }

  void _simulateRamFluctuation() async {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      simulatedRamUsage = (simulatedRamUsage + (_random.nextDouble() * 0.06 - 0.03))
          .clamp(0.4, 0.95);
      notifyListeners();
    }
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _autoStart = prefs.getBool('autoStart') ?? true;
    _autoBoostOnLaunch = prefs.getBool('autoBoostOnLaunch') ?? false;
    _backgroundOptimization = prefs.getBool('backgroundOptimization') ?? true;
    _aggressiveMode = prefs.getBool('aggressiveMode') ?? false;
    _showFpsOverlay = prefs.getBool('showFpsOverlay') ?? false;
    _selectedTheme = prefs.getString('selectedTheme') ?? 'Dark';
    _adbMethod = prefs.getString('adbMethod') ?? 'Wireless';
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoStart', _autoStart);
    await prefs.setBool('autoBoostOnLaunch', _autoBoostOnLaunch);
    await prefs.setBool('backgroundOptimization', _backgroundOptimization);
    await prefs.setBool('aggressiveMode', _aggressiveMode);
    await prefs.setBool('showFpsOverlay', _showFpsOverlay);
    await prefs.setString('selectedTheme', _selectedTheme);
    await prefs.setString('adbMethod', _adbMethod);
  }

  Future<void> restartShizuku() async {
    _status = ShizukuStatus.restarting;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 2500));
    _status = ShizukuStatus.running;
    notifyListeners();
  }

  void stopShizuku() {
    _status = ShizukuStatus.stopped;
    notifyListeners();
  }

  void startShizuku() {
    _status = ShizukuStatus.running;
    notifyListeners();
  }

  void toggleApp(String appId) {
    final index = _pairedApps.indexWhere((app) => app.id == appId);
    if (index != -1) {
      _pairedApps[index].isActive = !_pairedApps[index].isActive;
      notifyListeners();
    }
  }

  void setAutoStart(bool value) {
    _autoStart = value;
    _savePrefs();
    notifyListeners();
  }

  void setAutoBoostOnLaunch(bool value) {
    _autoBoostOnLaunch = value;
    _savePrefs();
    notifyListeners();
  }

  void setBackgroundOptimization(bool value) {
    _backgroundOptimization = value;
    _savePrefs();
    notifyListeners();
  }

  void setAggressiveMode(bool value) {
    _aggressiveMode = value;
    _savePrefs();
    notifyListeners();
  }

  void setShowFpsOverlay(bool value) {
    _showFpsOverlay = value;
    _savePrefs();
    notifyListeners();
  }

  void setSelectedTheme(String theme) {
    _selectedTheme = theme;
    _savePrefs();
    notifyListeners();
  }

  void setSelectedAccent(Color color) {
    _selectedAccent = color;
    notifyListeners();
  }

  void setAdbMethod(String method) {
    _adbMethod = method;
    _savePrefs();
    notifyListeners();
  }

  // GFX Tool
  void setGfxResolution(String resolution) {
    gfxResolution = resolution;
    notifyListeners();
  }

  void setGfxShadowQuality(bool value) {
    gfxShadowQuality = value;
    notifyListeners();
  }

  void setGfxAntiAliasing(bool value) {
    gfxAntiAliasing = value;
    notifyListeners();
  }

  void setGfxTextureQuality(double value) {
    gfxTextureQuality = value;
    notifyListeners();
  }

  void applyGfxSettings() {
    notifyListeners();
  }

  // FPS Unlocker
  void setFpsUnlockerTarget(int value) {
    fpsUnlockerTarget = value;
    notifyListeners();
  }

  void setFpsRefreshRateSync(bool value) {
    fpsRefreshRateSync = value;
    notifyListeners();
  }

  void setFpsFramePacing(bool value) {
    fpsFramePacing = value;
    notifyListeners();
  }

  void applyFpsUnlock() {
    notifyListeners();
  }

  // RAM Manager
  Future<void> cleanRam() async {
    simulatedRamUsage = 0.72;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500));
    simulatedRamUsage = 0.35 + _random.nextDouble() * 0.15;
    notifyListeners();
  }

  void setRamAutoClean(bool value) {
    ramAutoClean = value;
    notifyListeners();
  }

  void setRamCleanInterval(int minutes) {
    ramCleanInterval = minutes;
    notifyListeners();
  }

  // Network Optimizer
  Future<void> optimizeNetwork() async {
    networkOptimized = false;
    networkPing = 68;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 2000));
    networkPing = 8 + _random.nextInt(15);
    networkOptimized = true;
    notifyListeners();
  }

  void setNetworkDns(String dns) {
    networkDns = dns;
    notifyListeners();
  }
}

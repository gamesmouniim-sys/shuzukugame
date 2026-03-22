import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum BoostState { idle, boosting, active }

class BoostProvider extends ChangeNotifier {
  BoostState _boostState = BoostState.idle;
  bool _fpsBooster = false;
  bool _cpuPriority = false;
  bool _ramCleaner = false;
  bool _networkBoost = false;
  bool _batterySaver = false;
  bool _gpuOptimizer = false;

  // Stats
  int _fps = 45;
  int _ramFreed = 0;
  int _ping = 82;
  double _temp = 38.5;

  // Last session
  DateTime? _lastBoostTime;
  int _lastSessionDuration = 0;
  int _lastFpsGain = 0;
  int _lastRamFreed = 0;

  final Random _random = Random();

  BoostState get boostState => _boostState;
  bool get isBoostActive => _boostState == BoostState.active;
  bool get isBoosting => _boostState == BoostState.boosting;

  bool get fpsBooster => _fpsBooster;
  bool get cpuPriority => _cpuPriority;
  bool get ramCleaner => _ramCleaner;
  bool get networkBoost => _networkBoost;
  bool get batterySaver => _batterySaver;
  bool get gpuOptimizer => _gpuOptimizer;

  int get fps => _fps;
  int get ramFreed => _ramFreed;
  int get ping => _ping;
  double get temp => _temp;

  DateTime? get lastBoostTime => _lastBoostTime;
  int get lastSessionDuration => _lastSessionDuration;
  int get lastFpsGain => _lastFpsGain;
  int get lastRamFreed => _lastRamFreed;

  BoostProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _fpsBooster = prefs.getBool('fpsBooster') ?? false;
    _cpuPriority = prefs.getBool('cpuPriority') ?? false;
    _ramCleaner = prefs.getBool('ramCleaner') ?? false;
    _networkBoost = prefs.getBool('networkBoost') ?? false;
    _batterySaver = prefs.getBool('batterySaver') ?? false;
    _gpuOptimizer = prefs.getBool('gpuOptimizer') ?? false;
    notifyListeners();
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('fpsBooster', _fpsBooster);
    await prefs.setBool('cpuPriority', _cpuPriority);
    await prefs.setBool('ramCleaner', _ramCleaner);
    await prefs.setBool('networkBoost', _networkBoost);
    await prefs.setBool('batterySaver', _batterySaver);
    await prefs.setBool('gpuOptimizer', _gpuOptimizer);
  }

  Future<void> activateBoost() async {
    if (_boostState == BoostState.boosting) return;
    _boostState = BoostState.boosting;
    notifyListeners();

    // Simulate boosting delay
    await Future.delayed(const Duration(milliseconds: 2200));

    // Calculate simulated gains
    final baseFps = 45 + _random.nextInt(15);
    final fpsGain = (_fpsBooster ? 20 : 0) +
        (_gpuOptimizer ? 15 : 0) +
        (_cpuPriority ? 10 : 0) +
        _random.nextInt(10);
    _fps = baseFps + fpsGain;
    _ramFreed = (_ramCleaner ? 800 : 200) + _random.nextInt(400);
    _ping = (_networkBoost ? 18 : 45) + _random.nextInt(20);
    _temp = _batterySaver
        ? 34.0 + _random.nextDouble() * 2
        : 39.0 + _random.nextDouble() * 4;

    _lastFpsGain = fpsGain;
    _lastRamFreed = _ramFreed;
    _lastBoostTime = DateTime.now();
    _lastSessionDuration = 0;

    _boostState = BoostState.active;
    notifyListeners();

    // Simulate session tracking
    _startSessionTimer();
  }

  void _startSessionTimer() async {
    while (_boostState == BoostState.active) {
      await Future.delayed(const Duration(seconds: 1));
      if (_boostState == BoostState.active) {
        _lastSessionDuration++;
        // Slight value fluctuation
        _fps = (_fps + _random.nextInt(5) - 2).clamp(30, 165);
        _ping = (_ping + _random.nextInt(6) - 3).clamp(5, 200);
        _temp = (_temp + (_random.nextDouble() * 0.4 - 0.2)).clamp(30.0, 55.0);
        notifyListeners();
      }
    }
  }

  void deactivateBoost() {
    _boostState = BoostState.idle;
    _fps = 45 + _random.nextInt(10);
    _ramFreed = 0;
    _ping = 70 + _random.nextInt(30);
    _temp = 38.0 + _random.nextDouble() * 3;
    notifyListeners();
  }

  void setFpsBooster(bool value) {
    _fpsBooster = value;
    _savePrefs();
    notifyListeners();
  }

  void setCpuPriority(bool value) {
    _cpuPriority = value;
    _savePrefs();
    notifyListeners();
  }

  void setRamCleaner(bool value) {
    _ramCleaner = value;
    _savePrefs();
    notifyListeners();
  }

  void setNetworkBoost(bool value) {
    _networkBoost = value;
    _savePrefs();
    notifyListeners();
  }

  void setBatterySaver(bool value) {
    _batterySaver = value;
    _savePrefs();
    notifyListeners();
  }

  void setGpuOptimizer(bool value) {
    _gpuOptimizer = value;
    _savePrefs();
    notifyListeners();
  }

  // Refresh stats with random fluctuation
  void refreshStats() {
    if (_boostState == BoostState.active) {
      _fps = (_fps + _random.nextInt(7) - 3).clamp(30, 165);
      _ping = (_ping + _random.nextInt(8) - 4).clamp(5, 200);
      _temp = (_temp + (_random.nextDouble() * 0.6 - 0.3)).clamp(30.0, 55.0);
    } else {
      _fps = (45 + _random.nextInt(15)).clamp(20, 80);
      _ping = (65 + _random.nextInt(40)).clamp(20, 200);
      _temp = (37.0 + _random.nextDouble() * 5).clamp(30.0, 55.0);
    }
    notifyListeners();
  }
}

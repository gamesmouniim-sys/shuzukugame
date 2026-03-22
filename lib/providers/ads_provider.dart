import 'dart:async';
import 'dart:convert';

import 'package:applovin_max/applovin_max.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../models/ads_config.dart';

class AdsProvider extends ChangeNotifier {
  static const _configUrl =
      'https://drive.google.com/uc?export=download&id=1iBovdfwOh80mzYYlnFxaOVBl1tpYa86W';
  static const _fallbackAssetPath = 'assets/config/shizuku.json';
  static const _privacyUrl =
      'https://games-apps-store.blogspot.com/p/privacy-policy.html';
  static const _termsUrl =
      'https://games-apps-store.blogspot.com/p/terms-of-use.html';

  AdsConfigRoot _configRoot = AdsConfigRoot.empty;
  bool _isInitializing = false;
  bool _isReady = false;
  bool _appLovinInitialized = false;
  bool _interstitialReady = false;
  bool _rewardedReady = false;
  bool _appOpenReady = false;
  bool _isShowingInterstitial = false;
  bool _isShowingRewarded = false;
  bool _isShowingAppOpen = false;
  bool _hasShownColdStartAppOpen = false;
  int _interactionCount = 0;
  Completer<bool>? _rewardCompleter;
  bool _pendingRewardGrant = false;
  String _configSource = 'asset';

  AdsConfig get ads => _configRoot.ads;
  bool get isReady => _isReady;
  bool get isInitializing => _isInitializing;
  bool get shouldShowPromotion => ads.shouldShowPromotion;
  String get configSource => _configSource;

  Future<void> initialize() async {
    if (_isInitializing || _isReady) {
      return;
    }

    _isInitializing = true;
    notifyListeners();

    try {
      _configRoot = await _loadConfig();
      await _initializeAppLovinIfNeeded();
    } finally {
      _isInitializing = false;
      _isReady = true;
      notifyListeners();
    }
  }

  Future<AdsConfigRoot> _loadConfig() async {
    try {
      final response = await http.get(Uri.parse(_configUrl)).timeout(
            const Duration(seconds: 6),
          );
      if (response.statusCode == 200 && response.body.trim().isNotEmpty) {
        _configSource = 'remote';
        return AdsConfigRoot.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
        );
      }
    } catch (_) {
      // Fall back to the bundled config when the remote file is unavailable.
    }

    final fallbackJson = await rootBundle.loadString(_fallbackAssetPath);
    _configSource = 'asset';
    return AdsConfigRoot.fromJson(
      jsonDecode(fallbackJson) as Map<String, dynamic>,
    );
  }

  Future<void> _initializeAppLovinIfNeeded() async {
    if (!ads.canInitializeAppLovin || _appLovinInitialized) {
      return;
    }

    final adUnitIds = <String>{
      if (ads.usesAppLovinInterstitial) ads.applovin.interId,
      if (ads.usesAppLovinRewarded) ads.applovin.rewardId,
      if (ads.usesAppLovinAppOpen) ads.applovin.openAdsId,
    }.toList();

    if (adUnitIds.isNotEmpty) {
      AppLovinMAX.setInitializationAdUnitIds(adUnitIds);
    }
    AppLovinMAX.setTermsAndPrivacyPolicyFlowEnabled(true);
    AppLovinMAX.setPrivacyPolicyUrl(_privacyUrl);
    AppLovinMAX.setTermsOfServiceUrl(_termsUrl);
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (_) {
          _interstitialReady = true;
          notifyListeners();
        },
        onAdLoadFailedCallback: (_, __) {
          _interstitialReady = false;
        },
        onAdDisplayedCallback: (_) {
          _isShowingInterstitial = true;
        },
        onAdDisplayFailedCallback: (_, __) {
          _isShowingInterstitial = false;
          _interstitialReady = false;
          _preloadInterstitial();
        },
        onAdClickedCallback: (_) {},
        onAdHiddenCallback: (_) {
          _isShowingInterstitial = false;
          _interstitialReady = false;
          _preloadInterstitial();
        },
      ),
    );
    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (_) {
          _rewardedReady = true;
          notifyListeners();
        },
        onAdLoadFailedCallback: (_, __) {
          _rewardedReady = false;
        },
        onAdDisplayedCallback: (_) {
          _isShowingRewarded = true;
        },
        onAdDisplayFailedCallback: (_, __) {
          _completeReward(false);
          _isShowingRewarded = false;
          _rewardedReady = false;
          _preloadRewarded();
        },
        onAdClickedCallback: (_) {},
        onAdHiddenCallback: (_) {
          _completeReward(_pendingRewardGrant);
          _pendingRewardGrant = false;
          _isShowingRewarded = false;
          _rewardedReady = false;
          _preloadRewarded();
        },
        onAdReceivedRewardCallback: (_, __) {
          _pendingRewardGrant = true;
        },
      ),
    );
    AppLovinMAX.setAppOpenAdListener(
      AppOpenAdListener(
        onAdLoadedCallback: (_) {
          _appOpenReady = true;
          notifyListeners();
        },
        onAdLoadFailedCallback: (_, __) {
          _appOpenReady = false;
        },
        onAdDisplayedCallback: (_) {
          _isShowingAppOpen = true;
        },
        onAdDisplayFailedCallback: (_, __) {
          _isShowingAppOpen = false;
          _appOpenReady = false;
          _preloadAppOpen();
        },
        onAdClickedCallback: (_) {},
        onAdHiddenCallback: (_) {
          _isShowingAppOpen = false;
          _appOpenReady = false;
          _preloadAppOpen();
        },
      ),
    );

    await AppLovinMAX.initialize(ads.applovin.sdkKey);
    _appLovinInitialized = true;
    _preloadAppOpen();
    _preloadInterstitial();
    _preloadRewarded();
  }

  void _preloadAppOpen() {
    if (ads.usesAppLovinAppOpen) {
      AppLovinMAX.loadAppOpenAd(ads.applovin.openAdsId);
    }
  }

  void _preloadInterstitial() {
    if (ads.usesAppLovinInterstitial) {
      AppLovinMAX.loadInterstitial(ads.applovin.interId);
    }
  }

  void _preloadRewarded() {
    if (ads.usesAppLovinRewarded) {
      AppLovinMAX.loadRewardedAd(ads.applovin.rewardId);
    }
  }

  Future<void> registerInteraction({
    bool eligibleForInterstitial = true,
  }) async {
    if (!eligibleForInterstitial || !ads.adsOk || ads.clickNumber <= 0) {
      return;
    }

    _interactionCount += 1;

    if (_interactionCount < ads.clickNumber ||
        !ads.usesAppLovinInterstitial ||
        _isShowingInterstitial) {
      return;
    }

    final isReady = _interstitialReady ||
        (await AppLovinMAX.isInterstitialReady(ads.applovin.interId) ?? false);
    if (!isReady) {
      _preloadInterstitial();
      return;
    }

    _interactionCount = 0;
    _isShowingInterstitial = true;
    AppLovinMAX.showInterstitial(
      ads.applovin.interId,
      placement: 'tap_interaction',
    );
  }

  Future<bool> showRewardedForShizukuAction() async {
    if (!ads.adsOk || !ads.usesAppLovinRewarded || _isShowingRewarded) {
      return false;
    }

    final isReady = _rewardedReady ||
        (await AppLovinMAX.isRewardedAdReady(ads.applovin.rewardId) ?? false);
    if (!isReady) {
      _preloadRewarded();
      return false;
    }

    _pendingRewardGrant = false;
    _isShowingRewarded = true;
    _rewardCompleter = Completer<bool>();

    AppLovinMAX.showRewardedAd(
      ads.applovin.rewardId,
      placement: 'shizuku_action',
    );

    return _rewardCompleter!.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        _completeReward(false);
        return false;
      },
    );
  }

  Future<void> showAppOpenIfReady({
    bool markColdStartShown = false,
  }) async {
    if (!ads.adsOk ||
        !ads.usesAppLovinAppOpen ||
        _isShowingAppOpen ||
        _isShowingInterstitial ||
        _isShowingRewarded) {
      return;
    }

    final isReady = _appOpenReady ||
        (await AppLovinMAX.isAppOpenAdReady(ads.applovin.openAdsId) ?? false);
    if (!isReady) {
      _preloadAppOpen();
      return;
    }

    _isShowingAppOpen = true;
    if (markColdStartShown) {
      _hasShownColdStartAppOpen = true;
    }
    AppLovinMAX.showAppOpenAd(
      ads.applovin.openAdsId,
      placement: markColdStartShown ? 'cold_start' : 'app_resume',
    );
  }

  Future<void> showColdStartAppOpenIfReady() async {
    if (_hasShownColdStartAppOpen) {
      return;
    }
    await showAppOpenIfReady(markColdStartShown: true);
  }

  void _completeReward(bool rewarded) {
    if (_rewardCompleter != null && !_rewardCompleter!.isCompleted) {
      _rewardCompleter!.complete(rewarded);
    }
    _rewardCompleter = null;
  }

  Future<void> openPromotionLink() async {
    final link = ads.appLink;
    if (link.isEmpty) {
      return;
    }

    await launchUrl(
      Uri.parse(link),
      mode: LaunchMode.externalApplication,
    );
  }
}

class AdsConfigRoot {
  const AdsConfigRoot({
    required this.ads,
  });

  final AdsConfig ads;

  factory AdsConfigRoot.fromJson(Map<String, dynamic> json) {
    return AdsConfigRoot(
      ads: AdsConfig.fromJson(
        Map<String, dynamic>.from(json['ads'] as Map? ?? const {}),
      ),
    );
  }

  static const empty = AdsConfigRoot(ads: AdsConfig.empty);
}

class AdsConfig {
  const AdsConfig({
    required this.adsOk,
    required this.clickNumber,
    required this.promotion,
    required this.appImageLink,
    required this.appLink,
    required this.applovin,
    required this.settings,
  });

  final bool adsOk;
  final int clickNumber;
  final bool promotion;
  final String appImageLink;
  final String appLink;
  final AppLovinConfig applovin;
  final AdsSettings settings;

  static const empty = AdsConfig(
    adsOk: false,
    clickNumber: 0,
    promotion: false,
    appImageLink: '',
    appLink: '',
    applovin: AppLovinConfig.empty,
    settings: AdsSettings.empty,
  );

  factory AdsConfig.fromJson(Map<String, dynamic> json) {
    return AdsConfig(
      adsOk: json['AdsOk'] == true,
      clickNumber: (json['ClickNumber'] as num?)?.toInt() ?? 0,
      promotion: json['Promotion'] == true,
      appImageLink: (json['appImageLink'] as String? ?? '').trim(),
      appLink: (json['appLink'] as String? ?? '').trim(),
      applovin: AppLovinConfig.fromJson(
        Map<String, dynamic>.from(json['applovin'] as Map? ?? const {}),
      ),
      settings: AdsSettings.fromJson(
        Map<String, dynamic>.from(json['settings'] as Map? ?? const {}),
      ),
    );
  }

  bool get usesAppLovinInterstitial => applovin.interId.isNotEmpty;

  bool get usesAppLovinRewarded => applovin.rewardId.isNotEmpty;

  bool get usesAppLovinAppOpen => applovin.openAdsId.isNotEmpty;

  bool get shouldShowPromotion =>
      promotion && appImageLink.isNotEmpty && appLink.isNotEmpty;

  bool get canInitializeAppLovin =>
      adsOk &&
      applovin.sdkKey.isNotEmpty &&
      (usesAppLovinInterstitial || usesAppLovinRewarded || usesAppLovinAppOpen);
}

class AppLovinConfig {
  const AppLovinConfig({
    required this.sdkKey,
    required this.bannerId,
    required this.openAdsId,
    required this.interId,
    required this.nativeId,
    required this.rewardId,
  });

  final String sdkKey;
  final String bannerId;
  final String openAdsId;
  final String interId;
  final String nativeId;
  final String rewardId;

  static const empty = AppLovinConfig(
    sdkKey: '',
    bannerId: '',
    openAdsId: '',
    interId: '',
    nativeId: '',
    rewardId: '',
  );

  factory AppLovinConfig.fromJson(Map<String, dynamic> json) {
    return AppLovinConfig(
      sdkKey: (json['sdk_key'] as String? ?? '').trim(),
      bannerId: (json['bannerId'] as String? ?? '').trim(),
      openAdsId: (json['openAdsIds'] as String? ?? '').trim(),
      interId: (json['interId'] as String? ?? '').trim(),
      nativeId: (json['nativeId'] as String? ?? '').trim(),
      rewardId: (json['rewardId'] as String? ?? '').trim(),
    );
  }
}

class AdsSettings {
  const AdsSettings({
    required this.openAds,
    required this.banners,
    required this.inters,
    required this.natives,
    required this.rewards,
  });

  final String openAds;
  final String banners;
  final String inters;
  final String natives;
  final String rewards;

  static const empty = AdsSettings(
    openAds: '',
    banners: '',
    inters: '',
    natives: '',
    rewards: '',
  );

  factory AdsSettings.fromJson(Map<String, dynamic> json) {
    return AdsSettings(
      openAds: (json['openads'] as String? ?? '').toLowerCase(),
      banners: (json['banners'] as String? ?? '').toLowerCase(),
      inters: (json['inters'] as String? ?? '').toLowerCase(),
      natives: (json['natives'] as String? ?? '').toLowerCase(),
      rewards: (json['rewards'] as String? ?? '').toLowerCase(),
    );
  }
}

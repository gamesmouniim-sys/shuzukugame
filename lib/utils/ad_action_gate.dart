import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/ads_provider.dart';

class AdActionGate {
  static Future<void> run(
    BuildContext context, {
    required FutureOr<void> Function() action,
    bool eligibleForInterstitial = true,
  }) async {
    await action();
    if (!context.mounted) {
      return;
    }
    await context.read<AdsProvider>().registerInteraction(
          eligibleForInterstitial: eligibleForInterstitial,
        );
  }

  static Future<void> runRewardedShizukuAction(
    BuildContext context, {
    required FutureOr<void> Function() action,
  }) async {
    final adsProvider = context.read<AdsProvider>();
    await adsProvider.showRewardedForShizukuAction();
    await action();
    if (!context.mounted) {
      return;
    }
    await adsProvider.registerInteraction();
  }
}

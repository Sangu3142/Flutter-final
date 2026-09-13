library;

import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';

const String kTutorialCompletedKey = 'tutorial_completed';

Future<void> markTutorialComplete() async {
  await Hive.box(kSettingsBox).put(kTutorialCompletedKey, true);
}

bool isTutorialDone() {
  return Hive.box(kSettingsBox)
      .get(kTutorialCompletedKey, defaultValue: false) as bool;
}

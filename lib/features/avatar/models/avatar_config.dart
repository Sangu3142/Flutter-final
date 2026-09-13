import 'package:flutter/material.dart';

enum HairStyle {
  shortNeat,    // clean short male cut
  afro,         // large voluminous afro
  longWavy,     // long wavy/flowing female
  longStraight, // straight long female
  curlyMed,     // medium curly
  faded,        // tapered fade male
  hijab,        // hijab head covering
  keffiyeh,     // Arab keffiyeh
  bun,          // topknot/bun
  pixie,        // short female cut
}

class AvatarConfig {
  final String id;
  final String label;
  final Color skinTone;
  final Color bodyColor;
  final Color hairColor;
  final Color eyeColor;
  final HairStyle hairStyle;
  final bool hasGlasses;
  final bool hasBeard;
  final String accessoryEmoji;

  const AvatarConfig({
    required this.id,
    required this.label,
    required this.skinTone,
    required this.bodyColor,
    required this.hairColor,
    required this.eyeColor,
    required this.hairStyle,
    this.hasGlasses = false,
    this.hasBeard = false,
    required this.accessoryEmoji,
  });
}

const List<AvatarConfig> kAvatarConfigs = [
  // av_01 — F, medium-dark skin, curly black hair, orange shirt
  AvatarConfig(
    id: 'av_01', label: 'Chanda',
    skinTone: Color(0xFFB5743A), bodyColor: Color(0xFFFF8C42),
    hairColor: Color(0xFF0D0A06), eyeColor: Color(0xFF3E2000),
    hairStyle: HairStyle.curlyMed, accessoryEmoji: '🌿',
  ),
  // av_02 — M, light skin, short neat dark, beard, teal shirt
  AvatarConfig(
    id: 'av_02', label: 'Bwalya',
    skinTone: Color(0xFFE8C49A), bodyColor: Color(0xFF00B4D8),
    hairColor: Color(0xFF1A0A00), eyeColor: Color(0xFF2C1A0E),
    hairStyle: HairStyle.shortNeat, hasBeard: true, accessoryEmoji: '👔',
  ),
  // av_03 — F, light skin, bun dark hair, glasses, blue shirt
  AvatarConfig(
    id: 'av_03', label: 'Thandiwe',
    skinTone: Color(0xFFF2C9A0), bodyColor: Color(0xFF0077B6),
    hairColor: Color(0xFF0D0A06), eyeColor: Color(0xFF2C1A0E),
    hairStyle: HairStyle.bun, hasGlasses: true, accessoryEmoji: '📚',
  ),
  // av_04 — M, light skin, short neat dark, glasses, navy suit
  AvatarConfig(
    id: 'av_04', label: 'Mwape',
    skinTone: Color(0xFFE8C49A), bodyColor: Color(0xFF00203F),
    hairColor: Color(0xFF1A0A00), eyeColor: Color(0xFF2C1A0E),
    hairStyle: HairStyle.shortNeat, hasGlasses: true, accessoryEmoji: '💼',
  ),
  // av_05 — F, very light skin, afro dark, cream shirt
  AvatarConfig(
    id: 'av_05', label: 'Chileshe',
    skinTone: Color(0xFFF5DEB3), bodyColor: Color(0xFFF8EDE3),
    hairColor: Color(0xFF0D0500), eyeColor: Color(0xFF3E2000),
    hairStyle: HairStyle.afro, accessoryEmoji: '🎓',
  ),
  // av_06 — M, very dark skin, afro, glasses, dark suit
  AvatarConfig(
    id: 'av_06', label: 'Kampamba',
    skinTone: Color(0xFF1A0E06), bodyColor: Color(0xFF1A1A2E),
    hairColor: Color(0xFF050302), eyeColor: Color(0xFF5C2E0A),
    hairStyle: HairStyle.afro, hasGlasses: true, accessoryEmoji: '🎸',
  ),
  // av_07 — F, medium skin, curly auburn, blue shirt
  AvatarConfig(
    id: 'av_07', label: 'Musonda',
    skinTone: Color(0xFFC8864A), bodyColor: Color(0xFF4A90E2),
    hairColor: Color(0xFF8B2500), eyeColor: Color(0xFF795548),
    hairStyle: HairStyle.curlyMed, accessoryEmoji: '🌾',
  ),
  // av_08 — M, medium-light skin, short neat brown, gray shirt
  AvatarConfig(
    id: 'av_08', label: 'Lombe',
    skinTone: Color(0xFFD4956A), bodyColor: Color(0xFF9E9E9E),
    hairColor: Color(0xFF3D2005), eyeColor: Color(0xFF795548),
    hairStyle: HairStyle.shortNeat, accessoryEmoji: '📱',
  ),
  // av_09 — F, very light skin, long straight blonde, glasses, black shirt
  AvatarConfig(
    id: 'av_09', label: 'Nachilala',
    skinTone: Color(0xFFF5E0C8), bodyColor: Color(0xFF212121),
    hairColor: Color(0xFFE8C040), eyeColor: Color(0xFF1565C0),
    hairStyle: HairStyle.longStraight, hasGlasses: true, accessoryEmoji: '📊',
  ),
  // av_10 — M, medium-dark skin, short neat, beard, yellow shirt
  AvatarConfig(
    id: 'av_10', label: 'Mumba',
    skinTone: Color(0xFFB5743A), bodyColor: Color(0xFFFFB300),
    hairColor: Color(0xFF0D0A06), eyeColor: Color(0xFF3E2000),
    hairStyle: HairStyle.shortNeat, hasBeard: true, accessoryEmoji: '🔧',
  ),
  // av_13 — F, dark skin, pixie dark, green shirt
  AvatarConfig(
    id: 'av_13', label: 'Mutale',
    skinTone: Color(0xFF4A2512), bodyColor: Color(0xFF2BC48A),
    hairColor: Color(0xFF050302), eyeColor: Color(0xFF5C2E0A),
    hairStyle: HairStyle.pixie, accessoryEmoji: '🌍',
  ),
  // av_14 — M, light skin, short neat brown, glasses, blue hoodie
  AvatarConfig(
    id: 'av_14', label: 'Mulenga',
    skinTone: Color(0xFFE8C49A), bodyColor: Color(0xFF1A73E8),
    hairColor: Color(0xFF3D2005), eyeColor: Color(0xFF795548),
    hairStyle: HairStyle.shortNeat, hasGlasses: true, accessoryEmoji: '💻',
  ),
];

AvatarConfig avatarConfigById(String id) {
  try {
    return kAvatarConfigs.firstWhere((c) => c.id == id);
  } catch (_) {
    // Backwards compat: old IDs (student, trader, etc.) fall back to av_01
    return kAvatarConfigs.first;
  }
}

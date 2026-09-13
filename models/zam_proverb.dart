import 'package:flutter/material.dart';

enum ProverbTheme {
  savings,
  investment,
  budgeting,
  debt,
  emergency,
  community,
  property,
  education,
}

class ZamProverb {
  final String id;
  final String? bemba;
  final String? nyanja;
  final String? tonga;
  final String? lozi;
  final String english;
  final String lesson;
  final ProverbTheme theme;
  final String emoji;

  const ZamProverb({
    required this.id,
    this.bemba,
    this.nyanja,
    this.tonga,
    this.lozi,
    required this.english,
    required this.lesson,
    required this.theme,
    required this.emoji,
  });

  String get localText => bemba ?? nyanja ?? tonga ?? lozi ?? english;

  String get languageLabel {
    if (bemba != null) return 'Bemba';
    if (nyanja != null) return 'Nyanja';
    if (tonga != null) return 'Tonga';
    if (lozi != null) return 'Lozi';
    return 'English';
  }

  String get themeLabel => switch (theme) {
    ProverbTheme.savings    => 'Savings',
    ProverbTheme.investment => 'Investment',
    ProverbTheme.budgeting  => 'Budgeting',
    ProverbTheme.debt       => 'Debt',
    ProverbTheme.emergency  => 'Emergency Fund',
    ProverbTheme.community  => 'Community',
    ProverbTheme.property   => 'Property',
    ProverbTheme.education  => 'Education',
  };

  Color get themeColor => switch (theme) {
    ProverbTheme.savings    => const Color(0xFF00BCD4),
    ProverbTheme.investment => const Color(0xFFFFB300),
    ProverbTheme.budgeting  => const Color(0xFF7C4DFF),
    ProverbTheme.debt       => const Color(0xFFE53935),
    ProverbTheme.emergency  => const Color(0xFFFF7043),
    ProverbTheme.community  => const Color(0xFF43A047),
    ProverbTheme.property   => const Color(0xFF8D6E63),
    ProverbTheme.education  => const Color(0xFF1E88E5),
  };
}

const List<ZamProverb> zamProverbs = [
  ZamProverb(
    id: 'p01',
    bemba: 'Akalulu ka mfumu takasekwa',
    english: "A chief's rabbit is not laughed at",
    lesson: 'Respect earned wealth. Never mock someone\'s '
        'small savings — they may grow into great riches.',
    theme: ProverbTheme.savings,
    emoji: '🐇',
  ),
  ZamProverb(
    id: 'p02',
    bemba: "Umwana wa ng'ombe ni ng'ombe",
    english: 'The child of a cow is a cow',
    lesson: 'Money grows from money. Invest your earnings '
        'and watch them multiply — this is compound interest.',
    theme: ProverbTheme.investment,
    emoji: '🐄',
  ),
  ZamProverb(
    id: 'p03',
    bemba: 'Twalumba umulandu — tamwipelwa',
    english: 'We thanked trouble — it was not given to us',
    lesson: 'Build an emergency fund before disaster strikes. '
        'Preparation prevents financial ruin.',
    theme: ProverbTheme.emergency,
    emoji: '⛈️',
  ),
  ZamProverb(
    id: 'p04',
    bemba: 'Ulya nabangi talya yeka',
    english: 'He who eats with many does not eat alone',
    lesson: 'Group savings (chamas) and cooperatives '
        'help communities build wealth together.',
    theme: ProverbTheme.community,
    emoji: '🤝',
  ),
  ZamProverb(
    id: 'p05',
    bemba: 'Insoka yafwa na bulwi bwayo',
    english: 'A snake dies with its venom',
    lesson: 'Bad debt follows you. Pay off loans on time '
        'or interest will drain your finances for years.',
    theme: ProverbTheme.debt,
    emoji: '🐍',
  ),
  ZamProverb(
    id: 'p06',
    nyanja: 'Msanga upite — usadzudzumike',
    english: 'Cross quickly — do not hesitate',
    lesson: 'Delayed financial decisions cost money. '
        'Act on good investment opportunities promptly.',
    theme: ProverbTheme.investment,
    emoji: '⚡',
  ),
  ZamProverb(
    id: 'p07',
    bemba: 'Ifyo ukula, naifyo upwisha',
    english: 'How you grow is how you finish',
    lesson: 'Financial habits formed young determine '
        'your wealth at retirement. Start saving early.',
    theme: ProverbTheme.savings,
    emoji: '🌱',
  ),
  ZamProverb(
    id: 'p08',
    tonga: 'Mulimo wa mano — taupi',
    english: 'Work of the mind never tires',
    lesson: 'Financial literacy is the skill that keeps '
        'paying you. Invest in your knowledge first.',
    theme: ProverbTheme.education,
    emoji: '🧠',
  ),
  ZamProverb(
    id: 'p09',
    bemba: 'Umuntu alanda nefyo akwata',
    english: 'A person speaks according to what they have',
    lesson: 'Live within your means. Spending beyond '
        'your income leads to debt and lost respect.',
    theme: ProverbTheme.budgeting,
    emoji: '👛',
  ),
  ZamProverb(
    id: 'p10',
    nyanja: 'Chuma n\'chuma — chimodzi sichikwana',
    english: 'Wealth is wealth — one coin is not enough',
    lesson: 'Diversify your income streams. '
        'One source of money is never truly secure.',
    theme: ProverbTheme.investment,
    emoji: '💎',
  ),
  ZamProverb(
    id: 'p11',
    bemba: 'Akafweni — kamo kabili kambi',
    english: 'A little and a little makes more',
    lesson: 'Small consistent savings add up to great wealth. '
        'Save even ZMW 10 a day.',
    theme: ProverbTheme.savings,
    emoji: '🪙',
  ),
  ZamProverb(
    id: 'p12',
    lozi: 'Simu ya luna — yafumana',
    english: 'The farm of unity — it was harvested',
    lesson: 'Cooperative farming and group business ventures '
        'succeed where individuals fail alone.',
    theme: ProverbTheme.community,
    emoji: '🌾',
  ),
  ZamProverb(
    id: 'p13',
    bemba: 'Ukupanga kulingana na ufumo',
    english: 'Planning matches the purse',
    lesson: 'Budget before you spend. A plan without '
        'finances is just a dream.',
    theme: ProverbTheme.budgeting,
    emoji: '📋',
  ),
  ZamProverb(
    id: 'p14',
    nyanja: 'Njala yaphunzitsa mantha',
    english: 'Hunger has taught fear',
    lesson: 'Financial hardship teaches powerful lessons. '
        'Use hard times to build better money habits.',
    theme: ProverbTheme.emergency,
    emoji: '🍽️',
  ),
  ZamProverb(
    id: 'p15',
    bemba: 'Umwine ng\'anda — ni we mulelela',
    english: 'The owner of the house — is the one who builds it',
    lesson: 'Owning property builds lasting generational wealth. '
        'Rent pays others — a mortgage builds your future.',
    theme: ProverbTheme.property,
    emoji: '🏠',
  ),
  ZamProverb(
    id: 'p16',
    tonga: 'Nyika ya Leza — taili yako',
    english: "God's land — is not yours alone",
    lesson: 'Shared resources and community support systems '
        'reduce individual financial risk.',
    theme: ProverbTheme.community,
    emoji: '🌍',
  ),
  ZamProverb(
    id: 'p17',
    bemba: 'Amabunga yafuma — tasendwa',
    english: 'Spilled flour — cannot be gathered',
    lesson: 'Wasted money cannot be recovered. '
        'Track every Kwacha before it\'s gone.',
    theme: ProverbTheme.budgeting,
    emoji: '🌪️',
  ),
  ZamProverb(
    id: 'p18',
    nyanja: 'Mtengo waukulu — sukulira',
    english: 'A big tree — provides shade',
    lesson: 'Build wealth large enough to protect '
        'and support your family and community.',
    theme: ProverbTheme.investment,
    emoji: '🌳',
  ),
  ZamProverb(
    id: 'p19',
    bemba: 'Umulilo — utatumpa',
    english: 'Fire — does not jump',
    lesson: 'Financial problems spread slowly at first. '
        'Address debt and overspending before it becomes a crisis.',
    theme: ProverbTheme.debt,
    emoji: '🔥',
  ),
  ZamProverb(
    id: 'p20',
    lozi: 'Lifasi la swanela kaufela',
    english: 'The earth belongs to everyone',
    lesson: 'Land and property ownership is a right for all Zambians. '
        'Start your property ladder as early as possible.',
    theme: ProverbTheme.property,
    emoji: '🗺️',
  ),
  ZamProverb(
    id: 'p21',
    bemba: 'Ubushiku — tabusanga umuntu',
    english: 'The night — does not find a person unprepared',
    lesson: 'Retirement planning starts now. '
        'Night (old age) comes for everyone — be ready.',
    theme: ProverbTheme.savings,
    emoji: '🌙',
  ),
  ZamProverb(
    id: 'p22',
    nyanja: 'Munthu wina — ali nawo mphamvu',
    english: 'Another person — also has strength',
    lesson: 'Never underestimate competition in business. '
        'Study your market and stay innovative.',
    theme: ProverbTheme.education,
    emoji: '💪',
  ),
  ZamProverb(
    id: 'p23',
    bemba: 'Impiya — zileta lusansa',
    english: 'Money — brings noise',
    lesson: 'Wealth attracts attention. Be discreet about '
        'your financial goals to avoid exploitation.',
    theme: ProverbTheme.budgeting,
    emoji: '🤫',
  ),
  ZamProverb(
    id: 'p24',
    tonga: 'Mulimo — nguwe mwami',
    english: 'Work — is the chief',
    lesson: 'Consistent effort is the foundation of all wealth. '
        'There are no shortcuts to financial freedom.',
    theme: ProverbTheme.education,
    emoji: '⚒️',
  ),
  ZamProverb(
    id: 'p25',
    bemba: 'Ukulya kwabupe — kushota',
    english: 'Eating for free — is borrowing',
    lesson: 'Nothing is truly free. Understand the true cost '
        'of loans, favours and "free" financial products.',
    theme: ProverbTheme.debt,
    emoji: '🎁',
  ),
];

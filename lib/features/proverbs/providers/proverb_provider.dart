/// proverb_provider.dart
/// Purpose: Manages the Zambian proverbs collection — pool data, collection
///          tracking, and Hive persistence.
library;

import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/proverbs/models/proverb_record.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data
// ─────────────────────────────────────────────────────────────────────────────

class ProverbData {
  const ProverbData({
    required this.id,
    required this.original,
    required this.language,
    required this.translation,
    required this.lesson,
    required this.category,
  });
  final int    id;
  final String original;
  final String language;
  final String translation;
  final String lesson;
  final String category;
}

const List<ProverbData> kAllProverbs = [
  ProverbData(id: 1, language: 'Bemba', original: 'Uupanga mfumu, takonka.', translation: 'He who makes a chief does not follow.', lesson: 'Take charge of your financial decisions — don\'t just follow the crowd into debt or bad investments.', category: 'Leadership'),
  ProverbData(id: 2, language: 'Nyanja', original: 'Pali zinthu ziwiri zimene sizingagawidwe — imfa ndi umphawi.', translation: 'There are two things that cannot be shared — death and poverty.', lesson: 'Only you can fix your financial situation. Take full ownership of your money.', category: 'Responsibility'),
  ProverbData(id: 3, language: 'Tonga', original: 'Ukamanya kufumba, ukamanya kulya.', translation: 'If you know how to ask, you know how to eat.', lesson: 'Ask for financial advice, ask about loan options, ask for better terms. Asking is the beginning of getting.', category: 'Communication'),
  ProverbData(id: 4, language: 'Lozi', original: 'Siyo muzeezo wa pilu, ki muzeezo wa musebezi.', translation: 'It is not the thought of the heart, but the work of the hands.', lesson: 'Financial plans mean nothing without action. Open the savings account. Make the deposit. Start today.', category: 'Action'),
  ProverbData(id: 5, language: 'Bemba', original: 'Umwine ng\'anda aipaya.', translation: 'The owner of a house overworks himself for it.', lesson: 'Owning property requires sacrifice and long-term discipline. The struggle is part of the plan.', category: 'Property'),
  ProverbData(id: 6, language: 'Nyanja', original: 'Mwana wa nkuku akaona mame, amayamba kuyimba.', translation: 'The chick that sees dew begins to sing.', lesson: 'Small financial wins — a first ZMW 500 saved — deserve recognition. They signal that bigger wins are coming.', category: 'Savings'),
  ProverbData(id: 7, language: 'Bemba', original: 'Icisungu tacipolowe amafi ya ng\'ombe.', translation: 'A clever girl does not step in cattle dung.', lesson: 'Financial wisdom means spotting traps before you fall into them — high-interest loans, pyramid schemes, lifestyle debt.', category: 'Wisdom'),
  ProverbData(id: 8, language: 'Tonga', original: 'Ataamba mazuba, akaamba mpya.', translation: 'He who wastes days will also waste years.', lesson: 'Every day without a savings habit is a compounding loss. Start the habit now, not next month.', category: 'Patience'),
  ProverbData(id: 9, language: 'Kaonde', original: 'Ubupalu bwa muntu bwafuma mu mutwe wakwe.', translation: 'A person\'s foolishness comes from their own head.', lesson: 'Bad financial decisions are not external — they come from within. Education and discipline are the cures.', category: 'Responsibility'),
  ProverbData(id: 10, language: 'Lozi', original: 'Sitopa sa kuluma, si teli batu kaufela.', translation: 'A disease that bites does not spare anyone.', lesson: 'Inflation and financial hardship do not spare anyone — rich or poor. Everyone needs a plan.', category: 'Planning'),
  ProverbData(id: 11, language: 'Bemba', original: 'Umuntu fikala, tafyala umwana mubi.', translation: 'A person who stays at home cannot have a bad child.', lesson: 'Being present and attentive in your finances — tracking, reviewing, adjusting — prevents costly mistakes.', category: 'Discipline'),
  ProverbData(id: 12, language: 'Nyanja', original: 'Chuma chachoka ndi miyendo.', translation: 'Wealth walks away on legs.', lesson: 'Money that is not invested or saved will leave as fast as it came. Give your money a purpose or it will find its own.', category: 'Investing'),
  ProverbData(id: 13, language: 'Tonga', original: 'Kabange kamudimo bako kutuma.', translation: 'A small axe can also cut a big tree.', lesson: 'ZMW 50 saved weekly. ZMW 200 invested monthly. Small, consistent contributions build enormous wealth over time.', category: 'Savings'),
  ProverbData(id: 14, language: 'Bemba', original: 'Akalamba takalekeshe umusungu.', translation: 'An elder does not abandon wisdom.', lesson: 'Tried and tested financial principles — spend less than you earn, save first, invest consistently — never go out of fashion.', category: 'Wisdom'),
  ProverbData(id: 15, language: 'Lozi', original: 'Bana ba nuka, ba sheba pene.', translation: 'Children of the river look ahead.', lesson: 'Generational wealth requires looking decades ahead, not just to the next payday. Plan for your children\'s children.', category: 'Planning'),
  ProverbData(id: 16, language: 'Nyanja', original: 'Phiri likachera mmwamba, likapeza madzi.', translation: 'A mountain that digs upward finds water.', lesson: 'Pushing against the current — saving when peers spend, investing when others fear — is how wealth is built.', category: 'Discipline'),
  ProverbData(id: 17, language: 'Kaonde', original: 'Mutu mubidi, ukulya amakunde.', translation: 'A person with two heads eats beans.', lesson: 'Two income streams are better than one. Diversify your sources of income just as you diversify investments.', category: 'Income'),
  ProverbData(id: 18, language: 'Bemba', original: 'Ubushiku bwakwata inchende, bwakwata no mweo.', translation: 'The night that catches a crab also catches its life.', lesson: 'Financial emergencies come without warning. An emergency fund means you face them without losing everything.', category: 'Emergency'),
  ProverbData(id: 19, language: 'Tonga', original: 'Jisamu jidyiwa kumuzeezo.', translation: 'Trees are eaten by agreement.', lesson: 'Community savings groups — like chilimba — multiply individual capacity through collective discipline.', category: 'Community'),
  ProverbData(id: 20, language: 'Lozi', original: 'Sizo si si kenile, si fanga taba.', translation: 'A mat that is not woven causes problems.', lesson: 'A budget that is not written down is not a budget. Document your financial plan — it becomes real when it\'s written.', category: 'Budgeting'),
  ProverbData(id: 21, language: 'Nyanja', original: 'Chitsogolo chikangoanika m\'maso.', translation: 'The future is in the eyes.', lesson: 'Visualise your financial goals clearly. A specific target — ZMW 100,000 by 35 — is more powerful than a vague wish.', category: 'Planning'),
  ProverbData(id: 22, language: 'Bemba', original: 'Umuntu uucula, taculapo.', translation: 'A person who endures, has never suffered.', lesson: 'The discipline of delayed gratification — saving instead of spending — becomes its own reward over time.', category: 'Patience'),
  ProverbData(id: 23, language: 'Kaonde', original: 'Wamona mwanzo, wajua mwisho.', translation: 'One who has seen the beginning knows the end.', lesson: 'Understanding how debt accumulates from small payments helps you see where unchecked borrowing ends.', category: 'Debt'),
  ProverbData(id: 24, language: 'Tonga', original: 'Bulelo bwa muntu, busimba bwa nguwe.', translation: 'A person\'s wealth is the skin of a leopard.', lesson: 'Real wealth is hard-earned, distinctive, and not easily copied. Build it your own way, step by step.', category: 'Wealth'),
  ProverbData(id: 25, language: 'Lozi', original: 'Mutu wa bulafu, u bona nto za kwahule.', translation: 'A tall person sees things that are far away.', lesson: 'Financial literacy gives you a longer view — you see the effects of today\'s decisions on your future self.', category: 'Education'),
];

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

class ProverbState {
  const ProverbState({this.record, this.isLoading = false});
  final ProverbRecord? record;
  final bool           isLoading;

  bool isCollected(int id) => record?.collectedProverbIds.contains(id) ?? false;
  int get collectedCount => record?.collectedProverbIds.length ?? 0;
  bool get hasAll => collectedCount >= kTotalProverbs;
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class ProverbNotifier extends StateNotifier<ProverbState> {
  ProverbNotifier(this._ref) : super(const ProverbState(isLoading: true)) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) { _load(); }
    });
    _load();
  }

  final Ref _ref;
  Box<ProverbRecord> get _box => Hive.box<ProverbRecord>(kProverbsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const ProverbState();
      return;
    }
    var record = _box.get(uid);
    if (record == null) {
      record = ProverbRecord(
        uid: uid,
        collectedProverbIds: [],
        totalProverbsSeen: 0,
      );
      await _box.put(uid, record);
    }
    state = ProverbState(record: _box.get(uid));
  }

  Future<void> collectProverb(int proverbId) async {
    final record = state.record;
    if (record == null) { return; }
    record.totalProverbsSeen += 1;
    if (!record.collectedProverbIds.contains(proverbId)) {
      record.collectedProverbIds.add(proverbId);
    }
    await record.save();

    if (record.collectedProverbIds.length >= kTotalProverbs) {
      await _ref.read(authProvider.notifier).addXp(200);
    }
    state = ProverbState(record: _box.get(record.uid));
  }

  /// Returns a random proverb not yet collected, or random from all if all collected.
  ProverbData nextProverb() {
    final collected = Set<int>.from(state.record?.collectedProverbIds ?? []);
    final unseen = kAllProverbs.where((p) => !collected.contains(p.id)).toList();
    final pool = unseen.isEmpty ? List<ProverbData>.from(kAllProverbs) : unseen;
    pool.shuffle(Random());
    return pool.first;
  }

  Future<void> refresh() => _load();
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final proverbProvider = StateNotifierProvider<ProverbNotifier, ProverbState>(
  (ref) => ProverbNotifier(ref),
);

// ─────────────────────────────────────────────────────────────────────────────
// Unlock State & Notifier (string-ID based, stored in kSettingsBox raw box)
// ─────────────────────────────────────────────────────────────────────────────

class ProverbUnlockState {
  const ProverbUnlockState({
    this.unlockedIds = const <String>{},
    this.isLoading = true,
  });
  final Set<String> unlockedIds;
  final bool isLoading;

  bool isUnlocked(String id) => unlockedIds.contains(id);
}

class ProverbUnlockNotifier extends StateNotifier<ProverbUnlockState> {
  ProverbUnlockNotifier(this._ref) : super(const ProverbUnlockState()) {
    _ref.listen<AuthState>(authProvider, (prev, next) {
      if (prev?.currentUser?.uid != next.currentUser?.uid) _load();
    });
    _load();
  }

  final Ref _ref;
  Box get _box => Hive.box(kSettingsBox);
  String? get _uid => _ref.read(currentUserProvider)?.uid;
  String _key(String uid) => 'proverbs_unlocked_$uid';

  Future<void> _load() async {
    final uid = _uid;
    if (uid == null) {
      state = const ProverbUnlockState(unlockedIds: <String>{}, isLoading: false);
      return;
    }
    final stored = _box.get(_key(uid));
    final ids = stored != null
        ? Set<String>.from((stored as List).cast<String>())
        : <String>{};
    if (ids.isEmpty) {
      ids.add('p01');
      await _box.put(_key(uid), ids.toList());
    }
    state = ProverbUnlockState(unlockedIds: ids, isLoading: false);
  }

  Future<void> unlockProverbsForLevel(int level) async {
    final uid = _uid;
    if (uid == null) return;
    final toUnlock = _proverbsForLevel(level);
    if (toUnlock.isEmpty) return;
    final current = Set<String>.from(state.unlockedIds);
    current.addAll(toUnlock);
    await _box.put(_key(uid), current.toList());
    state = ProverbUnlockState(unlockedIds: current, isLoading: false);
  }

  static List<String> _proverbsForLevel(int level) => switch (level) {
    1 => ['p02', 'p03', 'p04', 'p05', 'p06', 'p07'],
    2 => ['p08', 'p09', 'p10', 'p11', 'p12', 'p13'],
    3 => ['p14', 'p15', 'p16', 'p17', 'p18', 'p19'],
    4 => ['p20', 'p21', 'p22', 'p23', 'p24', 'p25'],
    _ => <String>[],
  };
}

final proverbUnlockProvider =
    StateNotifierProvider<ProverbUnlockNotifier, ProverbUnlockState>(
  (ref) => ProverbUnlockNotifier(ref),
);

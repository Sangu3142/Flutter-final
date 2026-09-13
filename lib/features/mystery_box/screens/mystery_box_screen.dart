import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';
import '../../shop/providers/inventory_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/box_open_animation.dart';

class MysteryBoxScreen extends ConsumerStatefulWidget {
  const MysteryBoxScreen({super.key});

  @override
  ConsumerState<MysteryBoxScreen> createState() => _MysteryBoxScreenState();
}

class _MysteryBoxScreenState extends ConsumerState<MysteryBoxScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<BoxOpenAnimationState> _animKey = GlobalKey();
  bool _opening = false;
  bool _done = false;
  String? _lootLabel;
  String? _rarityTier;

  late final AnimationController _entryCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(_fade);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  /// Weighted random loot resolution using kMysteryLootWeights.
  (String tier, String reward) _resolveLoot() {
    final rng = Random();
    final roll = rng.nextInt(100);
    int cumulative = 0;
    String tier = kMysteryLootCommon;
    for (final (t, weight) in kMysteryLootWeights) {
      cumulative += weight;
      if (roll < cumulative) {
        tier = t;
        break;
      }
    }
    final List<String> pool = switch (tier) {
      kMysteryLootRare => kMysteryRareRewards,
      kMysteryLootEpic => kMysteryEpicRewards,
      _ => kMysteryCommonRewards,
    };
    return (tier, pool[rng.nextInt(pool.length)]);
  }

  String _rewardLabel(String reward) {
    return switch (reward) {
      'coins_10' => 'ZMW 10 Coins!',
      'coins_20' => 'ZMW 20 Coins!',
      'coins_30' => 'ZMW 30 Coins!',
      'xp_50'    => '50 XP Bonus!',
      'hint_token' => 'Hint Token!',
      'shield'     => 'Shield Power-Up!',
      'freeze'     => 'Freeze Power-Up!',
      'double_xp'      => 'Double XP Power-Up!',
      'xp_multiplier'  => '1.5× XP Multiplier!',
      'cosmetic_gold_frame' => 'Gold Frame Cosmetic!',
      _ => reward,
    };
  }

  Future<void> _applyReward(String reward) async {
    final inventory = ref.read(inventoryProvider.notifier);
    final auth      = ref.read(authProvider.notifier);

    switch (reward) {
      case 'coins_10': await auth.addWalletCoins(10);
      case 'coins_20': await auth.addWalletCoins(20);
      case 'coins_30': await auth.addWalletCoins(30);
      case 'xp_50':    await auth.addXp(50);
      case 'hint_token': await inventory.addItem('hint_token');
      case 'shield':     await inventory.addItem('shield');
      case 'freeze':     await inventory.addItem('freeze');
      case 'double_xp':     await inventory.addItem('double_xp');
      case 'xp_multiplier': await inventory.addItem('xp_multiplier');
      case 'cosmetic_gold_frame': await inventory.addItem('gold_frame');
    }
  }

  Future<void> _openBox() async {
    if (_opening) return;
    final boxCount = ref.read(inventoryProvider).powerUps['mystery_box'] ?? 0;
    if (boxCount <= 0) return;

    setState(() => _opening = true);

    // Decrement box count first
    await ref.read(inventoryProvider.notifier).consume('mystery_box');

    // Resolve loot
    final (tier, reward) = _resolveLoot();
    setState(() {
      _rarityTier = tier;
      _lootLabel  = _rewardLabel(reward);
    });

    // Wait for widget to rebuild with BoxOpenAnimation before calling play()
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    // Play animation; then apply reward
    await _animKey.currentState?.play();
    if (!mounted) return;
    await _applyReward(reward);
    if (!mounted) return;
    ref.invalidate(inventoryProvider);
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    final boxCount = ref.watch(inventoryProvider).powerUps['mystery_box'] ?? 0;

    return Scaffold(
      backgroundColor: kDeepNavy,
      appBar: AppBar(
        backgroundColor: kDeepNavy,
        title: const Text('Mystery Box', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Text(
                'Boxes available: $boxCount',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              if (_rarityTier != null && _lootLabel != null)
                BoxOpenAnimation(
                  key: _animKey,
                  lootLabel: _lootLabel!,
                  rarityTier: _rarityTier!,
                  onComplete: () {},
                )
              else
                const SizedBox(
                  width: 120,
                  height: 120,
                  child: Center(
                    child: Text('🎁', style: TextStyle(fontSize: 56)),
                  ),
                ),
              const SizedBox(height: 40),
              if (_done)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: kNeonMint),
                  onPressed: () {
                    if (boxCount > 0) {
                      setState(() {
                        _opening    = false;
                        _done       = false;
                        _lootLabel  = null;
                        _rarityTier = null;
                      });
                    } else {
                      context.pop();
                    }
                  },
                  child: Text(
                    boxCount > 0 ? 'Open Another' : 'Done',
                    style: const TextStyle(
                        color: kDeepNavy, fontWeight: FontWeight.bold),
                  ),
                )
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: boxCount > 0 ? kNeonMint : Colors.grey,
                  ),
                  onPressed: (boxCount > 0 && !_opening) ? _openBox : null,
                  child: Text(
                    _opening ? 'Opening…' : 'Open Box',
                    style: const TextStyle(
                        color: kDeepNavy, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
            ),
          ),
        ),
      ),
    );
  }
}

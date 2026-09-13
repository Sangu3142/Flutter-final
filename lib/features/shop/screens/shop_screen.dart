// lib/features/shop/screens/shop_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/inventory_provider.dart';
import '../widgets/shop_item_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../../wallet/widgets/wallet_badge.dart';
import '../../wallet/widgets/coin_earn_animation.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
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
      begin: const Offset(0, 0.06), // ~20px up effect
      end: Offset.zero,
    ).animate(_fade);
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(walletProvider);
    final inventory = ref.watch(inventoryProvider);
    final bottomInset = MediaQuery.of(context).padding.bottom + 16;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: kCoreNavy,
        appBar: AppBar(
          backgroundColor: kCoreNavy,
          title: const Text('Shop', style: TextStyle(color: kCharcoal)),
          actions: const [WalletBadge(), SizedBox(width: 12)],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Power-ups'),
              Tab(text: 'Cosmetics'),
            ],
            labelColor: kNeonMint,
            unselectedLabelColor: kCharcoalLight,
            indicatorColor: kNeonMint,
          ),
        ),
        body: SafeArea(
          top: false,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: TabBarView(
                children: [
                  ListView.builder(
                    padding: EdgeInsets.only(top: 8, bottom: bottomInset),
                    cacheExtent: 200,
                    itemCount: kShopPowerUps.length,
                    itemBuilder: (ctx, i) {
                      final item = kShopPowerUps[i];
                      return ShopItemCard(
                        item: item,
                        inventoryCount: inventory.countOf(item.id),
                        canAfford: walletBalance >= item.price,
                        alreadyOwned: false,
                        onBuy: () async {
                          final success = await ref
                              .read(authProvider.notifier)
                              .spendWalletCoins(item.price);
                          if (!success) return;
                          await ref
                              .read(inventoryProvider.notifier)
                              .addItem(item.id);
                          ref.invalidate(inventoryProvider);
                          if (!ctx.mounted) return;
                          CoinEarnAnimation.show(ctx, -item.price);
                        },
                      );
                    },
                  ),
                  ListView.builder(
                    padding: EdgeInsets.only(top: 8, bottom: bottomInset),
                    cacheExtent: 200,
                    itemCount: kShopCosmetics.length,
                    itemBuilder: (ctx, i) {
                      final item = kShopCosmetics[i];
                      final owned = inventory.unlockedFrames.contains(item.id) ||
                          inventory.unlockedStreakIcons.contains(item.id) ||
                          inventory.unlockedOutfits.contains(item.id);
                      return ShopItemCard(
                        item: item,
                        inventoryCount: 0,
                        canAfford: walletBalance >= item.price,
                        alreadyOwned: owned,
                        onBuy: () async {
                          final success = await ref
                              .read(authProvider.notifier)
                              .spendWalletCoins(item.price);
                          if (!success) return;
                          final notifier =
                              ref.read(inventoryProvider.notifier);
                          await notifier.addItem(item.id);
                          // Auto-equip immediately so the purchase takes effect
                          if (item.id.contains('frame')) {
                            await notifier.equipFrame(item.id);
                          } else if (item.id.contains('flame')) {
                            await notifier.equipStreakIcon(item.id);
                          } else if (item.id.contains('outfit')) {
                            await notifier.equipOutfit(item.id);
                          }
                          ref.invalidate(inventoryProvider);
                        },
                      );
                    },
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

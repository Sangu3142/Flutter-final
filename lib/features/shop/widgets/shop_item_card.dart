// lib/features/shop/widgets/shop_item_card.dart
import 'package:flutter/material.dart';
import '../../../core/constants.dart';
import '../../../core/theme.dart';

class ShopItemCard extends StatefulWidget {
  final ShopItem item;
  final int inventoryCount; // 0 for cosmetics = locked; >0 = owned
  final bool canAfford;
  final bool alreadyOwned; // for cosmetics
  final VoidCallback onBuy;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.inventoryCount,
    required this.canAfford,
    required this.alreadyOwned,
    required this.onBuy,
  });

  @override
  State<ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<ShopItemCard>
    with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final AnimationController _popCtrl;
  late final Animation<double> _popScale;
  bool _showGlow = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _popCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _popScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(_popCtrl);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _popCtrl.dispose();
    super.dispose();
  }

  void _handleBuy() {
    setState(() => _showGlow = true);
    _glowCtrl.forward().then((_) {
      if (!mounted) return;
      _glowCtrl.reverse().then((_) {
        if (mounted) setState(() => _showGlow = false);
      });
    });
    _popCtrl.forward(from: 0);
    widget.onBuy();
  }

  @override
  Widget build(BuildContext context) {
    final disabled = !widget.canAfford || widget.alreadyOwned;
    return AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: ScaleTransition(
        scale: _popScale,
        child: AnimatedBuilder(
          animation: _glowCtrl,
          builder: (_, child) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: kDeepNavy,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _showGlow
                    ? kNeonMint.withValues(alpha: _glowCtrl.value)
                    : kNeonMint.withValues(alpha: 0.2),
              ),
              boxShadow: _showGlow
                  ? [
                      BoxShadow(
                        color: kNeonMint
                            .withValues(alpha: 0.3 * _glowCtrl.value),
                        blurRadius: 12,
                      ),
                      const BoxShadow(
                        color: Color(0xFF050B14),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ]
                  : const [
                      BoxShadow(
                        color: Color(0xFF050B14),
                        offset: Offset(0, 4),
                        blurRadius: 0,
                      ),
                    ],
            ),
            child: child,
          ),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: kNeonMint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(widget.item.emoji,
                    style: const TextStyle(fontSize: 24)),
              ),
            ),
            title: Text(
              widget.item.name,
              style: const TextStyle(
                  color: kCharcoal, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.item.description,
                    style: const TextStyle(
                        color: kCharcoalLight, fontSize: 12)),
                const SizedBox(height: 4),
                if (widget.item.isPowerUp && widget.inventoryCount > 0)
                  Text('In stock: ${widget.inventoryCount}',
                      style: const TextStyle(color: kGreen, fontSize: 11)),
                if (widget.alreadyOwned && !widget.item.isPowerUp)
                  const Text('Owned ✓',
                      style: TextStyle(color: kGreen, fontSize: 11)),
              ],
            ),
            trailing: widget.alreadyOwned && !widget.item.isPowerUp
                ? const Icon(Icons.check_circle, color: kGreen)
                : GestureDetector(
                    onTapDown: disabled
                        ? null
                        : (_) => setState(() => _pressed = true),
                    onTapUp: disabled
                        ? null
                        : (_) => setState(() => _pressed = false),
                    onTapCancel: disabled
                        ? null
                        : () => setState(() => _pressed = false),
                    onTap: disabled ? null : _handleBuy,
                    child: AnimatedScale(
                      scale: _pressed ? 0.96 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      curve: Curves.easeOut,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: widget.canAfford
                              ? kNeonMint
                              : kCharcoalLight,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF050B14),
                              offset: Offset(0, 4),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        child: Text(
                          '🪙 ${widget.item.price}',
                          style: const TextStyle(
                            color: kCoreNavy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

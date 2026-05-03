/// payment_screen.dart
/// Purpose: Simulated payment screen for unlocking a level. Shows the
///          SIMULATED PAYMENT banner, MTN MoMo / Airtel Money selector,
///          a 2-second processing spinner, and a success dialog on completion.
/// Reads from: paymentProvider, levelProvider, authProvider
/// Writes to: paymentProvider → Hive 'payments', levelProvider (unlock)
/// Navigation: ← back to /levels after success
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/payments/providers/payment_provider.dart';

/// [PaymentScreen] presents the full-screen payment UI for a given level.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.levelId});

  final int levelId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedProvider = kProviderMTN;

  @override
  void initState() {
    super.initState();
    // Reset any leftover payment state when opening this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final meta = kLevelMeta[widget.levelId];
    final payState = ref.watch(paymentProvider);

    if (meta == null) {
      return const Scaffold(body: Center(child: Text('Invalid level')));
    }

    // Listen for success → show dialog then navigate back
    ref.listen<PaymentState>(paymentProvider, (prev, next) {
      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        _showSuccessDialog(context, meta);
      }
    });

    return Scaffold(
      backgroundColor: kCream,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ── SIMULATED PAYMENT Banner ─────────────────────────────
              _simulatedBanner(context),

              // ── App Bar (manual) ─────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios),
                    ),
                    Expanded(
                      child: Text(
                        'Unlock ${meta.name}',
                        style: Theme.of(context).textTheme.titleLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Level Summary Card ────────────────────────────
                    _levelSummaryCard(context, meta),

                    const SizedBox(height: 24),

                    // ── What You Unlock ────────────────────────────────
                    _whatYouUnlock(context, meta),

                    const SizedBox(height: 24),

                    // ── Provider Selector ──────────────────────────────
                    Text(
                      'Choose Payment Method',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _providerSelector(context),

                    const SizedBox(height: 24),

                    // ── Phone Number Field (UI only, no validation) ────
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: '$_selectedProvider Phone Number',
                        prefixText: '+260 ',
                        prefixIcon: const Icon(Icons.phone_android),
                        hintText: '97 XXX XXXX',
                      ),
                      keyboardType: TextInputType.phone,
                      enabled: !payState.isProcessing,
                    ),

                    const SizedBox(height: 24),

                    // ── Pay Button ─────────────────────────────────────
                    _payButton(context, meta, payState),

                    const SizedBox(height: 12),

                    // ── ZamCoins bonus notice ─────────────────────────
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🪙', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            'Earn $kPaymentBonusZamCoins ZamCoins on unlock!',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(color: kCharcoalLight),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Error display ──────────────────────────────────
                    if (payState.isFailure && payState.error != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: kError.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: kError),
                        ),
                        child: Text(
                          payState.error!,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: kError),
                        ),
                      ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SIMULATED PAYMENT Banner ──────────────────────────────────────────────

  /// This banner must always be visible on the payment screen to clearly
  /// communicate to users that no real payment is being processed.
  Widget _simulatedBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: kWarning,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            '⚠️ SIMULATED PAYMENT — No real money is transferred',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  // ── Level Summary Card ────────────────────────────────────────────────────

  Widget _levelSummaryCard(BuildContext context, LevelMeta meta) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: kZamGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(meta.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${meta.id}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                ),
                Text(
                  meta.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: kGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ZMW ${meta.price.toStringAsFixed(0)} / month',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: kCharcoal,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── What You Unlock ───────────────────────────────────────────────────────

  Widget _whatYouUnlock(BuildContext context, LevelMeta meta) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What you unlock:',
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: zamCard(),
          child: Column(
            children: [
              _unlockRow(context, '📈',
                  '${meta.simulations.length} interactive financial simulations'),
              _unlockRow(context, '🏆', '${meta.xpReward} XP on completion'),
              _unlockRow(context, '🏅', 'Level ${meta.id} completion badge'),
              _unlockRow(
                  context, '🪙', '$kPaymentBonusZamCoins bonus ZamCoins'),
              ...meta.businesses.map((b) => _unlockRow(context, meta.emoji, b)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _unlockRow(BuildContext context, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: kCharcoal)),
          ),
        ],
      ),
    );
  }

  // ── Provider Selector ─────────────────────────────────────────────────────

  Widget _providerSelector(BuildContext context) {
    return Row(
      children: [kProviderMTN, kProviderAirtel].map((provider) {
        final isSelected = _selectedProvider == provider;
        final isMTN = provider == kProviderMTN;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedProvider = provider),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(right: isMTN ? 8 : 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? kCopper.withValues(alpha: 0.08) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? kCopper : kCopperLight.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: kCopper.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Text(
                    isMTN ? '🟡' : '🔴',
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    provider,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: isSelected ? kCopper : kCharcoal,
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: kCopper, size: 16),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Pay Button ────────────────────────────────────────────────────────────

  Widget _payButton(
    BuildContext context,
    LevelMeta meta,
    PaymentState payState,
  ) {
    return ElevatedButton(
      onPressed: payState.isProcessing
          ? null
          : () => ref.read(paymentProvider.notifier).initiatePayment(
                levelId: widget.levelId,
                provider: _selectedProvider,
              ),
      style: ElevatedButton.styleFrom(
        backgroundColor: payState.isProcessing ? kCopperLight : kCopper,
        minimumSize: const Size.fromHeight(56),
      ),
      child: payState.isProcessing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Processing via $_selectedProvider...',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            )
          : Text(
              'Pay ZMW ${meta.price.toStringAsFixed(0)} via $_selectedProvider',
            ),
    );
  }

  // ── Success Dialog ────────────────────────────────────────────────────────

  void _showSuccessDialog(BuildContext context, LevelMeta meta) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              'Level Unlocked!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: kGreen,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${meta.emoji} ${meta.name}',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: kGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Text(
                    '+$kPaymentBonusZamCoins ZamCoins awarded!',
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium
                        ?.copyWith(color: kCopper, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // dismiss dialog
                  ref.read(paymentProvider.notifier).reset();
                  context.go(AppRoutes.levels); // navigate to level map
                },
                child: const Text('Go to Level Map →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

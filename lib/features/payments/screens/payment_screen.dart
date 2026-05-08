/// payment_screen.dart
/// Purpose: Simulated payment screen for unlocking a level. Shows the
///          SIMULATED PAYMENT banner, MTN MoMo / Airtel Money selector,
///          a 2-second processing spinner, and a success dialog on completion.
/// Reads from: paymentProvider, levelProvider, authProvider
/// Writes to: paymentProvider → Hive 'payments', levelProvider (unlock)
/// Navigation: ← back to /levels after success
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/features/payments/providers/payment_provider.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants
// ─────────────────────────────────────────────────────────────────────────────

const Color _kDeepNavy  = Color(0xFF0D1B2A);
const Color _kNeonMint  = Color(0xFF36ECDE);
const Color _kGold      = Color(0xFFFFB703);
const Color _kGreen     = Color(0xFF2BC48A);
const Color _kSoftGray  = Color(0xFFE6E9EC);
const Color _kWarning   = Color(0xFFFB8500);
const Color _kError     = Color(0xFFEF5350);

class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.levelId});

  final int levelId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  String _selectedProvider = kProviderMTN;
  final TextEditingController _phoneController = TextEditingController();
  String? _phoneError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paymentProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Please enter your phone number';
    if (digits.length < 9) return 'Phone number must be at least 9 digits';
    if (digits.length > 12) return 'Phone number is too long';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final meta = kLevelMeta[widget.levelId];
    final payState = ref.watch(paymentProvider);

    if (meta == null) {
      return const Scaffold(
        backgroundColor: _kDeepNavy,
        body: Center(child: Text('Invalid level', style: TextStyle(color: _kSoftGray))),
      );
    }

    ref.listen<PaymentState>(paymentProvider, (prev, next) {
      if (next.isSuccess && !(prev?.isSuccess ?? false)) {
        _showSuccessDialog(context, meta);
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── SIMULATED PAYMENT Banner ──────────────────────────────
              _simulatedBanner(context),

              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Manual App Bar ────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: _kSoftGray,
                                  size: 20,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Unlock ${meta.name}',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: _kSoftGray,
                                    letterSpacing: 0.4,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Level Summary Card ─────────────────────────────
                        _levelSummaryCard(context, meta),

                        const SizedBox(height: 20),

                        // ── What You Unlock ────────────────────────────────
                        _whatYouUnlock(context, meta),

                        const SizedBox(height: 20),

                        // ── Provider Selector ──────────────────────────────
                        Text(
                          'Choose Payment Method',
                          style: GoogleFonts.rajdhani(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _kSoftGray,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _providerSelector(context),

                        const SizedBox(height: 20),

                        // ── Phone Number Field ─────────────────────────────
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          enabled: !payState.isProcessing,
                          maxLength: 13,
                          style: GoogleFonts.inter(color: _kSoftGray, fontSize: 15),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d+]')),
                          ],
                          onChanged: (_) {
                            setState(() {
                              if (_phoneError != null) _phoneError = null;
                            });
                          },
                          decoration: InputDecoration(
                            labelText: '$_selectedProvider Phone Number',
                            prefixText: '+260 ',
                            prefixStyle: GoogleFonts.inter(color: _kNeonMint, fontSize: 14),
                            prefixIcon: Icon(Icons.phone_android, color: _kNeonMint.withValues(alpha: 0.70), size: 20),
                            hintText: '97 XXX XXXX',
                            counterText: '',
                            errorText: _phoneError,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Pay Button ─────────────────────────────────────
                        _payButton(context, meta, payState),

                        const SizedBox(height: 12),

                        // ── ZamCoins bonus notice ──────────────────────────
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('🪙', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 6),
                              Text(
                                'Earn $kPaymentBonusZamCoins ZamCoins on unlock!',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  color: _kGold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // ── Error display ──────────────────────────────────
                        if (payState.isFailure && payState.error != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _kError.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: _kError.withValues(alpha: 0.60)),
                            ),
                            child: Text(
                              payState.error!,
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: _kError,
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── SIMULATED PAYMENT Banner ──────────────────────────────────────────────

  Widget _simulatedBanner(BuildContext context) {
    final phone = _phoneController.text.trim();
    final hasPhone = phone.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      color: _kWarning.withValues(alpha: 0.90),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.science_outlined, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Flexible(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
                children: [
                  const TextSpan(text: '⚠️ SIMULATED PAYMENT'),
                  if (hasPhone) ...[
                    const TextSpan(text: ' TO '),
                    TextSpan(
                      text: phone,
                      style: const TextStyle(color: _kNeonMint),
                    ),
                  ],
                  const TextSpan(text: ' — No real money is transferred'),
                ],
              ),
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
        gradient: const LinearGradient(
          colors: [Color(0xFF1A73E8), Color(0xFF0D1B2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kNeonMint.withValues(alpha: 0.30)),
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
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: _kSoftGray.withValues(alpha: 0.70),
                  ),
                ),
                Text(
                  meta.name,
                  style: GoogleFonts.rajdhani(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _kGold,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'ZMW ${meta.price.toStringAsFixed(0)} / month',
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0D1B2A),
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
        Text(
          'What you unlock:',
          style: GoogleFonts.rajdhani(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _kSoftGray,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _kDeepNavy.withValues(alpha: 0.80),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            children: [
              _unlockRow(context, '📈', '${meta.simulations.length} interactive financial simulations'),
              _unlockRow(context, '🏆', '${meta.xpReward} XP on completion'),
              _unlockRow(context, '🏅', 'Level ${meta.id} completion badge'),
              _unlockRow(context, '🪙', '$kPaymentBonusZamCoins bonus ZamCoins'),
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
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: _kSoftGray,
                height: 1.4,
              ),
            ),
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
                color: isSelected
                    ? _kNeonMint.withValues(alpha: 0.10)
                    : _kDeepNavy.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? _kNeonMint : Colors.white.withValues(alpha: 0.12),
                  width: isSelected ? 1.5 : 1,
                ),
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
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? _kNeonMint : _kSoftGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: _kNeonMint, size: 16),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Pay Button ────────────────────────────────────────────────────────────

  Widget _payButton(BuildContext context, LevelMeta meta, PaymentState payState) {
    return ElevatedButton(
      onPressed: payState.isProcessing
          ? null
          : () {
              final error = _validatePhone(_phoneController.text);
              if (error != null) {
                setState(() => _phoneError = error);
                return;
              }
              setState(() => _phoneError = null);
              ref.read(paymentProvider.notifier).initiatePayment(
                    levelId: widget.levelId,
                    provider: _selectedProvider,
                  );
            },
      child: payState.isProcessing
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Color(0xFF0D1B2A),
                    strokeWidth: 2.5,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Processing via $_selectedProvider...',
                  style: GoogleFonts.rajdhani(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0D1B2A),
                  ),
                ),
              ],
            )
          : Text(
              'PAY ZMW ${meta.price.toStringAsFixed(0)} VIA $_selectedProvider',
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
    );
  }

  // ── Success Dialog ────────────────────────────────────────────────────────

  void _showSuccessDialog(BuildContext context, LevelMeta meta) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: _kDeepNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: _kGreen.withValues(alpha: 0.50), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              Text(
                'Level Unlocked!',
                style: GoogleFonts.rajdhani(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _kGreen,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                '${meta.emoji} ${meta.name}',
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: _kSoftGray,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _kGold.withValues(alpha: 0.35)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '+$kPaymentBonusZamCoins ZamCoins awarded!',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        color: _kGold,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(paymentProvider.notifier).reset();
                    context.go(AppRoutes.levels);
                  },
                  child: const Text('GO TO LEVEL MAP →'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

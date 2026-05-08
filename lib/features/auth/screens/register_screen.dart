/// register_screen.dart
/// Purpose: Registration screen — collects name, username, and password,
///          creates a new UserProfile in Hive, then routes to onboarding.
/// Reads from: authProvider
/// Writes to: authProvider → Hive boxes 'users', 'session'
/// Navigation: → /onboarding (success), ← /login (back)
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/shared/widgets/animated_gradient_background.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await ref.read(authProvider.notifier).register(
          name: _nameCtrl.text.trim(),
          username: _usernameCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (success && mounted) {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: kError,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                // ── Back Button ───────────────────────────────────────────
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => context.go(AppRoutes.login),
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: kCharcoal.withValues(alpha: 0.80),
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Header ────────────────────────────────────────────────
                Text(
                  'Join the Quest',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: kCharcoal,
                        letterSpacing: 0.5,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Start your financial literacy adventure today',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: kCharcoalLight,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // ── Form Card ─────────────────────────────────────────────
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Display Name
                        TextFormField(
                          controller: _nameCtrl,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoal),
                          decoration: InputDecoration(
                            labelText: 'Your Name',
                            hintText: 'e.g. Chanda',
                            prefixIcon: Icon(Icons.badge_outlined, color: kNeonMint.withValues(alpha: 0.70), size: 20),
                          ),
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            if (v.trim().length < 2) {
                              return 'Name must be at least 2 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Username
                        TextFormField(
                          controller: _usernameCtrl,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoal),
                          decoration: InputDecoration(
                            labelText: 'Username',
                            hintText: 'e.g. chanda_mw (min 3 chars)',
                            prefixIcon: Icon(Icons.alternate_email, color: kNeonMint.withValues(alpha: 0.70), size: 20),
                          ),
                          textInputAction: TextInputAction.next,
                          autocorrect: false,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Please choose a username';
                            }
                            if (v.trim().length < 3) {
                              return 'Username must be at least 3 characters';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                              return 'Only letters, numbers, and underscores';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: _obscurePassword,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoal),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: 'Min 6 characters',
                            prefixIcon: Icon(Icons.lock_outline, color: kNeonMint.withValues(alpha: 0.70), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: kCharcoalLight,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Please create a password';
                            if (v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Confirm Password
                        TextFormField(
                          controller: _confirmCtrl,
                          obscureText: _obscureConfirm,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: kCharcoal),
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: Icon(Icons.lock_outline, color: kNeonMint.withValues(alpha: 0.70), size: 20),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                color: kCharcoalLight,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                          ),
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _submit(),
                          validator: (v) {
                            if (v != _passwordCtrl.text) return 'Passwords do not match';
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        ElevatedButton(
                          onPressed: authState.isLoading ? null : _submit,
                          child: authState.isLoading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    color: kCoreNavy,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text('CREATE ACCOUNT'),
                        ),

                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => context.go(AppRoutes.login),
                          child: const Text('Already have an account? Sign In'),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Benefits Chips ────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _benefitChip('🎮 Gamified learning'),
                    _benefitChip('💰 Real ZMW data'),
                    _benefitChip('📴 Fully offline'),
                    _benefitChip('🏆 Earn badges'),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _benefitChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: kNeonMint.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kNeonMint.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: kCharcoal,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}

/// change_avatar_screen.dart
/// Full-screen avatar picker — replaces the AlertDialog that caused black
/// screen / Navigator stack corruption on physical devices.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/avatar/widgets/avatar_selector.dart';

const Color _kDeepNavy  = Color(0xFF0D1B2A);
const Color _kNeonMint  = Color(0xFF36ECDE);
const Color _kSoftGray  = Color(0xFFE6E9EC);

class ChangeAvatarScreen extends ConsumerStatefulWidget {
  const ChangeAvatarScreen({super.key});

  @override
  ConsumerState<ChangeAvatarScreen> createState() => _ChangeAvatarScreenState();
}

class _ChangeAvatarScreenState extends ConsumerState<ChangeAvatarScreen> {
  late String _selectedId;
  late String _originalId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _selectedId = user?.avatarId ?? 'default';
    _originalId = _selectedId;
  }

  Future<void> _confirm() async {
    setState(() => _isSaving = true);
    await ref.read(authProvider.notifier).setAvatarId(_selectedId);
    // Navigate explicitly to profile rather than popping. The router's
    // refreshListenable fires when authProvider updates (during setAvatarId),
    // which can reset the shell's "beneath" route to /home — making pop()
    // land on home instead of profile.
    if (mounted) context.go(AppRoutes.profile);
  }

  @override
  Widget build(BuildContext context) {
    final hasChanged = _selectedId != _originalId;

    return Scaffold(
      backgroundColor: _kDeepNavy,
      appBar: AppBar(
        backgroundColor: _kDeepNavy,
        foregroundColor: _kSoftGray,
        title: const Text('Change Avatar',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _isSaving ? null : () => context.go(AppRoutes.profile),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: _kNeonMint,
                    ),
                  )
                : TextButton(
                    onPressed: hasChanged ? _confirm : null,
                    child: Text(
                      'Save',
                      style: TextStyle(
                        color: hasChanged ? _kNeonMint : _kSoftGray.withValues(alpha: 0.4),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: AvatarSelector(
          selectedAvatarId: _selectedId,
          onSelect: _isSaving
              ? (_) {}
              : (id) => setState(() => _selectedId = id),
        ),
      ),
    );
  }
}

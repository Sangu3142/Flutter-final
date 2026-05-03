/// dev_screen.dart
/// Purpose: Developer-only screen accessed via 7-tap easter egg on the version
///          label in Profile. Provides sandbox tools: reset all progress,
///          manually unlock levels, view raw Hive box contents, toggle sandbox
///          mode label, and display app version.
/// Reads from: all Hive boxes, authProvider, levelProvider
/// Writes to: all Hive boxes (via reset / unlock), levelProvider, authProvider
/// Navigation: ← back to profile
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zamwealth_quest/core/constants.dart';
import 'package:zamwealth_quest/core/router.dart';
import 'package:zamwealth_quest/core/theme.dart';
import 'package:zamwealth_quest/features/auth/providers/auth_provider.dart';
import 'package:zamwealth_quest/features/levels/providers/level_provider.dart';

/// [DevScreen] is the internal developer console.
class DevScreen extends ConsumerStatefulWidget {
  const DevScreen({super.key});

  @override
  ConsumerState<DevScreen> createState() => _DevScreenState();
}

class _DevScreenState extends ConsumerState<DevScreen> {
  bool _sandboxMode = true;
  String _rawOutput = '';
  String _selectedBox = kUserBox;

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.greenAccent,
        title: const Text(
          '🔧 Developer Console',
          style: TextStyle(
            color: Colors.greenAccent,
            fontFamily: 'monospace',
            fontSize: 16,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Sandbox Mode Toggle ─────────────────────────────────────
          _section(
            context,
            title: '⚙️ Sandbox Mode',
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Payment Sandbox',
                    style: TextStyle(color: Colors.greenAccent)),
                Switch(
                  value: _sandboxMode,
                  activeThumbColor: Colors.greenAccent,
                  onChanged: (v) => setState(() => _sandboxMode = v),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── App Version ─────────────────────────────────────────────
          _section(
            context,
            title: '📋 App Info',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Version', 'v1.0.0+1'),
                _infoRow('Current User', user?.uid ?? 'None'),
                _infoRow('XP', '${user?.xp ?? 0}'),
                _infoRow(
                    'Unlocked Levels', user?.unlockedLevels.join(', ') ?? '—'),
                _infoRow('Sandbox', _sandboxMode ? 'ON' : 'OFF'),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Manually Unlock Levels ──────────────────────────────────
          _section(
            context,
            title: '🔓 Force Unlock Level',
            child: Column(
              children: [2, 3, 4].map((levelId) {
                final meta = kLevelMeta[levelId]!;
                final alreadyUnlocked = user?.hasUnlocked(levelId) ?? false;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${meta.emoji} Level $levelId: ${meta.name}',
                          style: TextStyle(
                            color: alreadyUnlocked
                                ? Colors.green
                                : Colors.greenAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: alreadyUnlocked
                            ? null
                            : () async {
                                final messenger =
                                    ScaffoldMessenger.of(context);
                                await ref
                                    .read(levelProvider.notifier)
                                    .devForceUnlock(levelId);
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text('Level $levelId unlocked!'),
                                      backgroundColor: kGreen,
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              alreadyUnlocked ? Colors.grey : kGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(alreadyUnlocked ? '✓ Done' : 'Unlock',
                            style: const TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 12),

          // ── Raw Hive Viewer ─────────────────────────────────────────
          _section(
            context,
            title: '🗄️ Raw Hive Box Viewer',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Box selector
                DropdownButton<String>(
                  value: _selectedBox,
                  dropdownColor: const Color(0xFF16213E),
                  style: const TextStyle(color: Colors.greenAccent),
                  items: [
                    kUserBox,
                    kLevelBox,
                    kPaymentBox,
                    kSessionBox,
                    kSettingsBox,
                    kLeaderboardBox,
                  ].map((b) {
                    return DropdownMenuItem(
                      value: b,
                      child: Text(b,
                          style: const TextStyle(color: Colors.greenAccent)),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedBox = v);
                  },
                ),

                const SizedBox(height: 8),

                ElevatedButton(
                  onPressed: _readBox,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade800,
                    foregroundColor: Colors.greenAccent,
                  ),
                  child: const Text('Read Box Contents'),
                ),

                if (_rawOutput.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        _rawOutput,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontFamily: 'monospace',
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // ── Reset All Progress ──────────────────────────────────────
          _section(
            context,
            title: '🔴 Danger Zone',
            child: Column(
              children: [
                const Text(
                  '⚠️ This will wipe ALL user data, level progress, and '
                  'payment records from Hive. This cannot be undone.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () => _confirmReset(context, ref),
                  icon: const Icon(Icons.delete_forever),
                  label: const Text('Reset All Progress'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kError,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Read Box ──────────────────────────────────────────────────────────────

  void _readBox() {
    try {
      final box = Hive.box(_selectedBox);
      final sb = StringBuffer();
      sb.writeln('=== $_selectedBox (${box.length} entries) ===\n');
      for (final key in box.keys) {
        final value = box.get(key);
        sb.writeln('[$key]:');
        sb.writeln('  $value');
        sb.writeln();
      }
      setState(() => _rawOutput = sb.toString());
    } catch (e) {
      setState(() => _rawOutput = 'Error reading box "$_selectedBox": $e');
    }
  }

  // ── Confirm Reset ─────────────────────────────────────────────────────────

  void _confirmReset(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('⚠️ Reset All?', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This will delete ALL user profiles, level progress, and payments. '
          'You will be logged out.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: Colors.greenAccent)),
          ),
          ElevatedButton(
            onPressed: () async {
              final router = GoRouter.of(context);
              Navigator.pop(context);
              await ref.read(authProvider.notifier).devResetAll();
              if (mounted) {
                router.go(AppRoutes.login);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: kError),
            child: const Text('Reset Everything'),
          ),
        ],
      ),
    );
  }

  // ── Section Container ─────────────────────────────────────────────────────

  Widget _section(BuildContext context,
      {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.greenAccent,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
          const Divider(color: Colors.greenAccent, height: 16, thickness: 0.5),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$label:',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Text(value,
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

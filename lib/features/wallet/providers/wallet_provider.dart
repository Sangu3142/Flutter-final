library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';

// Watches authProvider (not currentUserProvider) so that any auth state
// emission — even with the same UserProfile reference — triggers a rebuild.
// UserProfile.walletBalance is mutated in place, which means watching
// currentUserProvider would miss the change (same object reference = no diff).
final walletProvider = Provider<int>((ref) {
  return ref.watch(authProvider).currentUser?.walletBalance ?? 0;
});

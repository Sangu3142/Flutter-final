/// news_screen.dart
/// Purpose: Zambian Financial News Feed — newspaper-style headline cards with
///          "What this means for you" educational impact panel.
/// Palette: off-white (#F5F0E8) on deep navy, ink accents.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zamwealth_quest/features/news/providers/news_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette
// ─────────────────────────────────────────────────────────────────────────────

const _kNavy   = Color(0xFF0A1628);
const _kCard   = Color(0xFF0D1B2A);
const _kPaper  = Color(0xFFFFF8E8);
const _kInk    = Color(0xFF1A1A2E);
const _kGold   = Color(0xFFFFB703);
const _kMint   = Color(0xFF36ECDE);
const _kText   = Color(0xFFE6E9EC);

const _kCategoryColors = {
  'Economy':    Color(0xFF1A73E8),
  'Property':   Color(0xFFE76F51),
  'Investment': Color(0xFFFFB703),
  'Business':   Color(0xFF2BC48A),
  'Finance':    Color(0xFF9C27B0),
};

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class NewsScreen extends ConsumerWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final headlines = ref.watch(currentHeadlinesProvider);
    final state     = ref.watch(newsProvider);

    return Scaffold(
      backgroundColor: _kNavy,
      appBar: AppBar(
        backgroundColor: _kNavy,
        foregroundColor: _kText,
        title: const Text('Financial News',
            style: TextStyle(
                color: _kText, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _kGold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _kGold.withValues(alpha: 0.4))),
              child: const Text('WEEKLY',
                  style: TextStyle(
                      color: _kGold, fontSize: 10, fontWeight: FontWeight.bold,
                      letterSpacing: 1.1)),
            ),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: _kGold))
          : headlines.isEmpty
              ? const Center(
                  child: Text('No headlines available',
                      style: TextStyle(color: _kText)))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
                  children: [
                    _buildMastheadBar(),
                    const SizedBox(height: 16),
                    ...headlines.asMap().entries.map((e) {
                      final isMain = e.key == 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: isMain
                            ? _buildMainHeadline(context, e.value)
                            : _buildSecondaryHeadline(context, e.value),
                      );
                    }),
                    const SizedBox(height: 8),
                    _buildFooterNote(),
                  ],
                ),
    );
  }

  // ── Masthead ──────────────────────────────────────────────────────────────

  Widget _buildMastheadBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: _kPaper.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kPaper.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Text('📰', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('THE ZAMWEALTH HERALD',
                    style: TextStyle(
                        color: _kGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        letterSpacing: 1.5)),
                Text('Rotate weekly  •  5 stories curated for your finances',
                    style: TextStyle(
                        color: _kText.withValues(alpha: 0.5), fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Main (featured) headline ──────────────────────────────────────────────

  Widget _buildMainHeadline(BuildContext context, NewsHeadline h) {
    final catColor = _kCategoryColors[h.category] ?? _kMint;

    return GestureDetector(
      onTap: () => _showDetail(context, h),
      child: Container(
        decoration: BoxDecoration(
          color: _kPaper,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category ribbon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: catColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                children: [
                  Text(h.emoji, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    h.category.toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        letterSpacing: 1.2),
                  ),
                  const Spacer(),
                  const Text('FEATURED',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          letterSpacing: 1.0)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.title,
                      style: const TextStyle(
                          color: _kInk,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          height: 1.3)),
                  const SizedBox(height: 8),
                  Text(h.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: _kInk.withValues(alpha: 0.75),
                          fontSize: 13,
                          height: 1.45)),
                  const SizedBox(height: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: catColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: catColor.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: catColor, size: 14),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(h.impact,
                              style: TextStyle(
                                  color: _kInk.withValues(alpha: 0.8),
                                  fontSize: 11,
                                  height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text('Tap to read more →',
                        style: TextStyle(
                            color: catColor, fontSize: 11,
                            fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Secondary headline ────────────────────────────────────────────────────

  Widget _buildSecondaryHeadline(BuildContext context, NewsHeadline h) {
    final catColor = _kCategoryColors[h.category] ?? _kMint;

    return GestureDetector(
      onTap: () => _showDetail(context, h),
      child: Container(
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: catColor.withValues(alpha: 0.25)),
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(h.emoji,
                    style: const TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(h.category.toUpperCase(),
                      style: TextStyle(
                          color: catColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1)),
                  const SizedBox(height: 3),
                  Text(h.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: _kText.withValues(alpha: 0.9),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          height: 1.3)),
                  const SizedBox(height: 5),
                  Text(h.impact,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: _kText.withValues(alpha: 0.55),
                          fontSize: 11,
                          height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Detail modal ──────────────────────────────────────────────────────────

  void _showDetail(BuildContext context, NewsHeadline h) {
    final catColor = _kCategoryColors[h.category] ?? _kMint;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: _kCard,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(
          controller: scrollCtrl,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: catColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${h.emoji}  ${h.category}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
              const SizedBox(height: 12),
              Text(h.title,
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.95),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.3)),
              const SizedBox(height: 14),
              Text(h.body,
                  style: TextStyle(
                      color: _kText.withValues(alpha: 0.75),
                      fontSize: 14,
                      height: 1.55)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: catColor.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb, color: catColor, size: 16),
                        const SizedBox(width: 6),
                        Text('What this means for you',
                            style: TextStyle(
                                color: catColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(h.impact,
                        style: TextStyle(
                            color: _kText.withValues(alpha: 0.8),
                            fontSize: 13,
                            height: 1.5)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer note ───────────────────────────────────────────────────────────

  Widget _buildFooterNote() {
    return Center(
      child: Text(
        'Stories rotate weekly. For educational purposes only.\nNot financial advice.',
        textAlign: TextAlign.center,
        style: TextStyle(
            color: _kText.withValues(alpha: 0.3), fontSize: 11, height: 1.5),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router.dart';
import '../../../core/theme.dart';

class MiniGamesScreen extends StatefulWidget {
  const MiniGamesScreen({super.key});

  @override
  State<MiniGamesScreen> createState() => _MiniGamesScreenState();
}

class _MiniGamesScreenState extends State<MiniGamesScreen>
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
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Scaffold(
      backgroundColor: kCoreNavy,
      appBar: AppBar(
        backgroundColor: kCoreNavy,
        title: const Text('Mini-Games', style: TextStyle(color: kCharcoal)),
      ),
      body: SafeArea(
        top: false,
        child: FadeTransition(
          opacity: _fade,
          child: SlideTransition(
            position: _slide,
            child: ListView(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: mq.padding.bottom + 16,
              ),
              cacheExtent: 200,
              children: [
                _GameCard(
                  emoji: '💰',
                  title: 'Budget Blitz',
                  description:
                      'Drag expense cards into Need or Want buckets before the timer runs out!',
                  onTap: () => context.push(AppRoutes.budgetBlitz),
                ),
                const SizedBox(height: 16),
                _GameCard(
                  emoji: '📈',
                  title: 'Investment Flip',
                  description:
                      'Match financial terms with their definitions before time expires!',
                  onTap: () => context.push(AppRoutes.investFlip),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameCard extends StatefulWidget {
  final String emoji;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _GameCard({
    required this.emoji,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v && mounted) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kDeepNavy,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kNeonMint.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(widget.emoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title,
                        style: const TextStyle(
                            color: kCharcoal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.description,
                        style: const TextStyle(
                            color: kCharcoalLight, fontSize: 13)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kNeonMint),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme.dart';
import '../models/dialogue_moment.dart';
import '../providers/story_provider.dart';
import 'character_portrait_painter.dart';
import 'consequence_card.dart';

class DialogueChoiceCard extends ConsumerStatefulWidget {
  final DialogueMoment moment;
  final VoidCallback onDismiss;

  const DialogueChoiceCard({
    super.key,
    required this.moment,
    required this.onDismiss,
  });

  @override
  ConsumerState<DialogueChoiceCard> createState() =>
      _DialogueChoiceCardState();
}

class _DialogueChoiceCardState extends ConsumerState<DialogueChoiceCard> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    if (_selectedIndex != null) {
      return ConsequenceCard(
        option: widget.moment.options[_selectedIndex!],
        onDismiss: widget.onDismiss,
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kDeepNavy,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kNeonMint, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: kNeonMint.withValues(alpha: 0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                CharacterPortrait(speakerName: widget.moment.speakerName),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.moment.promptText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(widget.moment.options.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GestureDetector(
                  onTap: () {
                    ref.read(storyProvider.notifier).recordDialogueChoice(
                          widget.moment.momentId,
                          i,
                          widget.moment.options[i],
                        );
                    setState(() => _selectedIndex = i);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F2A44),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      widget.moment.options[i].text,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

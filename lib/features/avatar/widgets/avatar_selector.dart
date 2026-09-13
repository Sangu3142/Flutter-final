import 'package:flutter/material.dart';
import '../models/avatar_config.dart';
import 'avatar_painter.dart';
import '../../../core/theme.dart';

class AvatarSelector extends StatelessWidget {
  final String selectedAvatarId;
  final void Function(String avatarId) onSelect;

  const AvatarSelector({
    super.key,
    required this.selectedAvatarId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > constraints.maxHeight;
        final columns = isLandscape ? 5 : 3;
        return GridView.builder(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            MediaQuery.paddingOf(context).bottom + 16,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.82,
          ),
          itemCount: kAvatarConfigs.length,
          itemBuilder: (context, index) {
            final config = kAvatarConfigs[index];
            final isSelected = config.id == selectedAvatarId;
            return _AvatarCell(
              config: config,
              isSelected: isSelected,
              onTap: () => onSelect(config.id),
            );
          },
        );
      },
    );
  }
}

class _AvatarCell extends StatefulWidget {
  final AvatarConfig config;
  final bool isSelected;
  final VoidCallback onTap;

  const _AvatarCell({
    required this.config,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_AvatarCell> createState() => _AvatarCellState();
}

class _AvatarCellState extends State<_AvatarCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
    ]).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ctrl.forward(from: 0);
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: widget.isSelected
                ? kNeonMint.withValues(alpha: 0.12)
                : const Color(0xFF0D1B2A),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: widget.isSelected
                  ? kNeonMint
                  : Colors.white.withValues(alpha: 0.10),
              width: widget.isSelected ? 2.5 : 1,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: kNeonMint.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AvatarWidget(avatarId: widget.config.id, size: 56),
                  if (widget.isSelected)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: kNeonMint,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: const Color(0xFF0D1B2A), width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 12,
                          color: Color(0xFF0D1B2A),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                widget.config.label,
                style: TextStyle(
                  color: widget.isSelected ? kNeonMint : Colors.white54,
                  fontSize: 10,
                  fontWeight: widget.isSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

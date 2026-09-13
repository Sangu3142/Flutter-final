// lib/features/flash_challenge/widgets/countdown_timer_bar.dart
import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class CountdownTimerBar extends StatefulWidget {
  final int durationSeconds;
  final VoidCallback onExpired;
  final bool paused;

  const CountdownTimerBar({
    super.key,
    required this.durationSeconds,
    required this.onExpired,
    this.paused = false,
  });

  @override
  State<CountdownTimerBar> createState() => CountdownTimerBarState();
}

class CountdownTimerBarState extends State<CountdownTimerBar> {
  late double _progress; // 1.0 = full, 0.0 = empty
  late int _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.durationSeconds;
    _progress = 1.0;
    _startTimer();
  }

  @override
  void didUpdateWidget(CountdownTimerBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.paused != widget.paused) {
      if (widget.paused) {
        _timer?.cancel();
      } else {
        _startTimer();
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining--;
        _progress = _remaining / widget.durationSeconds;
      });
      if (_remaining <= 0) {
        _timer?.cancel();
        widget.onExpired();
      }
    });
  }

  void freeze(int seconds) {
    _timer?.cancel();
    Future.delayed(Duration(seconds: seconds), () {
      if (mounted && !widget.paused) _startTimer();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _progress > 0.5
        ? kGreen
        : _progress > 0.25
            ? kWarning
            : kError;
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress.clamp(0.0, 1.0),
          backgroundColor: kDeepNavy,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
        ),
        const SizedBox(height: 4),
        Text(
          '$_remaining s',
          style: TextStyle(
              color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

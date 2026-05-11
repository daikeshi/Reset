import 'dart:async';

import 'package:flutter/material.dart';

import '../models/activity_type.dart';
import '../state/reset_app_state.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/gradient_action_button.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({
    super.key,
    required this.appState,
    required this.onChanged,
  });

  final ResetAppState appState;
  final VoidCallback onChanged;

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  late ({ActivityType type, String suggestion}) _activity;
  Timer? _timer;
  late int _timeRemaining;
  bool _isRunning = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    _activity = ActivityType.randomSuggestion();
    _timeRemaining = widget.appState.settings.breakDurationMinutes * 60;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeRemaining <= 1) {
        timer.cancel();
        setState(() {
          _timeRemaining = 0;
          _isComplete = true;
        });
      } else {
        setState(() => _timeRemaining -= 1);
      }
    });
  }

  void _completeBreak() {
    widget.appState.logCompletedBreak(
      _activity.type,
      durationSeconds: widget.appState.settings.breakDurationMinutes * 60,
    );
    widget.onChanged();
    Navigator.of(context).pop();
  }

  void _skipBreak() {
    widget.appState.logSkippedBreak(_activity.type);
    widget.onChanged();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final totalSeconds = widget.appState.settings.breakDurationMinutes * 60;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Break Time'),
        leading: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        leadingWidth: 88,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFAF4FF), Color(0xFFF7FBFF)],
          ),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.deepPurple.withValues(alpha: 0.10),
                  ),
                  child: SizedBox.square(
                    dimension: 116,
                    child: Center(
                      child: Text(
                        _activity.type.icon,
                        style: const TextStyle(fontSize: 56),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  _activity.type.label,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 14),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 16,
                    ),
                    child: Text(
                      _activity.suggestion,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Opacity(
                  opacity: _isRunning || _isComplete ? 1 : 0.36,
                  child: CountdownRing(
                    size: 170,
                    progress: totalSeconds == 0
                        ? 1
                        : 1 - (_timeRemaining / totalSeconds),
                    label: _formatTime(_timeRemaining),
                    caption: 'break timer',
                  ),
                ),
                const Spacer(),
                if (_isComplete)
                  GradientActionButton(
                    label: 'Complete!',
                    icon: Icons.check_circle_rounded,
                    colors: const [Colors.green, Colors.teal],
                    onPressed: _completeBreak,
                  )
                else ...[
                  GradientActionButton(
                    label: _isRunning ? 'Timer Running' : 'Start Timer',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _isRunning ? null : _startTimer,
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: _skipBreak,
                    child: const Text('Skip this break'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainder = seconds % 60;
    return '$minutes:${remainder.toString().padLeft(2, '0')}';
  }
}

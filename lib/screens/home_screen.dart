import 'dart:async';

import 'package:flutter/material.dart';

import '../screens/break_screen.dart';
import '../state/reset_app_state.dart';
import '../widgets/countdown_ring.dart';
import '../widgets/gradient_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.appState,
    required this.onChanged,
  });

  final ResetAppState appState;
  final VoidCallback onChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  late DateTime _nextBreakDate;

  @override
  void initState() {
    super.initState();
    _scheduleNextBreak();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState.settings.reminderIntervalMinutes !=
        widget.appState.settings.reminderIntervalMinutes) {
      _scheduleNextBreak();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) {
      return;
    }

    if (_nextBreakDate.difference(DateTime.now()).isNegative) {
      _scheduleNextBreak();
      _openBreak();
    } else {
      setState(() {});
    }
  }

  void _scheduleNextBreak() {
    _nextBreakDate = DateTime.now().add(
      Duration(minutes: widget.appState.settings.reminderIntervalMinutes),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openBreak() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => BreakScreen(
          appState: widget.appState,
          onChanged: () {
            widget.onChanged();
            setState(() {});
          },
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF4ECFF), Color(0xFFF7FBFF)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _Header(appState: widget.appState),
              const Spacer(),
              CountdownRing(
                progress: _progress,
                label: _timeRemaining,
                caption: 'until break',
              ),
              const SizedBox(height: 26),
              _StreakBadge(streak: widget.appState.currentStreak),
              const SizedBox(height: 24),
              _HomeTotals(appState: widget.appState),
              const Spacer(),
              GradientActionButton(
                label: 'Take Break Now',
                icon: Icons.play_arrow_rounded,
                onPressed: _openBreak,
              ),
            ],
          ),
        ),
      ),
    );
  }

  double get _progress {
    final interval = widget.appState.settings.reminderIntervalMinutes * 60;
    final remaining = _nextBreakDate.difference(DateTime.now()).inSeconds;
    return 1 - (remaining / interval);
  }

  String get _timeRemaining {
    final remaining = _nextBreakDate.difference(DateTime.now());
    final seconds = remaining.isNegative ? 0 : remaining.inSeconds;
    final minutesPart = (seconds ~/ 60).toString().padLeft(2, '0');
    final secondsPart = (seconds % 60).toString().padLeft(2, '0');
    return '$minutesPart:$secondsPart';
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Reset',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        if (!appState.settings.notificationsEnabled)
          Chip(
            avatar: const Icon(Icons.notifications_off_outlined, size: 18),
            label: const Text('Alerts off'),
            side: BorderSide.none,
            backgroundColor: Colors.white.withValues(alpha: 0.72),
          ),
      ],
    );
  }
}

class _StreakBadge extends StatelessWidget {
  const _StreakBadge({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_fire_department, color: Colors.orange),
            const SizedBox(width: 8),
            Text(
              '$streak day streak',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTotals extends StatelessWidget {
  const _HomeTotals({required this.appState});

  final ResetAppState appState;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TotalValue(
              value: appState.breaksToday.toString(),
              label: 'breaks today',
            ),
            Container(
              width: 1,
              height: 42,
              margin: const EdgeInsets.symmetric(horizontal: 28),
              color: Colors.black.withValues(alpha: 0.12),
            ),
            _TotalValue(
              value: appState.totalMinutes.toString(),
              label: 'mins moved',
            ),
          ],
        ),
      ),
    );
  }
}

class _TotalValue extends StatelessWidget {
  const _TotalValue({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

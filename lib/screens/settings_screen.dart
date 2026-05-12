import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_settings.dart';
import '../state/reset_app_state.dart';
import '../theme/reset_theme.dart';
import '../widgets/reset_panel.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.appState,
    required this.onChanged,
  });

  final ResetAppState appState;
  final VoidCallback onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isSaving = false;

  Future<void> _runSettingUpdate(Future<void> Function() update) async {
    setState(() => _isSaving = true);
    await update();
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    widget.onChanged();
  }

  Future<void> _setNotificationsEnabled(bool value) async {
    setState(() => _isSaving = true);
    final enabled = await widget.appState.setNotificationsEnabled(value);
    if (!mounted) {
      return;
    }
    setState(() => _isSaving = false);
    widget.onChanged();
    if (value && !enabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission was not granted'),
        ),
      );
    }
  }

  Future<void> _openStore() async {
    final uri = Uri.parse('https://apps.apple.com');
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the App Store link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = widget.appState.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: ResetDecorations.screen(),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
          children: [
            _SettingsSection(
              title: 'Reminders',
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Enable Notifications'),
                  subtitle: settings.notificationsEnabled
                      ? const Text('Break reminders are scheduled')
                      : const Text('Turn on reminders for healthy breaks'),
                  value: settings.notificationsEnabled,
                  onChanged: _isSaving ? null : _setNotificationsEnabled,
                ),
                const _TileDivider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Sound'),
                  value: settings.soundEnabled,
                  onChanged: !settings.notificationsEnabled || _isSaving
                      ? null
                      : (value) => _runSettingUpdate(
                          () => widget.appState.setSoundEnabled(value),
                        ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'Timing',
              children: [
                _MinuteStepperTile(
                  title: 'Focus Time',
                  value: settings.reminderIntervalMinutes,
                  minValue: UserSettings.minReminderIntervalMinutes,
                  maxValue: UserSettings.maxReminderIntervalMinutes,
                  decrementKey: const ValueKey('focus-time-decrement'),
                  incrementKey: const ValueKey('focus-time-increment'),
                  onChanged: _isSaving
                      ? null
                      : (value) => _runSettingUpdate(
                          () => widget.appState.setReminderInterval(value),
                        ),
                ),
                const _TileDivider(),
                _MinuteStepperTile(
                  title: 'Break Duration',
                  value: settings.breakDurationMinutes,
                  minValue: UserSettings.minBreakDurationMinutes,
                  maxValue: UserSettings.maxBreakDurationMinutes,
                  decrementKey: const ValueKey('break-duration-decrement'),
                  incrementKey: const ValueKey('break-duration-increment'),
                  onChanged: _isSaving
                      ? null
                      : (value) => _runSettingUpdate(
                          () => widget.appState.setBreakDuration(value),
                        ),
                ),
                const _TileDivider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Quiet Hours'),
                  subtitle: const Text('No reminders during these hours'),
                  trailing: Text(
                    '${settings.quietHoursStart} - ${settings.quietHoursEnd}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: ResetColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SettingsSection(
              title: 'App',
              children: [
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('Version'),
                  trailing: Text('1.0.0'),
                ),
                const _TileDivider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Rate Reset'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: _openStore,
                ),
                const _TileDivider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Share App'),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: _openStore,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ResetPanel(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 4),
            child: Text(
              title,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: ResetColors.primaryDeep,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  const _TileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: ResetColors.border);
  }
}

class _MinuteStepperTile extends StatelessWidget {
  const _MinuteStepperTile({
    required this.title,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.decrementKey,
    required this.incrementKey,
    required this.onChanged,
  });

  final String title;
  final int value;
  final int minValue;
  final int maxValue;
  final Key decrementKey;
  final Key incrementKey;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final canDecrement = onChanged != null && value > minValue;
    final canIncrement = onChanged != null && value < maxValue;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: decrementKey,
            tooltip: 'Decrease $title',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.remove_rounded),
            onPressed: canDecrement ? () => onChanged!(value - 1) : null,
          ),
          SizedBox(
            width: 62,
            child: Text(
              '$value min',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: ResetColors.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            key: incrementKey,
            tooltip: 'Increase $title',
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.add_rounded),
            onPressed: canIncrement ? () => onChanged!(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

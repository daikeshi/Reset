import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/user_settings.dart';
import '../state/reset_app_state.dart';

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
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: settings.notificationsEnabled
                ? const Text('Break reminders are scheduled')
                : const Text('Turn on reminders for healthy breaks'),
            value: settings.notificationsEnabled,
            onChanged: _isSaving ? null : _setNotificationsEnabled,
          ),
          SwitchListTile(
            title: const Text('Sound'),
            value: settings.soundEnabled,
            onChanged: !settings.notificationsEnabled || _isSaving
                ? null
                : (value) => _runSettingUpdate(
                    () => widget.appState.setSoundEnabled(value),
                  ),
          ),
          const Divider(height: 24),
          _DropdownTile<int>(
            title: 'Reminder Interval',
            value: settings.reminderIntervalMinutes,
            values: UserSettings.intervals,
            labelFor: (value) => '$value min',
            onChanged: _isSaving
                ? null
                : (value) => _runSettingUpdate(
                    () => widget.appState.setReminderInterval(value),
                  ),
          ),
          _DropdownTile<int>(
            title: 'Break Duration',
            value: settings.breakDurationMinutes,
            values: UserSettings.breakDurations,
            labelFor: (value) => '$value min',
            onChanged: _isSaving
                ? null
                : (value) => _runSettingUpdate(
                    () => widget.appState.setBreakDuration(value),
                  ),
          ),
          const Divider(height: 24),
          ListTile(
            title: const Text('Quiet Hours'),
            subtitle: const Text('No reminders during these hours'),
            trailing: Text(
              '${settings.quietHoursStart} - ${settings.quietHoursEnd}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Divider(height: 24),
          const ListTile(title: Text('Version'), trailing: Text('1.0.0')),
          ListTile(
            title: const Text('Rate Reset'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: _openStore,
          ),
          ListTile(
            title: const Text('Share App'),
            trailing: const Icon(Icons.open_in_new_rounded),
            onTap: _openStore,
          ),
        ],
      ),
    );
  }
}

class _DropdownTile<T> extends StatelessWidget {
  const _DropdownTile({
    required this.title,
    required this.value,
    required this.values,
    required this.labelFor,
    required this.onChanged,
  });

  final String title;
  final T value;
  final List<T> values;
  final String Function(T value) labelFor;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: DropdownButton<T>(
        value: value,
        underline: const SizedBox.shrink(),
        items: [
          for (final item in values)
            DropdownMenuItem(value: item, child: Text(labelFor(item))),
        ],
        onChanged: onChanged == null
            ? null
            : (value) {
                if (value != null) {
                  onChanged!(value);
                }
              },
      ),
    );
  }
}

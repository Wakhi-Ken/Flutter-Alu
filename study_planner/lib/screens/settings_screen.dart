import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final String storageMethod;

  const SettingsScreen({super.key, required this.storageMethod});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _remindersEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadReminderSetting();
  }

  Future<void> _loadReminderSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _remindersEnabled = prefs.getBool('remindersEnabled') ?? true;
    });
  }

  Future<void> _saveReminderSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remindersEnabled', value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReminderSetting,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.grey[900]?.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text(
                "Enable Reminders",
                style: TextStyle(color: Colors.white),
              ),
              trailing: Switch(
                value: _remindersEnabled,
                activeColor: theme.colorScheme.primary,
                onChanged: (value) {
                  setState(() => _remindersEnabled = value);
                  _saveReminderSetting(value);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: Colors.grey[900]?.withOpacity(0.85),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: const Text(
                "Storage Method",
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                widget.storageMethod,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

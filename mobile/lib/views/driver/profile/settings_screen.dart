import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifications = true;
  bool _locationTracking = true;
  bool _darkMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: const Color(0xFF0F4C3A), foregroundColor: Colors.white),
      body: ListView(children: [
        SwitchListTile(title: const Text('Push Notifications'), subtitle: const Text('Receive alerts for new jobs'), value: _notifications, onChanged: (v) => setState(() => _notifications = v), activeThumbColor: const Color(0xFF0F4C3A)),
        SwitchListTile(title: const Text('Location Tracking'), subtitle: const Text('Share location during active routes'), value: _locationTracking, onChanged: (v) => setState(() => _locationTracking = v), activeThumbColor: const Color(0xFF0F4C3A)),
        SwitchListTile(title: const Text('Dark Mode'), value: _darkMode, onChanged: (v) => setState(() => _darkMode = v), activeThumbColor: const Color(0xFF0F4C3A)),
        ListTile(title: const Text('Change Password'), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {}),
        ListTile(title: const Text('Privacy Policy'), trailing: const Icon(Icons.arrow_forward_ios, size: 14), onTap: () {}),
        ListTile(title: const Text('Sign Out'), leading: const Icon(Icons.logout, color: Colors.red), onTap: () {}),
      ]),
    );
  }
}



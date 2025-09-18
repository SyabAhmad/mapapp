import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  String _mapStyle = 'Standard';
  String _distanceUnit = 'Kilometers';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          SwitchListTile(
            title: const Text('Enable Notifications'),
            subtitle: const Text('Get notified about nearby places'),
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          ListTile(
            title: const Text('Map Style'),
            subtitle: Text(_mapStyle),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showMapStyleDialog();
            },
          ),
          ListTile(
            title: const Text('Distance Unit'),
            subtitle: Text(_distanceUnit),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              _showDistanceUnitDialog();
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Location Permissions'),
            subtitle: const Text('Manage app location access'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Geolocator.openAppSettings();
            },
          ),
          ListTile(
            title: const Text('About'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Nearby Places',
                applicationVersion: '1.0.0',
                children: const [
                  Text('Find nearby places around you'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  void _showMapStyleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Map Style'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Standard'),
                value: 'Standard',
                groupValue: _mapStyle,
                onChanged: (value) {
                  setState(() {
                    _mapStyle = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('Satellite'),
                value: 'Satellite',
                groupValue: _mapStyle,
                onChanged: (value) {
                  setState(() {
                    _mapStyle = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('Terrain'),
                value: 'Terrain',
                groupValue: _mapStyle,
                onChanged: (value) {
                  setState(() {
                    _mapStyle = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDistanceUnitDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Distance Unit'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('Kilometers'),
                value: 'Kilometers',
                groupValue: _distanceUnit,
                onChanged: (value) {
                  setState(() {
                    _distanceUnit = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              RadioListTile<String>(
                title: const Text('Miles'),
                value: 'Miles',
                groupValue: _distanceUnit,
                onChanged: (value) {
                  setState(() {
                    _distanceUnit = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
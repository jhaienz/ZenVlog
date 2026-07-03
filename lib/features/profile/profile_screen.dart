import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app/router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.settings, color: Color(0xFFD4A853)),
            title: const Text('Settings'),
            onTap: () => context.push(kSettingsRoute),
          ),
        ],
      ),
    );
  }
}

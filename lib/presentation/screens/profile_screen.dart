import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 16),
              // Profile avatar
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.15),
                  child: authProvider.isSignedIn && authProvider.userName != null
                      ? Text(
                          authProvider.userName![0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : const Icon(Icons.person,
                          size: 48, color: AppTheme.primaryColor),
                ),
              ),
              const SizedBox(height: 16),
              // Name and email
              Center(
                child: Text(
                  authProvider.userName ?? 'Guest',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              if (authProvider.userEmail != null)
                Center(
                  child: Text(
                    authProvider.userEmail!,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              const SizedBox(height: 12),
              // Sign In button
              if (!authProvider.isSignedIn)
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => authProvider.signIn(),
                    icon: const Icon(Icons.login),
                    label: const Text('Sign In'),
                  ),
                ),
              const SizedBox(height: 24),
              // Stats section
              Text(
                'Stats',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _StatItem(label: 'Played', value: '—'),
                      _StatItem(label: 'Won', value: '—'),
                      _StatItem(label: 'Best', value: '—'),
                      _StatItem(label: 'Words', value: '—'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Settings section
              Text(
                'Settings',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.help_outline),
                      title: const Text('Help'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.block),
                      title: const Text('Remove Ads'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.restore),
                      title: const Text('Restore Purchases'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Sign Out button
              if (authProvider.isSignedIn)
                Center(
                  child: TextButton.icon(
                    onPressed: () => authProvider.signOut(),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Sign Out',
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}

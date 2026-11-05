import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

/// About screen showing app information
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // App Logo
          Center(
            child: Image.asset(
              'assets/img/logo-256.png',
              width: 120,
              height: 120,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.radar,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          
          // App Name and Version
          Text(
            AppConstants.appName,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Version ${AppConstants.appVersion}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppConstants.appDescription,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          
          // Features Section
          _buildSectionTitle(context, 'Features'),
          _buildFeatureTile(
            context,
            icon: Icons.wifi,
            title: 'Local Network Transfer',
            subtitle: 'Share files without internet connection',
          ),
          _buildFeatureTile(
            context,
            icon: Icons.security,
            title: 'Secure & Private',
            subtitle: 'No data leaves your local network',
          ),
          _buildFeatureTile(
            context,
            icon: Icons.devices,
            title: 'Cross-Platform',
            subtitle: 'Works on Android, iOS, Windows, macOS, Linux',
          ),
          _buildFeatureTile(
            context,
            icon: Icons.speed,
            title: 'Fast Transfer',
            subtitle: 'Direct peer-to-peer connection',
          ),
          const SizedBox(height: 16),
          
          // Links Section
          _buildSectionTitle(context, 'Links'),
          _buildLinkCard(
            context,
            icon: Icons.code,
            title: 'GitHub Repository',
            subtitle: 'View source code and contribute',
            url: AppConstants.githubRepo,
          ),
          _buildLinkCard(
            context,
            icon: Icons.language,
            title: 'Official Website',
            subtitle: 'Learn more about LocalSend',
            url: AppConstants.websiteUrl,
          ),
          _buildLinkCard(
            context,
            icon: Icons.chat,
            title: 'Discord Community',
            subtitle: 'Join the discussion',
            url: AppConstants.discordUrl,
          ),
          _buildLinkCard(
            context,
            icon: Icons.bug_report,
            title: 'Report Issues',
            subtitle: 'Found a bug? Let us know',
            url: AppConstants.githubIssues,
          ),
          const SizedBox(height: 16),
          
          // License Section
          _buildSectionTitle(context, 'License'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'MIT License',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This is an open-source project. Feel free to use, modify, and distribute.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Credits
          Text(
            'Made with ❤️ by LocalSend Team',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Clone implementation for educational purposes',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFeatureTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    );
  }

  Widget _buildLinkCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String url,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.open_in_new, size: 20),
        onTap: () => _launchUrl(url),
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

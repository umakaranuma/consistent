import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        backgroundColor: AppColors.bg0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bg2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSection(
                  'Introduction',
                  'VitaTrack ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our mobile application.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Information We Collect',
                  'VitaTrack is designed with privacy in mind. We do not collect or gather any user data on our servers. All information you enter in the application, including:\n\n'
                      '• Body measurements (weight, height)\n'
                      '• Daily schedule and logs\n'
                      '• Water consumption data\n'
                      '• Fitness goals and preferences\n'
                      '• Notification settings\n\n'
                      'is stored exclusively on your device using local storage. We do not have any backend servers, and no data is transmitted to external servers. Your data remains completely private and under your control.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'How We Use Your Information',
                  'Since all data is stored locally on your device, we do not have access to your information. The application uses your locally stored data strictly to:\n\n'
                      '• Calculate BMI, calories, and macros locally\n'
                      '• Generate and manage your daily health schedule\n'
                      '• Send you local notifications (if enabled) precisely on time\n\n'
                      'No data is transmitted to external servers or third parties.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Data Storage',
                  'All your health and fitness data is stored exclusively on your device using local storage. We do not have any backend infrastructure, cloud services, or external servers. Your data never leaves your device and is not transmitted anywhere.\n\n'
                      'You have complete control over your data and can delete it at any time. Since all data is local, if you uninstall the app, all data will be permanently removed from your device.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Data Security',
                  'We implement appropriate technical and organizational measures to protect your personal information on your device. However, since the data resides on your device, the physical and digital security of your device itself is your responsibility.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Third-Party Services',
                  'Currently, VitaTrack operates entirely offline. It does not integrate with third-party analytics or tracking frameworks. Our app may contain links to external resources, and we encourage you to read their privacy policies.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Changes to This Privacy Policy',
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Contact Us',
                  'If you have any questions or comments about this Privacy Policy, please contact us at:\n\n'
                      'Email: fynux.bussiness@gmail.com',
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.bg2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.bg3,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Last updated: May 17, 2026',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.bg2,
            AppColors.bg3.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border1, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

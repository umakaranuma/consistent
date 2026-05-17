import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
                  'Agreement to Terms',
                  'By accessing or using VitaTrack, you agree to be bound by these Terms of Service. If you disagree with any part of these terms, then you may not access the service.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Use License',
                  'Permission is granted to temporarily download one copy of VitaTrack for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n'
                      '• Modify or copy the materials\n'
                      '• Use the materials for any commercial purpose\n'
                      '• Attempt to reverse engineer any software contained in VitaTrack\n'
                      '• Remove any copyright or other proprietary notations from the materials',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'User Accounts',
                  'This application does not require user accounts or registration. All data is stored locally on your device, and you have full control over your information.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Medical Disclaimer',
                  'VitaTrack is provided "as is" for informational and personal tracking purposes. It is not a substitute for professional medical advice, diagnosis, or treatment. Always consult a physician or qualified health provider with any questions you may have regarding a medical condition or fitness regimen.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Prohibited Uses',
                  'You may not use VitaTrack:\n\n'
                      '• In any way that violates any applicable law or regulation\n'
                      '• To transmit any malicious code or viruses\n'
                      '• To attempt to gain unauthorized access to any portion of the service\n'
                      '• To interfere with or disrupt the service or servers',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'In-App Purchases',
                  'VitaTrack does not currently offer any Pro features or in-app purchases. No payment methods are implemented in this application. All features are available to all users at no cost.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Disclaimer',
                  'The materials on VitaTrack are provided on an "as is" basis. VitaTrack makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Limitations',
                  'In no event shall VitaTrack or its suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use VitaTrack, even if VitaTrack or a VitaTrack authorized representative has been notified orally or in writing of the possibility of such damage.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Modifications',
                  'VitaTrack may revise these terms of service at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.',
                ),
                const SizedBox(height: 24),
                _buildSection(
                  'Contact Information',
                  'If you have any questions about these Terms of Service, please contact us at:\n\n'
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

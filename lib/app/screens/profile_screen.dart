import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../store/app_provider.dart';
import '../../utils/bmi_engine.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appProvider);
    final profile = state.profile;

    if (profile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: const Text('My Health Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(profile),
            const SizedBox(height: 30),
            _buildBmiCard(profile),
            const SizedBox(height: 20),
            _buildStatGrid(profile),
            const SizedBox(height: 30),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(profile) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.bg2,
              child: Icon(Icons.person, size: 60, color: AppColors.accent),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, size: 16, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          profile.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
        ),
        Text(
          profile.mode == 'gym' ? 'Gym Focus' : 'Wellness Focus',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildBmiCard(profile) {
    final bmi = profile.bmi;
    final cat = profile.bmiCategory;
    final label = BmiEngine.getBmiLabel(cat);
    
    Color catColor;
    switch (cat) {
      case 'underweight': catColor = AppColors.bmiUnder; break;
      case 'normal': catColor = AppColors.bmiNormal; break;
      case 'overweight': catColor = AppColors.bmiOver; break;
      case 'obese': catColor = AppColors.bmiObese; break;
      default: catColor = AppColors.bmiNormal;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Body Mass Index (BMI)', style: TextStyle(color: AppColors.textSecondary)),
              Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                bmi.toString(),
                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.white),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: catColor),
                ),
                child: Text(
                  label,
                  style: TextStyle(color: catColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // BMI Scale visualization
          Container(
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(
                colors: [
                  AppColors.bmiUnder,
                  AppColors.bmiNormal,
                  AppColors.bmiOver,
                  AppColors.bmiObese,
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: (bmi / 40).clamp(0.0, 1.0) * 200, // Very rough estimation for UI
                  child: Container(
                    width: 4,
                    height: 8,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid(profile) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      children: [
        _buildStatCard('Height', '${profile.heightCm.toInt()} cm', Icons.height, AppColors.lavender),
        _buildStatCard('Weight', '${profile.currentWeight.toInt()} kg', Icons.monitor_weight_outlined, AppColors.blue),
        _buildStatCard('Goal', '${profile.goalWeight.toInt()} kg', Icons.flag_outlined, AppColors.green),
        _buildStatCard('Step Goal', '${profile.stepGoal.toInt()}', Icons.directions_walk, AppColors.amber),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          _buildSettingsTile('Personal Info', Icons.person_outline),
          _buildSettingsTile('Units (Metric)', Icons.straighten),
          _buildSettingsTile('Notifications', Icons.notifications_none),
          _buildSettingsTile('App Theme', Icons.dark_mode_outlined),
          _buildSettingsTile('Logout', Icons.logout, color: AppColors.red),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(String title, IconData icon, {Color? color}) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textSecondary),
      title: Text(title, style: TextStyle(color: color ?? AppColors.white)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: () {},
    );
  }
}

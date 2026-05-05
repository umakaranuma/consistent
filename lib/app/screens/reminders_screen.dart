import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: const Text('Reminders'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader('Automated Reminders'),
          _buildReminderTile(
            'Hydration',
            'Every 60 mins',
            Icons.water_drop_outlined,
            AppColors.blue,
            true,
          ),
          _buildReminderTile(
            'Step Alert',
            'If inactive for 2 hrs',
            Icons.directions_walk,
            AppColors.green,
            true,
          ),
          const SizedBox(height: 30),
          _buildSectionHeader('Daily Schedule'),
          _buildReminderTile(
            'Breakfast',
            '08:00 AM',
            Icons.breakfast_dining,
            AppColors.amber,
            true,
          ),
          _buildReminderTile(
            'Lunch',
            '01:00 PM',
            Icons.lunch_dining,
            AppColors.amber,
            false,
          ),
          _buildReminderTile(
            'Gym Session',
            '05:30 PM',
            Icons.fitness_center,
            AppColors.accent,
            true,
          ),
          _buildReminderTile(
            'Sleep',
            '11:00 PM',
            Icons.bedtime_outlined,
            AppColors.lavender,
            true,
          ),
          const SizedBox(height: 30),
          _buildAddButton(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildReminderTile(
    String title,
    String time,
    IconData icon,
    Color color,
    bool enabled,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            onChanged: (val) {},
            activeColor: AppColors.accent,
            activeTrackColor: AppColors.accent.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.accent.withOpacity(0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(20),
        // borderDashPattern: const [6, 3], // Note: BorderDashPattern isn't native, using a simpler look
      ),
      child: TextButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add, color: AppColors.accent),
        label: const Text(
          'Add Custom Reminder',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

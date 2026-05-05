import 'package:flutter/material.dart';
import '../../constants/colors.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg0,
      appBar: AppBar(
        title: const Text('Consistency Tracker'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWeekSelector(),
            const SizedBox(height: 30),
            _buildDaySummary('Monday', 'Success', 1.0),
            _buildDaySummary('Tuesday', 'Success', 0.95),
            _buildDaySummary('Wednesday', 'Partial', 0.65),
            _buildDaySummary('Thursday', 'In Progress', 0.4),
            const SizedBox(height: 30),
            _buildStatisticsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekSelector() {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final dates = [4, 5, 6, 7, 8, 9, 10];
    
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(7, (index) {
          bool isToday = index == 3;
          return Column(
            children: [
              Text(days[index], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(height: 8),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.accent : Colors.transparent,
                  shape: BoxShape.circle,
                  border: isToday ? null : Border.all(color: AppColors.bg2),
                ),
                alignment: Alignment.center,
                child: Text(
                  dates[index].toString(),
                  style: TextStyle(
                    color: isToday ? Colors.white : AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: index < 3 ? AppColors.green : (index == 3 ? AppColors.amber : Colors.transparent),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDaySummary(String day, String status, double progress) {
    Color statusColor = status == 'Success' ? AppColors.green : (status == 'Partial' ? AppColors.amber : AppColors.accent);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
                Text(status, style: TextStyle(color: statusColor, fontSize: 12)),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.bg3,
              valueColor: AlwaysStoppedAnimation(statusColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bg1,
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [AppColors.accent.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Performance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Avg Score', value: '92%'),
              _StatItem(label: 'Streak', value: '12 Days'),
              _StatItem(label: 'Perfect', value: '4/7'),
            ],
          ),
        ],
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
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.accent)),
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      ],
    );
  }
}

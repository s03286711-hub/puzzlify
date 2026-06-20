import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/top_notification.dart';

class Mission {
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final String reward;
  final Color themeColor;

  bool get isCompleted => currentProgress >= targetProgress;

  Mission({
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.reward,
    required this.themeColor,
  });
}

class MissionsScreen extends StatefulWidget {
  const MissionsScreen({super.key});

  @override
  State<MissionsScreen> createState() => _MissionsScreenState();
}

class _MissionsScreenState extends State<MissionsScreen> with TickerProviderStateMixin {
  int _totalStars = 0;
  List<Mission> _missions = [];
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _loadMissions();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMissions() async {
    final stars = await StorageService.getTotalStars();
    if (mounted) {
      setState(() {
        _totalStars = stars;
        _missions = [
          Mission(
            title: 'Star Collector',
            description: 'Accumulate 30 Total Stars across any levels.',
            currentProgress: _totalStars,
            targetProgress: 30,
            reward: 'Neon Avatar Border',
            themeColor: const Color(0xFF00D2FF),
          ),
          Mission(
            title: 'Arcade Challenger',
            description: 'Play and win 3 Endless Arcade levels.',
            currentProgress: 2,
            targetProgress: 3,
            reward: '150 Coins',
            themeColor: const Color(0xFFFFD044),
          ),
          Mission(
            title: 'Perfectionist',
            description: 'Earn a 3-star rating on 5 Hard puzzles.',
            currentProgress: 5,
            targetProgress: 5,
            reward: 'Cyber Title',
            themeColor: const Color(0xFFB14DFF),
          ),
          Mission(
            title: 'Daily Warmup',
            description: 'Solve 2 Easy levels without using hints.',
            currentProgress: 0,
            targetProgress: 2,
            reward: '50 Coins',
            themeColor: const Color(0xFF4FDD6F),
          ),
        ];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -50,
            right: -100,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF4F5E).withValues(alpha: 0.12),
                boxShadow: const [BoxShadow(blurRadius: 100, color: Color(0xFFFF4F5E))],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAppBar(),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _missions.length,
                    itemBuilder: (context, index) {
                      return _buildMissionCard(_missions[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 8),
              Text('ACTIVE BOUNTIES', style: AppTheme.heading(24, color: Colors.white)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppTheme.accentLight, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Resets in 14h 22m',
                  style: AppTheme.body(13, color: AppTheme.accentLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final pct = (mission.currentProgress / mission.targetProgress).clamp(0.0, 1.0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.bgCard.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: mission.isCompleted 
                    ? mission.themeColor.withValues(alpha: 0.5) 
                    : Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: mission.isCompleted ? [
                BoxShadow(
                  color: mission.themeColor.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                )
              ] : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(mission.title, style: AppTheme.heading(18, color: Colors.white), overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: mission.themeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.military_tech_rounded, color: mission.themeColor, size: 16),
                          const SizedBox(width: 4),
                          Text(mission.reward, style: AppTheme.body(12, color: mission.themeColor, weight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(mission.description, style: AppTheme.body(14, color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                if (mission.isCompleted)
                  _buildClaimButton(mission.themeColor)
                else
                  _buildProgressBar(mission, pct),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(Mission mission, double pct) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('PROGRESS', style: AppTheme.body(11, color: AppTheme.textSecondary, weight: FontWeight.bold)),
            Text('${mission.currentProgress} / ${mission.targetProgress}', style: AppTheme.heading(14, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 12,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: (pct * 1000).toInt() + 1, // +1 avoids flex 0 crash
                child: Container(
                  decoration: BoxDecoration(
                    color: mission.themeColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(color: mission.themeColor.withValues(alpha: 0.6), blurRadius: 8),
                    ]
                  ),
                ),
              ),
              Expanded(
                flex: ((1.0 - pct) * 1000).toInt() + 1,
                child: const SizedBox(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClaimButton(Color color) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        return GestureDetector(
          onTap: () {
            TopNotification.show(context, 'Reward claimed!', color: color);
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.6 + 0.2 * _pulseCtrl.value),
                  color.withValues(alpha: 0.3 + 0.1 * _pulseCtrl.value),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.4 + 0.2 * _pulseCtrl.value), blurRadius: 15)
              ],
            ),
            child: Center(
              child: Text(
                'CLAIM REWARD',
                style: AppTheme.heading(16, color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

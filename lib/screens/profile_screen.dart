import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/top_notification.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String _userName = 'Player';
  int _totalStars = 0;

  bool _sfxEnabled = true;
  bool _musicEnabled = true;
  bool _hapticsEnabled = true;

  late AnimationController _bgAnimCtrl;

  @override
  void initState() {
    super.initState();
    _bgAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
    _loadData();
  }

  Future<void> _loadData() async {
    final name = await StorageService.getUserName();
    final stars = await StorageService.getTotalStars();
    if (mounted) {
      setState(() {
        _userName = name;
        _totalStars = stars;
      });
    }
  }

  @override
  void dispose() {
    _bgAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _bgAnimCtrl,
            builder: (_, _) => CustomPaint(
              painter: _BgPainter(_bgAnimCtrl.value),
              child: const SizedBox.expand(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                Expanded(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('SETTINGS'),
                      _buildSettingsPanel(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('OFFICIAL STORE'),
                      _buildStorePanel(),
                      const SizedBox(height: 40),
                    ],
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text('HUB', style: AppTheme.heading(22, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTheme.heading(16, color: AppTheme.accentLight),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF00D2FF), Color(0xFFB14DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D2FF).withValues(alpha: 0.4),
                blurRadius: 20,
              ),
            ],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.person_rounded,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Text(_userName, style: AppTheme.heading(26, color: Colors.white)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.starColor.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.star_rounded,
                color: AppTheme.starColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '$_totalStars LIFETIME STARS',
                style: AppTheme.heading(14, color: AppTheme.starColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsPanel() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildToggleRow(
                'Sound Effects',
                Icons.volume_up_rounded,
                _sfxEnabled,
                (val) => setState(() => _sfxEnabled = val),
              ),
              _buildDivider(),
              _buildToggleRow(
                'Music',
                Icons.music_note_rounded,
                _musicEnabled,
                (val) => setState(() => _musicEnabled = val),
              ),
              _buildDivider(),
              _buildToggleRow(
                'Haptic Feedback',
                Icons.vibration_rounded,
                _hapticsEnabled,
                (val) => setState(() => _hapticsEnabled = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() =>
      Divider(height: 1, color: Colors.white.withValues(alpha: 0.05));

  Widget _buildToggleRow(
    String label,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white70, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(label, style: AppTheme.body(16, color: Colors.white)),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: const Color(0xFF4FDD6F),
            inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildStorePanel() {
    return Column(
      children: [
        _buildStoreCard(
          title: 'Unlock Cyber Theme',
          description: 'A brand new neon green visual pack.',
          price: '\$1.99',
          color: const Color(0xFF4FDD6F),
          icon: Icons.palette_rounded,
        ),
        const SizedBox(height: 16),
        _buildStoreCard(
          title: 'Pro Pass',
          description: 'Remove all ads and get 500 bonus coins.',
          price: '\$4.99',
          color: const Color(0xFFFFD044),
          icon: Icons.workspace_premium_rounded,
        ),
        const SizedBox(height: 16),
        _buildStoreCard(
          title: 'Hint Pack',
          description: 'Get 50 hints to solve the toughest expert levels.',
          price: '\$0.99',
          color: const Color(0xFF00D2FF),
          icon: Icons.lightbulb_rounded,
        ),
      ],
    );
  }

  Widget _buildStoreCard({
    required String title,
    required String description,
    required String price,
    required Color color,
    required IconData icon,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.heading(16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: AppTheme.body(13, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () {
                  TopNotification.show(
                    context,
                    'Store currently offline',
                    color: const Color(0xFFFF4F5E),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    price,
                    style: AppTheme.heading(14, color: AppTheme.bgDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Background painter for visual consistency
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 80);
    void drawOrb(Offset center, double r, Color c) {
      paint.color = c;
      canvas.drawCircle(center, r, paint);
    }

    final cx = size.width / 2;
    final cy = size.height / 2;

    final dx1 = cos(t * 2 * pi) * 100;
    final dy1 = sin(t * 2 * pi) * 150;
    drawOrb(
      Offset(cx + dx1, cy + dy1 - 100),
      120,
      const Color(0xFF00D2FF).withValues(alpha: 0.15),
    );

    final dx2 = cos(t * 2 * pi + pi) * 120;
    final dy2 = sin(t * 2 * pi + pi) * 100;
    drawOrb(
      Offset(cx + dx2, cy + dy2 + 100),
      140,
      const Color(0xFFB14DFF).withValues(alpha: 0.15),
    );
  }

  @override
  bool shouldRepaint(covariant _BgPainter old) => old.t != t;
}

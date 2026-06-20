import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class LeaderboardPlayer {
  final String name;
  final int stars;
  final bool isUser;

  LeaderboardPlayer(this.name, this.stars, {this.isUser = false});
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  List<LeaderboardPlayer> _players = [];
  LeaderboardPlayer? _userPlayer;
  int _userRank = 0;

  @override
  void initState() {
    super.initState();
    _generateLeaderboard();
  }

  Future<void> _generateLeaderboard() async {
    final userName = await StorageService.getUserName();
    final userStars = await StorageService.getTotalStars();
    
    _userPlayer = LeaderboardPlayer(userName, userStars, isUser: true);

    final rng = Random(42); // fixed seed so mock leaderboard stays consistent
    final prefixes = ['Neon', 'Flow', 'Puzzle', 'Cyber', 'Star', 'Grid', 'Void', 'Hex'];
    final suffixes = ['Ninja', 'Master', 'God', 'Pro', 'King', 'Lord', 'Walker', 'Hacker'];

    final List<LeaderboardPlayer> mockPlayers = [];
    for (int i = 0; i < 50; i++) {
      final name = '${prefixes[rng.nextInt(prefixes.length)]}${suffixes[rng.nextInt(suffixes.length)]}${rng.nextInt(99)}';
      // Generate stars around 10 to 250 so the user can see progress
      final stars = rng.nextInt(240) + 10;
      mockPlayers.add(LeaderboardPlayer(name, stars));
    }

    // Add some highly competitive players at the top
    mockPlayers.add(LeaderboardPlayer('PuzzlifyDev', 420));
    mockPlayers.add(LeaderboardPlayer('Faker', 380));
    mockPlayers.add(LeaderboardPlayer('TenZ', 350));

    mockPlayers.add(_userPlayer!);

    // Sort descending by stars
    mockPlayers.sort((a, b) => b.stars.compareTo(a.stars));

    final userIdx = mockPlayers.indexOf(_userPlayer!);

    if (mounted) {
      setState(() {
        _players = mockPlayers;
        _userRank = userIdx + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_players.isEmpty) {
      return const Scaffold(
        backgroundColor: AppTheme.bgDark,
        body: Center(child: CircularProgressIndicator(color: AppTheme.accent)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          // Background Glows
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D2FF).withValues(alpha: 0.15),
                boxShadow: const [BoxShadow(blurRadius: 100, color: Color(0xFF00D2FF))],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                const SizedBox(height: 10),
                _buildPodium(),
                const SizedBox(height: 20),
                Expanded(child: _buildList()),
                _buildStickyUserBar(),
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
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Text('GLOBAL RANKING', style: AppTheme.heading(22, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildPodium() {
    if (_players.length < 3) return const SizedBox();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildPodiumSpot(_players[1], 2, 120, const Color(0xFFE0E0E0)), // Silver
        const SizedBox(width: 10),
        _buildPodiumSpot(_players[0], 1, 150, const Color(0xFFFFD044)), // Gold
        const SizedBox(width: 10),
        _buildPodiumSpot(_players[2], 3, 100, const Color(0xFFCD7F32)), // Bronze
      ],
    );
  }

  Widget _buildPodiumSpot(LeaderboardPlayer player, int rank, double height, Color color) {
    final isUser = player.isUser;
    return Column(
      children: [
        Text(
          player.name,
          style: AppTheme.heading(12, color: isUser ? AppTheme.accentLight : Colors.white),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 14),
              const SizedBox(width: 4),
              Text('${player.stars}', style: AppTheme.heading(12, color: Colors.white)),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.6),
                color.withValues(alpha: 0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            '#$rank',
            style: AppTheme.heading(28, color: color),
          ),
        ),
      ],
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _players.length - 3,
      itemBuilder: (ctx, idx) {
        final rank = idx + 4;
        final player = _players[idx + 3];
        return _buildPlayerRow(player, rank);
      },
    );
  }

  Widget _buildPlayerRow(LeaderboardPlayer player, int rank) {
    final isUser = player.isUser;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUser ? AppTheme.accent.withValues(alpha: 0.2) : AppTheme.bgCard.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUser ? AppTheme.accent : Colors.white.withValues(alpha: 0.1),
          width: isUser ? 1.5 : 1.0,
        ),
      ),
      child: ListTile(
        leading: Text(
          '#$rank',
          style: AppTheme.heading(18, color: AppTheme.textSecondary),
        ),
        title: Text(
          player.name,
          style: AppTheme.heading(16, color: isUser ? Colors.white : Colors.white70),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${player.stars}', style: AppTheme.heading(18, color: Colors.white)),
            const SizedBox(width: 6),
            const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyUserBar() {
    // Hide if user is top 3, they are already on the podium
    if (_userPlayer == null || _userRank <= 3) return const SizedBox();
    
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: AppTheme.bgCard.withValues(alpha: 0.8),
            border: Border(
              top: BorderSide(color: AppTheme.accent.withValues(alpha: 0.5), width: 2),
            ),
          ),
          child: Row(
            children: [
              Text('#$_userRank', style: AppTheme.heading(22, color: AppTheme.accentLight)),
              const SizedBox(width: 16),
              Expanded(
                child: Text('YOU', style: AppTheme.heading(18, color: Colors.white)),
              ),
              Text('${_userPlayer!.stars}', style: AppTheme.heading(22, color: Colors.white)),
              const SizedBox(width: 8),
              const Icon(Icons.star_rounded, color: AppTheme.starColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

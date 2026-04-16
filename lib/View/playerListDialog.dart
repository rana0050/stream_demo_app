import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:streaming_demo_app/AppData/local/constant.dart';
import 'package:streaming_demo_app/AppFunctions/appTextFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/showToastFunction.dart';
import 'package:streaming_demo_app/AppServices/streamingFirebaseService.dart';
import 'package:streaming_demo_app/Models/player_model.dart';

class PlayerListDialog extends StatefulWidget {
  const PlayerListDialog({super.key});

  @override
  State<PlayerListDialog> createState() => _PlayerListDialogState();
}

class _PlayerListDialogState extends State<PlayerListDialog> {
  StreamSubscription<DatabaseEvent>? _playersSubscription;
  StreamSubscription<DatabaseEvent>? _inviteSubscription;

  List<PlayerModel> _players = [];
  bool _isLoading = true;

  // Current invite state
  String? _invitedPlayerId;
  String _inviteStatus = 'none'; // pending | accepted | declined | none
  // ignore: unused_field
  int? _joinedAt; // epoch ms — kept for future use
  Timer? _liveTimer;
  int _liveSeconds = 0;

  @override
  void initState() {
    super.initState();
    _listenToPlayers();
    _listenToInvite();
  }

  @override
  void dispose() {
    _playersSubscription?.cancel();
    _inviteSubscription?.cancel();
    _liveTimer?.cancel();
    super.dispose();
  }

  // ─────────────── Firebase: Players ───────────────

  void _listenToPlayers() {
    _playersSubscription = streamingFirebaseService.playersStream.listen(
      (event) {
        if (!mounted) return;
        if (!event.snapshot.exists || event.snapshot.value == null) {
          setState(() {
            _players = [];
            _isLoading = false;
          });
          return;
        }

        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final players = data.entries.map((e) {
            final value = e.value;
            if (value is Map<dynamic, dynamic>) {
              return PlayerModel.fromMap(e.key as String, value);
            }
            return PlayerModel(id: e.key as String, name: value?.toString() ?? 'Unknown');
          }).toList();

          players.sort((a, b) => a.name.compareTo(b.name));

          setState(() {
            _players = players;
            _isLoading = false;
          });
        } catch (e) {
          debugPrint('PlayerListDialog parse error: $e');
          setState(() => _isLoading = false);
        }
      },
      onError: (e) {
        debugPrint('PlayerListDialog Firebase error: $e');
        if (mounted) setState(() => _isLoading = false);
      },
    );
  }

  // ─────────────── Firebase: Invite ───────────────

  void _listenToInvite() {
    _inviteSubscription = streamingFirebaseService.inviteStream.listen(
      (event) {
        if (!mounted) return;
        if (!event.snapshot.exists || event.snapshot.value == null) {
          _clearInviteState();
          return;
        }

        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final playerId = data['invitedPlayerId'] as String?;
          final status = data['status'] as String? ?? 'none';
          final joinedAt = data['joinedAt'] as int?;

          setState(() {
            _invitedPlayerId = playerId;
            _inviteStatus = status;
            _joinedAt = joinedAt;
          });

          // Start live timer when player accepts
          if (status == 'accepted' && joinedAt != null) {
            _startLiveTimer(joinedAt);
            Navigator.pop(context);
          } else if (status != 'accepted') {
            _liveTimer?.cancel();
          }
        } catch (e) {
          debugPrint('PlayerListDialog invite parse error: $e');
        }
      },
    );
  }

  void _clearInviteState() {
    setState(() {
      _invitedPlayerId = null;
      _inviteStatus = 'none';
      _joinedAt = null;
      _liveSeconds = 0;
    });
    _liveTimer?.cancel();
  }

  void _startLiveTimer(int joinedAtMs) {
    _liveTimer?.cancel();
    final joinedAtTime = DateTime.fromMillisecondsSinceEpoch(joinedAtMs);
    _liveSeconds = DateTime.now().difference(joinedAtTime).inSeconds;
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _liveSeconds++);
    });
  }

  // ─────────────── Invite Actions ───────────────

  Future<void> _onInvite(PlayerModel player) async {
    // Only allow invite if no other invite is active
    if (_invitedPlayerId != null && _inviteStatus != 'declined') {
      showToast('Already invited ${_invitedPlayerId == player.id ? player.name : "another player"}');
      return;
    }
    await streamingFirebaseService.invitePlayer(
      playerId: player.id,
      playerName: player.name,
      presenterName: constant.userName,
    );
    showSuccessToast('Invitation sent to ${player.name}');
  }

  Future<void> _onCancelInvite() async {
    await streamingFirebaseService.clearInvite();
    showToast('Invite cancelled');
  }

  String _formatLiveTime(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s'; // ignore: unused_local_variable
  }

  // ─────────────── Build ───────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF13131F),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.w)),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Column(
            children: [
              // Handle
              SizedBox(height: 12.w),
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.w,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                ),
              ),
              SizedBox(height: 20.w),

              // Header
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10.w),
                      ),
                      child: Icon(Icons.people_alt_rounded, color: const Color(0xFF7C3AED), size: 20.w),
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.semiBold18('Viewers', color: Colors.white),
                        AppText.regular12('${_players.length} connected', color: Colors.white38),
                      ],
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close_rounded, color: Colors.white54, size: 22.w),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.w),

              // Active invite banner
              if (_invitedPlayerId != null && _inviteStatus != 'none') _buildInviteBanner(),

              Divider(color: Colors.white.withOpacity(0.07), height: 1),
              SizedBox(height: 8.w),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        ),
                      )
                    : _players.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
                            itemCount: _players.length,
                            itemBuilder: (ctx, i) {
                              final player = _players[i];
                              final isInvited = _invitedPlayerId == player.id;
                              final hasActiveInvite = _invitedPlayerId != null && _inviteStatus != 'declined';

                              return _PlayerTile(
                                player: player,
                                index: i,
                                isInvited: isInvited,
                                inviteStatus: isInvited ? _inviteStatus : 'none',
                                liveSeconds: isInvited && _inviteStatus == 'accepted' ? _liveSeconds : 0,
                                canInvite: !hasActiveInvite || isInvited,
                                onInvite: () => _onInvite(player),
                                onCancel: isInvited ? _onCancelInvite : null,
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInviteBanner() {
    Color bannerColor;
    String bannerText;
    IconData bannerIcon;

    switch (_inviteStatus) {
      case 'pending':
        bannerColor = const Color(0xFFD97706);
        bannerText = 'Waiting for player to accept...';
        bannerIcon = Icons.access_time_rounded;
        break;
      case 'accepted':
        bannerColor = const Color(0xFF059669);
        bannerText = 'Player is live • ${_formatLiveTime(_liveSeconds)}';
        bannerIcon = Icons.fiber_manual_record_rounded;
        break;
      case 'declined':
        bannerColor = Colors.red.shade700;
        bannerText = 'Player declined the invite';
        bannerIcon = Icons.cancel_rounded;
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.w),
      decoration: BoxDecoration(
        color: bannerColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.w),
        border: Border.all(color: bannerColor.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(bannerIcon, color: bannerColor, size: 16.w),
          SizedBox(width: 8.w),
          Expanded(child: AppText.regular13(bannerText, color: bannerColor)),
          if (_inviteStatus == 'declined')
            GestureDetector(
              onTap: _onCancelInvite,
              child: Icon(Icons.close_rounded, color: bannerColor, size: 18.w),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.person_search_rounded, size: 52.w, color: Colors.white12),
        SizedBox(height: 16.w),
        AppText.medium16('No viewers yet', color: Colors.white38),
        SizedBox(height: 8.w),
        AppText.regular13('Players will appear here when they join', color: Colors.white24),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Player tile
// ─────────────────────────────────────────────
class _PlayerTile extends StatelessWidget {
  final PlayerModel player;
  final int index;
  final bool isInvited;
  final String inviteStatus;
  final int liveSeconds;
  final bool canInvite;
  final VoidCallback onInvite;
  final VoidCallback? onCancel;

  const _PlayerTile({
    required this.player,
    required this.index,
    required this.isInvited,
    required this.inviteStatus,
    required this.liveSeconds,
    required this.canInvite,
    required this.onInvite,
    this.onCancel,
  });

  Color _avatarColor(int index) {
    const colors = [
      Color(0xFF7C3AED),
      Color(0xFFDB2777),
      Color(0xFF0891B2),
      Color(0xFF059669),
      Color(0xFFD97706),
    ];
    return colors[index % colors.length];
  }

  String _formatTime(int totalSec) {
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final initial = player.name.isNotEmpty ? player.name[0].toUpperCase() : '?';
    final color = _avatarColor(index);

    // Determine tile highlight when this player is invited
    Color tileBorder = Colors.white.withOpacity(0.07);
    Color tileBg = Colors.white.withOpacity(0.04);
    if (isInvited && inviteStatus == 'accepted') {
      tileBorder = const Color(0xFF059669).withOpacity(0.5);
      tileBg = const Color(0xFF059669).withOpacity(0.07);
    } else if (isInvited && inviteStatus == 'pending') {
      tileBorder = const Color(0xFFD97706).withOpacity(0.5);
      tileBg = const Color(0xFFD97706).withOpacity(0.07);
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 5.w),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.w),
      decoration: BoxDecoration(
        color: tileBg,
        borderRadius: BorderRadius.circular(14.w),
        border: Border.all(color: tileBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: color,
                      fontSize: 18.w,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (isInvited && inviteStatus == 'accepted')
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF13131F), width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          // Name + status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.semiBold14(player.name, color: Colors.white, textAlign: TextAlign.left),
                if (isInvited && inviteStatus == 'accepted')
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
                      ),
                      SizedBox(width: 5.w),
                      AppText.regular12('Live • ${_formatTime(liveSeconds)}', color: const Color(0xFF059669)),
                    ],
                  )
                else
                  Row(
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 5.w),
                      AppText.regular12('Watching live', color: Colors.white30),
                    ],
                  ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          // Action button
          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (isInvited && (inviteStatus == 'pending' || inviteStatus == 'accepted')) {
      // Cancel button
      return GestureDetector(
        onTap: onCancel,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.w),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10.w),
            border: Border.all(color: Colors.red.withOpacity(0.4)),
          ),
          child: Text(
            inviteStatus == 'accepted' ? 'End' : 'Cancel',
            style: TextStyle(
              color: Colors.red,
              fontSize: 12.w,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    // Invite button (greyed out if another player is already invited)
    final enabled = canInvite;
    return GestureDetector(
      onTap: enabled ? onInvite : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.w),
        decoration: BoxDecoration(
          gradient: enabled ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFDB2777)]) : null,
          color: enabled ? null : Colors.white10,
          borderRadius: BorderRadius.circular(10.w),
        ),
        child: Text(
          'Invite',
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white30,
            fontSize: 12.w,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:streaming_demo_app/AppData/local/constant.dart';
import 'package:streaming_demo_app/AppData/remote/streaming_api_service.dart';
import 'package:streaming_demo_app/AppFunctions/appNavigationFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/appTextFunctions.dart';
import 'package:streaming_demo_app/AppFunctions/showToastFunction.dart';
import 'package:streaming_demo_app/AppServices/streamingFirebaseService.dart';
import 'package:streaming_demo_app/View/addNameScreen.dart';
import 'package:streaming_demo_app/View/playerListDialog.dart';
// livekit_token_model imported transitively via streamingApiService

class PresenterScreen extends StatefulWidget {
  const PresenterScreen({super.key});

  @override
  State<PresenterScreen> createState() => _PresenterScreenState();
}

class _PresenterScreenState extends State<PresenterScreen> {
  Room? _room;
  LocalVideoTrack? _localVideoTrack;
  LocalAudioTrack? _localAudioTrack;
  bool _isConnected = false;
  bool _isLive = false;
  bool _isConnecting = false;
  bool _isMicMuted = false;
  bool _isCameraOff = false;

  // ── Invite state ──
  StreamSubscription? _inviteSubscription;
  String? _invitedPlayerId;
  String? _invitedPlayerName;
  String _inviteStatus = 'none';
  // ignore: unused_field
  int? _joinedAtMs;
  Timer? _liveTimer;
  int _liveSeconds = 0;

  // Current invited player remote video track
  VideoTrack? _invitedVideoTrack;
  // ignore: unused_field
  RemoteParticipant? _invitedParticipant;

  // Draggable overlay position
  double _overlayRight = 16;
  double _overlayBottom = 100;

  @override
  void initState() {
    super.initState();
    streamingFirebaseService.initialize();
    _requestPermissionsAndConnect();
    _listenToInvite();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    _inviteSubscription?.cancel();
    _stopAndCleanup();
    super.dispose();
  }

  // ─────────────────────────── Permissions ───────────────────────────

  Future<void> _requestPermissionsAndConnect() async {
    final cameraStatus = await Permission.camera.request();
    final micStatus = await Permission.microphone.request();

    if (cameraStatus.isGranted && micStatus.isGranted) {
      await _connectToRoom();
    } else {
      showToast('Camera and microphone permissions are required');
    }
  }

  // ─────────────────────────── LiveKit Connect ───────────────────────────

  Future<void> _connectToRoom() async {
    if (_isConnecting) return;
    setState(() => _isConnecting = true);

    try {
      final presenterName = constant.userName.isNotEmpty ? constant.userName : 'Presenter';
      final tokenModel = await streamingApiService.getToken(identity: presenterName);

      if (tokenModel == null || tokenModel.token.isEmpty) {
        showErrorToast('Failed to get stream token. Check your connection.');
        setState(() => _isConnecting = false);
        return;
      }

      debugPrint('LiveKit wsUrl: ${tokenModel.wsUrl}');

      _room = Room(
        roomOptions: const RoomOptions(
          adaptiveStream: true,
          dynacast: true,
        ),
      );
      _room!.addListener(_onRoomUpdate);

      await _room!.connect(
        tokenModel.wsUrl,
        tokenModel.token,
        connectOptions: const ConnectOptions(
          autoSubscribe: true,
          rtcConfiguration: RTCConfiguration(
            iceTransportPolicy: RTCIceTransportPolicy.all,
          ),
        ),
      );

      // Create local video + audio tracks
      _localVideoTrack = await LocalVideoTrack.createCameraTrack(
        const CameraCaptureOptions(cameraPosition: CameraPosition.front),
      );
      _localAudioTrack = await LocalAudioTrack.create(const AudioCaptureOptions());

      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });

      showSuccessToast('Connected to room ✓');
    } catch (e) {
      final errType = e.runtimeType.toString();
      final errMsg = e.toString();
      debugPrint('PresenterScreen connect error [$errType]: $errMsg');
      showErrorToast('Connection failed ($errType). Check server.');
      setState(() => _isConnecting = false);
    }
  }

  // ─────────────────────────── Go Live ───────────────────────────

  Future<void> _goLive() async {
    if (_room == null || !_isConnected) {
      showToast('Not connected to room yet');
      return;
    }
    try {
      setState(() => _isLive = true);

      // Publish tracks
      await _room!.localParticipant?.publishVideoTrack(_localVideoTrack!);
      await _room!.localParticipant?.publishAudioTrack(_localAudioTrack!);

      // Update Firebase: presenter is live
      await streamingFirebaseService.setPresenterLive(constant.userName);

      // Wait 3 seconds for stream to stabilize, then call /start-stream
      await Future.delayed(const Duration(seconds: 3));
      final success = await streamingApiService.startStream();
      if (success) {
        showSuccessToast('Stream started 🔴');
      } else {
        showToast('Stream notified (server response pending)');
      }
    } catch (e) {
      debugPrint('PresenterScreen goLive error: $e');
      showErrorToast('Failed to start stream: $e');
      setState(() => _isLive = false);
    }
  }

  // ─────────────────────────── Stop Stream ───────────────────────────

  Future<void> _stopStream() async {
    try {
      await _room?.localParticipant?.unpublishAllTracks();
      await streamingFirebaseService.setPresenterOffline();
      setState(() => _isLive = false);
      showToast('Stream stopped');
      _signOut();
    } catch (e) {
      debugPrint('PresenterScreen stopStream error: $e');
    }
  }

  // ─────────────────────────── Cleanup ───────────────────────────

  Future<void> _stopAndCleanup() async {
    try {
      final success = await streamingApiService.stopStream();
      if (success) {
        showSuccessToast('Stream stopped 🔴');
      } else {
        showToast('Stream notified (server response pending)');
      }
      if (_isLive) {
        await streamingFirebaseService.setPresenterOffline();
      }

      await _localVideoTrack?.stop();
      await _localAudioTrack?.stop();
      _room?.removeListener(_onRoomUpdate);
      await _room?.disconnect();
      _room?.dispose();
    } catch (e) {
      debugPrint('PresenterScreen cleanup error: $e');
    }
  }

  void _onRoomUpdate() {
    if (!mounted) return;
    _updateInvitedParticipantTrack();
    setState(() {});
  }

  // ─────────────────────────── Invite Listener ───────────────────────────

  void _listenToInvite() {
    _inviteSubscription = streamingFirebaseService.inviteStream.listen(
      (event) {
        if (!mounted) return;
        if (!event.snapshot.exists || event.snapshot.value == null) {
          _resetInviteState();
          return;
        }
        try {
          final data = event.snapshot.value as Map<dynamic, dynamic>;
          final playerId = data['invitedPlayerId'] as String?;
          final playerName = data['invitedPlayerName'] as String?;
          final status = data['status'] as String? ?? 'none';
          final joinedAt = data['joinedAt'] as int?;

          setState(() {
            _invitedPlayerId = playerId;
            _invitedPlayerName = playerName;
            _inviteStatus = status;
            _joinedAtMs = joinedAt;
          });

          if (status == 'accepted' && joinedAt != null) {
            _startLiveTimer(joinedAt);
            _updateInvitedParticipantTrack();
          } else if (status != 'accepted') {
            _liveTimer?.cancel();
            setState(() {
              _invitedVideoTrack = null;
              _invitedParticipant = null;
            });
          }
        } catch (e) {
          debugPrint('PresenterScreen invite parse error: $e');
        }
      },
    );
  }

  void _resetInviteState() {
    _liveTimer?.cancel();
    setState(() {
      _invitedPlayerId = null;
      _invitedPlayerName = null;
      _inviteStatus = 'none';
      _joinedAtMs = null;
      _liveSeconds = 0;
      _invitedVideoTrack = null;
      _invitedParticipant = null;
    });
  }

  void _startLiveTimer(int joinedAtMs) {
    _liveTimer?.cancel();
    final joinedAtTime = DateTime.fromMillisecondsSinceEpoch(joinedAtMs);
    _liveSeconds = DateTime.now().difference(joinedAtTime).inSeconds;
    if (_liveSeconds < 0) _liveSeconds = 0;
    _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _liveSeconds++);
    });
  }

  void _updateInvitedParticipantTrack() {
    if (_invitedPlayerId == null || _room == null) return;
    for (final participant in _room!.remoteParticipants.values) {
      if (participant.identity == _invitedPlayerName || participant.identity == _invitedPlayerId) {
        _invitedParticipant = participant;
        // Get first video track (videoTrackPublications is a List)
        for (final pub in participant.videoTrackPublications) {
          if (pub.track != null) {
            setState(() => _invitedVideoTrack = pub.track as VideoTrack?);
            return;
          }
        }
      }
    }
  }

  Future<void> _endInviteSession() async {
    await streamingFirebaseService.clearInvite();
    showToast('Player session ended');
  }

  // ─────────────────────────── Toggle Mic / Camera ───────────────────────────

  Future<void> _toggleMic() async {
    if (_room?.localParticipant == null) return;
    _isMicMuted = !_isMicMuted;
    await _room!.localParticipant!.setMicrophoneEnabled(!_isMicMuted);
    setState(() {});
  }

  Future<void> _toggleCamera() async {
    if (_room?.localParticipant == null) return;
    _isCameraOff = !_isCameraOff;
    await _room!.localParticipant!.setCameraEnabled(!_isCameraOff);
    setState(() {});
  }

  // ─────────────────────────── Players Dialog ───────────────────────────

  void _openPlayerList() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PlayerListDialog(),
    );
  }

  // ─────────────────────────── Sign out ───────────────────────────

  void _signOut() {
    appNavigationMethods.pushAndRemoveUntilNavigation(context, const AddNameScreen());
  }

  String _formatLiveTime(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  // ─────────────────────────── Build ───────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A14),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildBody()),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
      child: Row(
        children: [
          // Live indicator
          if (_isLive)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 7.w, height: 7.w, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  SizedBox(width: 5.w),
                  AppText.semiBold12('LIVE', color: Colors.white),
                ],
              ),
            )
          else
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: AppText.medium12('OFFLINE', color: Colors.white54),
            ),
          const Spacer(),
          AppText.semiBold16(constant.userName.isNotEmpty ? constant.userName : 'Presenter', color: Colors.white),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _signOut,
            child: Icon(Icons.logout_rounded, color: Colors.white54, size: 22.w),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isConnecting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40.w,
              height: 40.w,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
              ),
            ),
            SizedBox(height: 16.w),
            AppText.regular16('Connecting to room...', color: Colors.white54),
          ],
        ),
      );
    }

    if (!_isConnected) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.signal_wifi_off_rounded, size: 56.w, color: Colors.white24),
            SizedBox(height: 16.w),
            AppText.medium18('Not connected', color: Colors.white54),
            SizedBox(height: 8.w),
            AppText.regular14('Check server and try again', color: Colors.white30),
            SizedBox(height: 24.w),
            _GradientButton(
              label: 'Retry',
              icon: Icons.refresh_rounded,
              onTap: _requestPermissionsAndConnect,
            ),
          ],
        ),
      );
    }

    // Video preview with overlay
    return Stack(
      children: [
        // Camera preview
        Positioned.fill(
          child: _localVideoTrack != null && !_isCameraOff
              ? VideoTrackRenderer(_localVideoTrack!)
              : Container(
                  color: const Color(0xFF1A1A2E),
                  child: Center(
                    child: Icon(Icons.videocam_off_rounded, size: 56.w, color: Colors.white24),
                  ),
                ),
        ),

        // View Players button (top-right overlay)
        Positioned(
          top: 16.w,
          right: 16.w,
          child: _IconPill(
            icon: Icons.people_alt_rounded,
            label: 'Players',
            onTap: _openPlayerList,
          ),
        ),

        // ── Invited player video overlay (draggable) ──
        if (_inviteStatus == 'accepted' && _invitedPlayerName != null) _buildInvitedPlayerOverlay(),
      ],
    );
  }

  Widget _buildInvitedPlayerOverlay() {
    return Positioned(
      right: _overlayRight,
      bottom: _overlayBottom,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _overlayRight -= details.delta.dx;
            _overlayBottom -= details.delta.dy;
            // Clamp so it doesn't go off screen
            _overlayRight = _overlayRight.clamp(8, MediaQuery.of(context).size.width - 120.w - 8);
            _overlayBottom = _overlayBottom.clamp(8, MediaQuery.of(context).size.height - 200.w - 8);
          });
        },
        child: Container(
          width: 120.w,
          height: 170.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.w),
            border: Border.all(color: const Color(0xFF059669), width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.w),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Video or placeholder
                _invitedVideoTrack != null
                    ? VideoTrackRenderer(_invitedVideoTrack!)
                    : Container(
                        color: const Color(0xFF1A1A2E),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_rounded, color: Colors.white38, size: 28.w),
                              SizedBox(height: 4.w),
                              Text(
                                _invitedPlayerName?.substring(0, 1).toUpperCase() ?? '?',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 22.w,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                // Top gradient + name
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            _invitedPlayerName ?? '',
                            style: TextStyle(color: Colors.white, fontSize: 9.w, fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom: live timer + end button
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatLiveTime(_liveSeconds),
                          style: TextStyle(color: Colors.white70, fontSize: 9.w),
                        ),
                        GestureDetector(
                          onTap: _endInviteSession,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.w),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(6.w),
                            ),
                            child: Text(
                              'End',
                              style: TextStyle(color: Colors.white, fontSize: 8.w, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F1A),
        border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.07))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mic + Camera toggles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ControlButton(
                icon: _isMicMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                label: _isMicMuted ? 'Unmute' : 'Mute',
                onTap: _isConnected ? _toggleMic : null,
                isActive: !_isMicMuted,
              ),
              SizedBox(width: 20.w),
              // _ControlButton(
              //   icon: _isCameraOff ? Icons.videocam_off_rounded : Icons.videocam_rounded,
              //   label: _isCameraOff ? 'Camera On' : 'Camera Off',
              //   onTap: _isConnected ? _toggleCamera : null,
              //   isActive: !_isCameraOff,
              // ),
              // SizedBox(width: 20.w),
              _ControlButton(
                icon: Icons.people_alt_rounded,
                label: 'Players',
                onTap: _openPlayerList,
                isActive: true,
              ),
            ],
          ),
          SizedBox(height: 16.w),
          // Go Live / Stop
          if (_isConnected)
            _isLive
                ? _GradientButton(
                    label: '⬛  Stop Streaming',
                    onTap: _stopStream,
                    gradientColors: const [Color(0xFFDC2626), Color(0xFF991B1B)],
                  )
                : _GradientButton(
                    label: '🔴  Go Live',
                    onTap: _goLive,
                  ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Reusable widgets
// ─────────────────────────────────────────────

class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final List<Color> gradientColors;

  const _GradientButton({
    required this.label,
    this.onTap,
    this.icon,
    this.gradientColors = const [Color(0xFF7C3AED), Color(0xFFDB2777)],
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 52.w,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradientColors),
          borderRadius: BorderRadius.circular(14.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 20.w),
              SizedBox(width: 8.w),
            ],
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.w,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;

  const _ControlButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: isActive ? Colors.white12 : Colors.red.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? Colors.white24 : Colors.red.withValues(alpha: 0.4)),
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.red, size: 24.w),
          ),
          SizedBox(height: 6.w),
          Text(
            label,
            style: TextStyle(color: Colors.white54, fontSize: 11.w),
          ),
        ],
      ),
    );
  }
}

class _IconPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _IconPill({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.w),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(20.w),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16.w),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12.w)),
          ],
        ),
      ),
    );
  }
}

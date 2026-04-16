// import 'dart:async';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:livekit_client/livekit_client.dart';
// import 'package:video_player/video_player.dart';
// import 'package:streaming_demo_app/AppData/local/constant.dart';
// import 'package:streaming_demo_app/AppData/remote/streaming_api_service.dart';
// import 'package:streaming_demo_app/AppFunctions/appNavigationFunctions.dart';
// import 'package:streaming_demo_app/AppFunctions/appTextFunctions.dart';
// import 'package:streaming_demo_app/AppFunctions/showToastFunction.dart';
// import 'package:streaming_demo_app/AppServices/streamingFirebaseService.dart';
// import 'package:streaming_demo_app/View/addNameScreen.dart';

// class PlayerScreen extends StatefulWidget {
//   const PlayerScreen({super.key});

//   @override
//   State<PlayerScreen> createState() => _PlayerScreenState();
// }

// class _PlayerScreenState extends State<PlayerScreen> with TickerProviderStateMixin {
//   static const String _hlsUrl = 'http://3.6.145.246:8080/hls/test-room.m3u8';

//   // ── HLS ──
//   VideoPlayerController? _videoController;
//   StreamSubscription<DatabaseEvent>? _isLiveSubscription;
//   Timer? _liveSyncTimer; // periodic sync to live edge
//   bool _isMuted = false;

//   bool _isLive = false;
//   bool _playerInitialized = false;
//   String _statusMessage = 'Waiting for presenter to go live...';

//   // ── Invite ──
//   StreamSubscription<DatabaseEvent>? _inviteSubscription;
//   // ignore: unused_field
//   String? _invitedPlayerId;
//   String? _presenterName;
//   // ignore: unused_field
//   String _inviteStatus = 'none';
//   bool _showInviteDialog = false;
//   bool _isJoiningWebRTC = false;

//   // ── WebRTC (when invited) ──
//   Room? _webRtcRoom;
//   LocalVideoTrack? _localVideoTrack;
//   LocalAudioTrack? _localAudioTrack;
//   bool _isInWebRTC = false;
//   // ignore: unused_field
//   int? _joinedAtMs;
//   Timer? _liveTimer;
//   int _liveSeconds = 0;

//   // Presenter's remote video track (shown fullscreen when invited)
//   VideoTrack? _presenterVideoTrack;

//   // Self-view PiP overlay position
//   double _pipRight = 16;
//   double _pipBottom = 120;

//   // ── Viewer-mode WebRTC (non-invited players watch invited player PiP) ──
//   Room? _viewerRoom;
//   VideoTrack? _invitedPlayerVideoTrack; // remote track of the invited player
//   String? _invitedPlayerName; // name pulled from /invite node
//   bool _isViewerConnected = false;

//   // PiP position for the HLS viewer overlay
//   double _viewerPipRight = 16;
//   double _viewerPipBottom = 120;

//   // Animation for invite popup
//   late AnimationController _pulseController;
//   late Animation<double> _pulseAnimation;

//   @override
//   void initState() {
//     super.initState();
//     streamingFirebaseService.initialize();
//     _listenToPresenterStatus();
//     _listenToInvite();

//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 900),
//     )..repeat(reverse: true);
//     _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//   }

//   @override
//   void dispose() {
//     _liveTimer?.cancel();
//     _liveSyncTimer?.cancel();
//     _pulseController.dispose();
//     _isLiveSubscription?.cancel();
//     _inviteSubscription?.cancel();
//     _videoController?.dispose();
//     _disconnectWebRTC();
//     _disconnectViewer();
//     super.dispose();
//   }

//   // ─────────────────────────── Firebase: Presenter Live ───────────────────────────

//   void _listenToPresenterStatus() {
//     _isLiveSubscription = streamingFirebaseService.isLiveStream.listen(
//       (event) {
//         final bool isLive = event.snapshot.value == true;
//         debugPrint('PlayerScreen: isLive = $isLive');

//         if (isLive && !_isLive) {
//           setState(() {
//             _isLive = true;
//             _statusMessage = 'Stream is live!';
//           });
//           if (!_isInWebRTC) _startHlsPlayback();
//         } else if (!isLive && _isLive) {
//           setState(() {
//             _isLive = false;
//             _playerInitialized = false;
//             _statusMessage = 'Stream has ended. Waiting for next session...';
//           });
//           if (!_isInWebRTC) _stopPlayback();
//         } else if (!isLive) {
//           if (mounted) {
//             setState(() => _statusMessage = 'Waiting for presenter to go live...');
//           }
//         }
//       },
//       onError: (e) {
//         debugPrint('PlayerScreen Firebase listener error: $e');
//         if (mounted) setState(() => _statusMessage = 'Connection error. Please restart the app.');
//       },
//     );
//   }

//   // ─────────────────────────── Firebase: Invite ───────────────────────────

//   void _listenToInvite() {
//     _inviteSubscription = streamingFirebaseService.inviteStream.listen(
//       (event) {
//         if (!mounted) return;
//         if (!event.snapshot.exists || event.snapshot.value == null) {
//           if (_isInWebRTC) _leaveWebRTC();
//           _resetInviteState();
//           return;
//         }

//         try {
//           final data = event.snapshot.value as Map<dynamic, dynamic>;
//           final playerId = data['invitedPlayerId'] as String?;
//           final invitedName = data['invitedPlayerName'] as String?;
//           final presenterName = data['presenterName'] as String?;
//           final status = data['status'] as String? ?? 'none';
//           final joinedAt = data['joinedAt'] as int?;

//           // ── This player is the one being invited ──
//           if (playerId == constant.playerId) {
//             setState(() {
//               _invitedPlayerId = playerId;
//               _presenterName = presenterName;
//               _inviteStatus = status;
//               _joinedAtMs = joinedAt;
//               _invitedPlayerName = invitedName;
//             });

//             if (status == 'pending' && !_isInWebRTC) {
//               setState(() => _showInviteDialog = true);
//             } else if (status == 'accepted' && joinedAt != null) {
//               _startLiveTimer(joinedAt);
//             } else if (status == 'declined') {
//               setState(() => _showInviteDialog = false);
//             }
//             return;
//           }

//           // ── This player is a spectator — watch invited player as PiP ──
//           if (_isInWebRTC) _leaveWebRTC();

//           setState(() {
//             _invitedPlayerName = invitedName;
//             _inviteStatus = status;
//           });

//           if (status == 'accepted') {
//             if (!_isViewerConnected) _connectAsViewer();
//           } else {
//             _disconnectViewer();
//           }
//         } catch (e) {
//           debugPrint('PlayerScreen invite parse error: $e');
//         }
//       },
//     );
//   }

//   void _resetInviteState() {
//     _disconnectViewer();
//     setState(() {
//       _invitedPlayerId = null;
//       _presenterName = null;
//       _inviteStatus = 'none';
//       _showInviteDialog = false;
//       _joinedAtMs = null;
//       _liveSeconds = 0;
//       _invitedPlayerName = null;
//     });
//     _liveTimer?.cancel();
//   }

//   void _startLiveTimer(int joinedAtMs) {
//     _liveTimer?.cancel();
//     final joinedAtTime = DateTime.fromMillisecondsSinceEpoch(joinedAtMs);
//     _liveSeconds = DateTime.now().difference(joinedAtTime).inSeconds;
//     if (_liveSeconds < 0) _liveSeconds = 0;
//     _liveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       setState(() => _liveSeconds++);
//     });
//   }

//   // ─────────────── Viewer-mode (watch invited player PiP) ───────────────

//   /// Silently join the LiveKit room as a subscribe-only participant.
//   Future<void> _connectAsViewer() async {
//     try {
//       // Use a unique identity so it doesn't clash with the actual player identity
//       final identity = '${constant.userName}_view';
//       final tokenModel = await streamingApiService.getPlayerToken(identity: identity);
//       if (tokenModel == null || tokenModel.token.isEmpty) {
//         debugPrint('PlayerScreen viewer: failed to get token');
//         return;
//       }

//       _viewerRoom = Room(
//         roomOptions: const RoomOptions(adaptiveStream: true, dynacast: false),
//       );
//       _viewerRoom!.addListener(_onViewerRoomUpdate);

//       await _viewerRoom!.connect(
//         tokenModel.wsUrl,
//         tokenModel.token,
//         connectOptions: const ConnectOptions(
//           autoSubscribe: true,
//           rtcConfiguration: RTCConfiguration(iceTransportPolicy: RTCIceTransportPolicy.all),
//         ),
//       );

//       setState(() => _isViewerConnected = true);
//       _updateInvitedPlayerTrack();
//       debugPrint('PlayerScreen: viewer connected to room');
//     } catch (e) {
//       debugPrint('PlayerScreen viewer connect error: $e');
//     }
//   }

//   void _onViewerRoomUpdate() {
//     if (!mounted) return;
//     _updateInvitedPlayerTrack();
//     setState(() {});
//   }

//   /// Scan remote participants for the invited player's video track.
//   void _updateInvitedPlayerTrack() {
//     if (_viewerRoom == null) return;
//     for (final participant in _viewerRoom!.remoteParticipants.values) {
//       // Match by name (identity set when they joined)
//       if (_invitedPlayerName != null && (participant.identity == _invitedPlayerName || participant.name == _invitedPlayerName)) {
//         for (final pub in participant.videoTrackPublications) {
//           if (pub.track != null) {
//             if (_invitedPlayerVideoTrack != pub.track) {
//               setState(() => _invitedPlayerVideoTrack = pub.track as VideoTrack?);
//             }
//             return;
//           }
//         }
//       }
//     }
//     // Fallback: take first available remote track
//     for (final participant in _viewerRoom!.remoteParticipants.values) {
//       for (final pub in participant.videoTrackPublications) {
//         if (pub.track != null) {
//           if (_invitedPlayerVideoTrack != pub.track) {
//             setState(() => _invitedPlayerVideoTrack = pub.track as VideoTrack?);
//           }
//           return;
//         }
//       }
//     }
//     if (_invitedPlayerVideoTrack != null) {
//       setState(() => _invitedPlayerVideoTrack = null);
//     }
//   }

//   Future<void> _disconnectViewer() async {
//     try {
//       _viewerRoom?.removeListener(_onViewerRoomUpdate);
//       await _viewerRoom?.disconnect();
//       _viewerRoom?.dispose();
//       _viewerRoom = null;
//     } catch (e) {
//       debugPrint('PlayerScreen viewer disconnect error: $e');
//     }
//     if (mounted) {
//       setState(() {
//         _isViewerConnected = false;
//         _invitedPlayerVideoTrack = null;
//       });
//     }
//   }

//   // ─────────────────────────── Invite Actions ───────────────────────────

//   Future<void> _acceptInvite() async {
//     setState(() {
//       _showInviteDialog = false;
//       _isJoiningWebRTC = true;
//     });

//     // Stop HLS
//     _stopPlayback();

//     try {
//       // Get LiveKit token for player
//       final tokenModel = await streamingApiService.getPlayerToken(identity: constant.userName);
//       if (tokenModel == null || tokenModel.token.isEmpty) {
//         showErrorToast('Failed to get WebRTC token');
//         setState(() => _isJoiningWebRTC = false);
//         if (_isLive) _startHlsPlayback(); // fallback to HLS
//         return;
//       }

//       // Connect to LiveKit room
//       _webRtcRoom = Room(
//         roomOptions: const RoomOptions(adaptiveStream: true, dynacast: true),
//       );
//       _webRtcRoom!.addListener(_onWebRtcRoomUpdate);

//       await _webRtcRoom!.connect(
//         tokenModel.wsUrl,
//         tokenModel.token,
//         connectOptions: const ConnectOptions(
//           autoSubscribe: true,
//           rtcConfiguration: RTCConfiguration(iceTransportPolicy: RTCIceTransportPolicy.all),
//         ),
//       );

//       // Publish camera + audio
//       final cameraTrack = await LocalVideoTrack.createCameraTrack(
//         const CameraCaptureOptions(cameraPosition: CameraPosition.front),
//       );
//       final audioTrack = await LocalAudioTrack.create(const AudioCaptureOptions());

//       await _webRtcRoom!.localParticipant?.publishVideoTrack(cameraTrack);
//       await _webRtcRoom!.localParticipant?.publishAudioTrack(audioTrack);

//       _localVideoTrack = cameraTrack;
//       _localAudioTrack = audioTrack;

//       // Tell Firebase the player accepted
//       await streamingFirebaseService.acceptInvite(constant.playerId);

//       setState(() {
//         _isInWebRTC = true;
//         _isJoiningWebRTC = false;
//       });

//       showSuccessToast('You are now live with the presenter!');
//     } catch (e) {
//       debugPrint('PlayerScreen WebRTC join error: $e');
//       showErrorToast('Failed to join session: $e');
//       setState(() => _isJoiningWebRTC = false);
//       // Fallback to HLS
//       if (_isLive) _startHlsPlayback();
//     }
//   }

//   Future<void> _declineInvite() async {
//     setState(() => _showInviteDialog = false);
//     await streamingFirebaseService.declineInvite();
//     showToast('Invite declined');
//   }

//   void _onWebRtcRoomUpdate() {
//     if (!mounted) return;
//     _updatePresenterTrack();
//     setState(() {});
//   }

//   /// Scans remote participants to find the presenter's video track.
//   void _updatePresenterTrack() {
//     if (_webRtcRoom == null) return;
//     for (final participant in _webRtcRoom!.remoteParticipants.values) {
//       for (final pub in participant.videoTrackPublications) {
//         if (pub.track != null) {
//           if (_presenterVideoTrack != pub.track) {
//             setState(() => _presenterVideoTrack = pub.track as VideoTrack?);
//           }
//           return;
//         }
//       }
//     }
//     // No remote track found yet
//     if (_presenterVideoTrack != null) {
//       setState(() => _presenterVideoTrack = null);
//     }
//   }

//   Future<void> _leaveWebRTC() async {
//     await _disconnectWebRTC();
//     setState(() {
//       _isInWebRTC = false;
//       _liveSeconds = 0;
//       _presenterVideoTrack = null;
//     });
//     _liveTimer?.cancel();
//     // Resume HLS if still live
//     if (_isLive) _startHlsPlayback();
//   }

//   Future<void> _disconnectWebRTC() async {
//     try {
//       await _localVideoTrack?.stop();
//       await _localAudioTrack?.stop();
//       _localVideoTrack = null;
//       _localAudioTrack = null;
//       _webRtcRoom?.removeListener(_onWebRtcRoomUpdate);
//       await _webRtcRoom?.disconnect();
//       _webRtcRoom?.dispose();
//       _webRtcRoom = null;
//     } catch (e) {
//       debugPrint('PlayerScreen WebRTC disconnect error: $e');
//     }
//   }

//   // ─────────────────────────── HLS Playback ───────────────────────────

//   Future<void> _startHlsPlayback() async {
//     print("-------------------------------------------------------------------");
//     print("HLS PLAYBACK STARTED");
//     print("-------------------------------------------------------------------");
//     try {
//       _videoController = VideoPlayerController.networkUrl(
//         Uri.parse(_hlsUrl),
//         videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
//         httpHeaders: const {'Connection': 'keep-alive'},
//       );

//       await _videoController!.initialize();

//       // Apply mute state
//       await _videoController!.setVolume(_isMuted ? 0.0 : 1.0);

//       // ── Jump to live edge immediately ──
//       final duration = _videoController!.value.duration;
//       if (duration > Duration.zero) {
//         await _videoController!.seekTo(duration);
//       }

//       await _videoController!.play();

//       if (mounted) setState(() => _playerInitialized = true);

//       // ── Periodic re-sync every 15 s ──
//       _liveSyncTimer?.cancel();
//       _liveSyncTimer = Timer.periodic(const Duration(seconds: 15), (_) {
//         _syncToLiveEdge();
//       });
//     } catch (e) {
//       debugPrint('PlayerScreen HLS init error: $e');
//       if (mounted) {
//         setState(() => _statusMessage = 'Stream loading failed. Retrying...');
//         await Future.delayed(const Duration(seconds: 5));
//         if (_isLive && mounted && !_isInWebRTC) _startHlsPlayback();
//       }
//     }
//   }

//   /// Jump to stream duration (live edge) for minimum latency.
//   void _seekToLiveEdge() {
//     try {
//       final duration = _videoController?.value.duration;
//       if (duration != null && duration > Duration.zero) {
//         _videoController!.seekTo(duration);
//       }
//     } catch (_) {}
//   }

//   /// Re-seek to live edge if drifted more than 8 seconds.
//   void _syncToLiveEdge() {
//     try {
//       if (_videoController == null || !_videoController!.value.isPlaying) return;
//       final duration = _videoController!.value.duration;
//       final position = _videoController!.value.position;
//       if (duration <= Duration.zero) return;
//       final behindMs = duration.inMilliseconds - position.inMilliseconds;
//       debugPrint('HLS: ${behindMs}ms behind live edge');
//       if (behindMs > 8000) {
//         _videoController!.seekTo(duration);
//         debugPrint('HLS: re-synced to live edge');
//       }
//     } catch (_) {}
//   }

//   void _stopPlayback() {
//     _liveSyncTimer?.cancel();
//     _liveSyncTimer = null;
//     _videoController?.dispose();
//     _videoController = null;
//     if (mounted) setState(() => _playerInitialized = false);
//   }

//   void _signOut() {
//     appNavigationMethods.pushAndRemoveUntilNavigation(context, const AddNameScreen());
//   }

//   String _formatLiveTime(int s) {
//     final m = (s ~/ 60).toString().padLeft(2, '0');
//     final sec = (s % 60).toString().padLeft(2, '0');
//     return '$m:$sec';
//   }

//   // ─────────────────────────── Build ───────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A0A14),
//       body: SafeArea(
//         child: Stack(
//           children: [
//             Column(
//               children: [
//                 _buildAppBar(),
//                 Expanded(child: _buildBody()),
//               ],
//             ),

//             // Invite dialog overlay
//             if (_showInviteDialog) _buildInvitationOverlay(),

//             // Joining spinner
//             if (_isJoiningWebRTC) _buildJoiningOverlay(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildAppBar() {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.w),
//       child: Row(
//         children: [
//           AnimatedSwitcher(
//             duration: const Duration(milliseconds: 300),
//             child: _isLive
//                 ? Container(
//                     key: const ValueKey('live'),
//                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(8.w),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           width: 7.w,
//                           height: 7.w,
//                           decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
//                         ),
//                         SizedBox(width: 5.w),
//                         AppText.semiBold12('LIVE', color: Colors.white),
//                       ],
//                     ),
//                   )
//                 : Container(
//                     key: const ValueKey('offline'),
//                     padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.w),
//                     decoration: BoxDecoration(
//                       color: Colors.white12,
//                       borderRadius: BorderRadius.circular(8.w),
//                     ),
//                     child: AppText.medium12('WAITING', color: Colors.white54),
//                   ),
//           ),
//           const Spacer(),
//           // "You are live" badge when in WebRTC
//           if (_isInWebRTC) ...[
//             Container(
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF059669).withOpacity(0.2),
//                 borderRadius: BorderRadius.circular(8.w),
//                 border: Border.all(color: const Color(0xFF059669).withOpacity(0.5)),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(Icons.videocam_rounded, color: const Color(0xFF059669), size: 12.w),
//                   SizedBox(width: 4.w),
//                   Text(
//                     'ON AIR • ${_formatLiveTime(_liveSeconds)}',
//                     style: TextStyle(color: const Color(0xFF059669), fontSize: 10.w, fontWeight: FontWeight.bold),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(width: 8.w),
//           ],
//           AppText.semiBold16(
//             constant.userName.isNotEmpty ? constant.userName : 'Player',
//             color: Colors.white,
//           ),
//           SizedBox(width: 12.w),
//           GestureDetector(
//             onTap: _signOut,
//             child: Icon(Icons.logout_rounded, color: Colors.white54, size: 22.w),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBody() {
//     // WebRTC mode — show self preview
//     if (_isInWebRTC) {
//       return _buildWebRTCView();
//     }

//     if (_isLive && _playerInitialized && _videoController != null) {
//       return Stack(
//         alignment: Alignment.center,
//         children: [
//           // ── MAIN: Raw VideoPlayer — lowest latency, no wrapper overhead ──
//           AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!)),

//           // ── Top-right: mute toggle ──
//           Positioned(
//             top: 12.w,
//             right: 12.w,
//             child: GestureDetector(
//               onTap: () {
//                 setState(() => _isMuted = !_isMuted);
//                 _videoController!.setVolume(_isMuted ? 0.0 : 1.0);
//               },
//               child: Container(
//                 padding: EdgeInsets.all(8.w),
//                 decoration: BoxDecoration(
//                   color: Colors.black54,
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
//                   color: Colors.white,
//                   size: 18.w,
//                 ),
//               ),
//             ),
//           ),

//           // ── PiP: Invited player's video (center-right overlay) ──
//           // if (_invitedPlayerVideoTrack != null) _buildWatcherInviteePiP(),
//         ],
//       );
//     }

//     if (_isLive && !_playerInitialized) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             SizedBox(
//               width: 40.w,
//               height: 40.w,
//               child: const CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
//               ),
//             ),
//             SizedBox(height: 16.w),
//             AppText.regular16('Loading stream...', color: Colors.white54),
//           ],
//         ),
//       );
//     }

//     return _buildWaitingState();
//   }

//   // WebRTC view — presenter fullscreen + self PiP overlay
//   Widget _buildWebRTCView() {
//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         // ── MAIN: Presenter's video (fullscreen background) ──
//         _presenterVideoTrack != null
//             ? VideoTrackRenderer(_presenterVideoTrack!)
//             : Container(
//                 color: const Color(0xFF0A0A14),
//                 child: Center(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       SizedBox(
//                         width: 36.w,
//                         height: 36.w,
//                         child: const CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
//                         ),
//                       ),
//                       SizedBox(height: 14.w),
//                       AppText.regular14('Connecting to presenter...', color: Colors.white38),
//                     ],
//                   ),
//                 ),
//               ),

//         // ── PiP: Player's own self-view (draggable, center-right) ──
//         Positioned(
//           right: _pipRight,
//           bottom: _pipBottom,
//           child: GestureDetector(
//             onPanUpdate: (details) {
//               setState(() {
//                 _pipRight -= details.delta.dx;
//                 _pipBottom -= details.delta.dy;
//                 final screenW = MediaQuery.of(context).size.width;
//                 final screenH = MediaQuery.of(context).size.height;
//                 _pipRight = _pipRight.clamp(8.0, screenW - 120.w - 8);
//                 _pipBottom = _pipBottom.clamp(8.0, screenH - 200.w - 8);
//               });
//             },
//             child: Container(
//               width: 120.w,
//               height: 170.w,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(16.w),
//                 border: Border.all(color: const Color(0xFF7C3AED), width: 2),
//                 boxShadow: [
//                   BoxShadow(
//                     color: const Color(0xFF7C3AED).withOpacity(0.4),
//                     blurRadius: 12,
//                     spreadRadius: 2,
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(14.w),
//                 child: Stack(
//                   fit: StackFit.expand,
//                   children: [
//                     // Self camera feed
//                     _localVideoTrack != null
//                         ? VideoTrackRenderer(_localVideoTrack!)
//                         : Container(
//                             color: const Color(0xFF1A1A2E),
//                             child: Center(
//                               child: Icon(Icons.videocam_off_rounded, color: Colors.white24, size: 28.w),
//                             ),
//                           ),

//                     // Top label
//                     Positioned(
//                       top: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.topCenter,
//                             end: Alignment.bottomCenter,
//                             colors: [
//                               Colors.black.withOpacity(0.7),
//                               Colors.transparent,
//                             ],
//                           ),
//                         ),
//                         child: Row(
//                           children: [
//                             Container(
//                               width: 6.w,
//                               height: 6.w,
//                               decoration: const BoxDecoration(
//                                 color: Color(0xFF7C3AED),
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                             SizedBox(width: 4.w),
//                             Text(
//                               'You',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 9.w,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),

//         // ── Bottom bar: live info + Leave button ──
//         Positioned(
//           bottom: 20.w,
//           left: 20.w,
//           right: 20.w,
//           child: Container(
//             padding: EdgeInsets.all(14.w),
//             decoration: BoxDecoration(
//               color: Colors.black.withOpacity(0.6),
//               borderRadius: BorderRadius.circular(16.w),
//               border: Border.all(color: const Color(0xFF059669).withOpacity(0.4)),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   width: 10.w,
//                   height: 10.w,
//                   decoration: const BoxDecoration(color: Color(0xFF059669), shape: BoxShape.circle),
//                 ),
//                 SizedBox(width: 10.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     AppText.semiBold14('You are on air', color: Colors.white),
//                     AppText.regular12(
//                       'Live with ${_presenterName ?? "Presenter"} • ${_formatLiveTime(_liveSeconds)}',
//                       color: Colors.white38,
//                     ),
//                   ],
//                 ),
//                 const Spacer(),
//                 GestureDetector(
//                   onTap: () async {
//                     await _leaveWebRTC();
//                     await streamingFirebaseService.clearInvite();
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.w),
//                     decoration: BoxDecoration(
//                       color: Colors.red.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10.w),
//                       border: Border.all(color: Colors.red.withOpacity(0.5)),
//                     ),
//                     child: Text(
//                       'Leave',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 12.w,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   /// Draggable PiP overlay shown to non-invited players while watching HLS.
//   /// Shows the invited player's live video at center-right of the screen.

//   // Widget _buildWatcherInviteePiP() {
//   //   return Positioned(
//   //     right: _viewerPipRight,
//   //     bottom: _viewerPipBottom,
//   //     child: GestureDetector(
//   //       onPanUpdate: (details) {
//   //         setState(() {
//   //           _viewerPipRight -= details.delta.dx;
//   //           _viewerPipBottom -= details.delta.dy;
//   //           final screenW = MediaQuery.of(context).size.width;
//   //           final screenH = MediaQuery.of(context).size.height;
//   //           _viewerPipRight = _viewerPipRight.clamp(8.0, screenW - 120.w - 8);
//   //           _viewerPipBottom = _viewerPipBottom.clamp(8.0, screenH - 200.w - 8);
//   //         });
//   //       },
//   //       child: Container(
//   //         width: 120.w,
//   //         height: 170.w,
//   //         decoration: BoxDecoration(
//   //           borderRadius: BorderRadius.circular(16.w),
//   //           border: Border.all(color: const Color(0xFF059669), width: 2),
//   //           boxShadow: [
//   //             BoxShadow(
//   //               color: const Color(0xFF059669).withOpacity(0.35),
//   //               blurRadius: 12,
//   //               spreadRadius: 2,
//   //             ),
//   //           ],
//   //         ),
//   //         child: ClipRRect(
//   //           borderRadius: BorderRadius.circular(14.w),
//   //           child: Stack(
//   //             fit: StackFit.expand,
//   //             children: [
//   //               // Invited player's video feed
//   //               VideoTrackRenderer(_invitedPlayerVideoTrack!),

//   //               // Top gradient + name label
//   //               Positioned(
//   //                 top: 0,
//   //                 left: 0,
//   //                 right: 0,
//   //                 child: Container(
//   //                   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
//   //                   decoration: BoxDecoration(
//   //                     gradient: LinearGradient(
//   //                       begin: Alignment.topCenter,
//   //                       end: Alignment.bottomCenter,
//   //                       colors: [
//   //                         Colors.black.withOpacity(0.7),
//   //                         Colors.transparent,
//   //                       ],
//   //                     ),
//   //                   ),
//   //                   child: Row(
//   //                     children: [
//   //                       Container(
//   //                         width: 6.w,
//   //                         height: 6.w,
//   //                         decoration: const BoxDecoration(
//   //                           color: Color(0xFF059669),
//   //                           shape: BoxShape.circle,
//   //                         ),
//   //                       ),
//   //                       SizedBox(width: 4.w),
//   //                       Flexible(
//   //                         child: Text(
//   //                           _invitedPlayerName ?? 'Guest',
//   //                           overflow: TextOverflow.ellipsis,
//   //                           style: TextStyle(
//   //                             color: Colors.white,
//   //                             fontSize: 9.w,
//   //                             fontWeight: FontWeight.w600,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //               ),

//   //               // Bottom gradient + LIVE badge
//   //               Positioned(
//   //                 bottom: 0,
//   //                 left: 0,
//   //                 right: 0,
//   //                 child: Container(
//   //                   padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 5.w),
//   //                   decoration: BoxDecoration(
//   //                     gradient: LinearGradient(
//   //                       begin: Alignment.bottomCenter,
//   //                       end: Alignment.topCenter,
//   //                       colors: [
//   //                         Colors.black.withOpacity(0.7),
//   //                         Colors.transparent,
//   //                       ],
//   //                     ),
//   //                   ),
//   //                   child: Row(
//   //                     children: [
//   //                       Container(
//   //                         padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
//   //                         decoration: BoxDecoration(
//   //                           color: Colors.red,
//   //                           borderRadius: BorderRadius.circular(4.w),
//   //                         ),
//   //                         child: Text(
//   //                           'LIVE',
//   //                           style: TextStyle(
//   //                             color: Colors.white,
//   //                             fontSize: 7.w,
//   //                             fontWeight: FontWeight.bold,
//   //                           ),
//   //                         ),
//   //                       ),
//   //                     ],
//   //                   ),
//   //                 ),
//   //               ),
//   //             ],
//   //           ),
//   //         ),
//   //       ),
//   //     ),
//   //   );
//   // }

//   // Widget _buildStreamInfo() {
//   //   return Container(
//   //     padding: EdgeInsets.all(16.w),
//   //     decoration: BoxDecoration(
//   //       color: Colors.white.withOpacity(0.05),
//   //       borderRadius: BorderRadius.circular(16.w),
//   //       border: Border.all(color: Colors.white12),
//   //     ),
//   //     child: Row(
//   //       children: [
//   //         Container(
//   //           width: 10.w,
//   //           height: 10.w,
//   //           decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
//   //         ),
//   //         SizedBox(width: 10.w),
//   //         Column(
//   //           crossAxisAlignment: CrossAxisAlignment.start,
//   //           children: [
//   //             AppText.semiBold14('Live Stream', color: Colors.white),
//   //             AppText.regular12('test-room • HLS', color: Colors.white38),
//   //           ],
//   //         ),
//   //         const Spacer(),
//   //         Icon(Icons.hd_rounded, color: Colors.white38, size: 20.w),
//   //       ],
//   //     ),
//   //   );
//   // }

//   Widget _buildWaitingState() {
//     return Center(
//       child: Padding(
//         padding: EdgeInsets.symmetric(horizontal: 32.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0.9, end: 1.1),
//               duration: const Duration(milliseconds: 900),
//               curve: Curves.easeInOut,
//               builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
//               child: Container(
//                 width: 100.w,
//                 height: 100.w,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: const Color(0xFF7C3AED).withOpacity(0.15),
//                   border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4), width: 2),
//                 ),
//                 child: Icon(Icons.live_tv_rounded, size: 44.w, color: const Color(0xFF7C3AED)),
//               ),
//             ),
//             SizedBox(height: 28.w),
//             AppText.semiBold18(_statusMessage, color: Colors.white70, textAlign: TextAlign.center),
//             SizedBox(height: 12.w),
//             AppText.regular14(
//               'The stream will automatically start\nwhen the presenter goes live.',
//               color: Colors.white30,
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 32.w),
//             const _PulsingDots(),
//           ],
//         ),
//       ),
//     );
//   }

//   // ─────────────────────────── Invitation Overlay ───────────────────────────

//   Widget _buildInvitationOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.75),
//       child: Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 32.w),
//           child: Container(
//             padding: EdgeInsets.all(28.w),
//             decoration: BoxDecoration(
//               color: const Color(0xFF13131F),
//               borderRadius: BorderRadius.circular(24.w),
//               border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5), width: 1.5),
//               boxShadow: [
//                 BoxShadow(
//                   color: const Color(0xFF7C3AED).withOpacity(0.3),
//                   blurRadius: 30,
//                   spreadRadius: 5,
//                 ),
//               ],
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 // Pulsing icon
//                 ScaleTransition(
//                   scale: _pulseAnimation,
//                   child: Container(
//                     width: 80.w,
//                     height: 80.w,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF7C3AED).withOpacity(0.5),
//                           blurRadius: 20,
//                           spreadRadius: 3,
//                         ),
//                       ],
//                     ),
//                     child: Icon(Icons.videocam_rounded, color: Colors.white, size: 36.w),
//                   ),
//                 ),
//                 SizedBox(height: 24.w),

//                 AppText.semiBold18('You\'re Invited!', color: Colors.white),
//                 SizedBox(height: 8.w),
//                 AppText.regular14(
//                   '${_presenterName ?? "The Presenter"} is inviting you\nto join their live stream.',
//                   color: Colors.white54,
//                   textAlign: TextAlign.center,
//                 ),
//                 SizedBox(height: 28.w),

//                 // Join button
//                 GestureDetector(
//                   onTap: _acceptInvite,
//                   child: Container(
//                     width: double.infinity,
//                     height: 50.w,
//                     decoration: BoxDecoration(
//                       gradient: const LinearGradient(
//                         colors: [Color(0xFF7C3AED), Color(0xFFDB2777)],
//                       ),
//                       borderRadius: BorderRadius.circular(14.w),
//                       boxShadow: [
//                         BoxShadow(
//                           color: const Color(0xFF7C3AED).withOpacity(0.4),
//                           blurRadius: 12,
//                           offset: const Offset(0, 4),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.videocam_rounded, color: Colors.white, size: 20.w),
//                         SizedBox(width: 8.w),
//                         Text(
//                           'Join Now',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16.w,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 12.w),

//                 // Decline button
//                 GestureDetector(
//                   onTap: _declineInvite,
//                   child: Container(
//                     width: double.infinity,
//                     height: 46.w,
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.05),
//                       borderRadius: BorderRadius.circular(14.w),
//                       border: Border.all(color: Colors.white12),
//                     ),
//                     child: Center(
//                       child: Text(
//                         'Decline',
//                         style: TextStyle(
//                           color: Colors.white38,
//                           fontSize: 14.w,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildJoiningOverlay() {
//     return Container(
//       color: Colors.black.withOpacity(0.75),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             SizedBox(
//               width: 48.w,
//               height: 48.w,
//               child: const CircularProgressIndicator(
//                 strokeWidth: 2.5,
//                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
//               ),
//             ),
//             SizedBox(height: 20.w),
//             AppText.semiBold16('Joining session...', color: Colors.white),
//             SizedBox(height: 8.w),
//             AppText.regular13('Starting your camera & microphone', color: Colors.white38),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ─────────────────────────────────────────────
// // Animated pulsing dots
// // ─────────────────────────────────────────────
// class _PulsingDots extends StatefulWidget {
//   const _PulsingDots();

//   @override
//   State<_PulsingDots> createState() => _PulsingDotsState();
// }

// class _PulsingDotsState extends State<_PulsingDots> with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: List.generate(3, (i) {
//         final delay = i * 0.2;
//         return AnimatedBuilder(
//           animation: _controller,
//           builder: (_, __) {
//             final t = (((_controller.value - delay) % 1.0 + 1.0) % 1.0);
//             final opacity = t < 0.5 ? t * 2 : 2 - t * 2;
//             return Padding(
//               padding: EdgeInsets.symmetric(horizontal: 4.w),
//               child: Opacity(
//                 opacity: opacity.clamp(0.2, 1.0),
//                 child: Container(
//                   width: 8.w,
//                   height: 8.w,
//                   decoration: const BoxDecoration(color: Color(0xFF7C3AED), shape: BoxShape.circle),
//                 ),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }
// }

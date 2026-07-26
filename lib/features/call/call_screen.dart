import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';

import '../../core/app_constants.dart';
import 'agora_call_controller.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, required this.controller, required this.isHost});

  final AgoraCallController controller;
  final bool isHost;

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final AgoraCallController _controller;
  String? _lastStatusMessage;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _lastStatusMessage = _controller.statusMessage;
    _controller.addListener(_handleUserNotifications);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleUserNotifications);
    super.dispose();
  }

  void _handleUserNotifications() {
    if (!mounted) {
      return;
    }

    final message = _controller.statusMessage;
    if (message == null || message == _lastStatusMessage) {
      return;
    }
    _lastStatusMessage = message;

    final isJoinOrLeaveNotice =
        message.contains('انضم مشارك') || message.contains('غادر مشارك');
    if (!isJoinOrLeaveNotice) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _leaveCall() async {
    await _controller.leaveChannel();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: () async {
        await _leaveCall();
        return false;
      },
      child: Scaffold(
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final hasRemoteVideo =
                _controller.remoteUid != null && _controller.remoteUid != 0;
            final isWaitingForRemote = !hasRemoteVideo;

            return Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF02111B), Color(0xFF081624)],
                    ),
                  ),
                ),
                if (hasRemoteVideo && AppConstants.hasValidAgoraConfig)
                  Positioned.fill(
                    child: AgoraVideoView(
                      controller: VideoViewController.remote(
                        rtcEngine: _controller.engine,
                        canvas: VideoCanvas(
                          uid: _controller.remoteUid!,
                          renderMode: RenderModeType.renderModeHidden,
                        ),
                        connection: RtcConnection(
                          channelId: _controller.channelName,
                        ),
                      ),
                    ),
                  )
                else
                  Positioned.fill(
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.08),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: isWaitingForRemote
                                      ? [
                                          const Color(0xFF31D0AA),
                                          const Color(0xFF6EE7FF),
                                        ]
                                      : [
                                          const Color(0xFFFFC857),
                                          const Color(0xFFFF7A59),
                                        ],
                                ),
                              ),
                              child: Icon(
                                isWaitingForRemote
                                    ? Icons.people_alt_outlined
                                    : Icons.videocam_off_outlined,
                                size: 42,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              isWaitingForRemote
                                  ? 'في انتظار المشارك الآخر'
                                  : 'جارٍ تجهيز الفيديو...',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'القناة: ${_controller.channelName}',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _GlassChip(
                            icon: widget.isHost
                                ? Icons.workspace_premium_outlined
                                : Icons.person_outline,
                            label: widget.isHost ? 'المضيف' : 'مشترك',
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _GlassChip(
                                icon: Icons.meeting_room_outlined,
                                label: _controller.channelName,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 120,
                  child: _LocalPreview(controller: _controller),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 20,
                  child: SafeArea(
                    top: false,
                    child: _BottomToolbar(
                      controller: _controller,
                      onEndCall: _leaveCall,
                    ),
                  ),
                ),
                if (_controller.errorMessage != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 156,
                    child: Center(
                      child: Text(
                        _controller.errorMessage!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.errorContainer,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomToolbar extends StatelessWidget {
  const _BottomToolbar({required this.controller, required this.onEndCall});

  final AgoraCallController controller;
  final Future<void> Function() onEndCall;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.50),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _ControlButton(
              icon: controller.isMuted
                  ? Icons.mic_off_rounded
                  : Icons.mic_none_rounded,
              label: controller.isMuted ? 'إلغاء كتم' : 'كتم',
              onTap: controller.toggleMute,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ControlButton(
              icon: controller.isVideoEnabled
                  ? Icons.videocam_rounded
                  : Icons.videocam_off_rounded,
              label: controller.isVideoEnabled
                  ? 'تشغيل الفيديو'
                  : 'إيقاف الفيديو',
              onTap: controller.toggleVideo,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ControlButton(
              icon: Icons.cameraswitch_rounded,
              label: 'تبديل',
              onTap: controller.switchCamera,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _ControlButton(
              icon: Icons.call_end_rounded,
              label: 'إنهاء',
              backgroundColor: const Color(0xFFE25555),
              onTap: onEndCall,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final buttonColor = backgroundColor ?? Colors.white.withOpacity(0.08);
    return Material(
      color: buttonColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.40),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 16), const SizedBox(width: 8), Text(label)],
      ),
    );
  }
}

class _LocalPreview extends StatelessWidget {
  const _LocalPreview({required this.controller});

  final AgoraCallController controller;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 120,
        height: 180,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.30),
          border: Border.all(color: Colors.white.withOpacity(0.06)),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 10,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: controller.isVideoEnabled
            ? AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: controller.engine,
                  canvas: const VideoCanvas(
                    uid: 0,
                    renderMode: RenderModeType.renderModeHidden,
                  ),
                ),
              )
            : const Center(child: Icon(Icons.videocam_off_outlined)),
      ),
    );
  }
}

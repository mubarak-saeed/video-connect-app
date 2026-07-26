import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_constants.dart';

class AgoraCallController extends ChangeNotifier {
  AgoraCallController() : _engine = createAgoraRtcEngine();

  final RtcEngine _engine;

  bool _initialized = false;
  bool _joined = false;
  bool _isMuted = false;
  bool _isVideoEnabled = true;
  bool _isFrontCamera = true;
  bool _isBusy = false;
  bool _isDisposed = false;
  int? _remoteUid;
  String _channelName = AppConstants.defaultChannelName;
  String? _statusMessage;
  String? _errorMessage;

  RtcEngine get engine => _engine;
  bool get initialized => _initialized;
  bool get joined => _joined;
  bool get isMuted => _isMuted;
  bool get isVideoEnabled => _isVideoEnabled;
  bool get isFrontCamera => _isFrontCamera;
  bool get isBusy => _isBusy;
  int? get remoteUid => _remoteUid;
  String get channelName => _channelName;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  bool get hasValidAgoraConfig => AppConstants.hasValidAgoraConfig;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _ensurePermissions();
    await _engine.initialize(RtcEngineContext(appId: AppConstants.agoraAppId));

    // register event handlers after engine has been initialized
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          _joined = true;
          _statusMessage = null;
          _errorMessage = null;
          _isBusy = false;
          print('Agora: onJoinChannelSuccess channel=${connection.channelId}');
          _notifyIfActive();
        },
        onUserJoined: (connection, remoteUid, elapsed) {
          print(
            'Agora: onUserJoined uid=$remoteUid channel=${connection.channelId}',
          );
          _remoteUid = remoteUid;
          _statusMessage = 'انضم مشارك إلى ${connection.channelId}';
          _notifyIfActive();
        },
        onFirstRemoteVideoDecoded: (connection, remoteUid, width, height, elapsed) {
          print(
            'Agora: onFirstRemoteVideoDecoded uid=$remoteUid size=${width}x$height',
          );
        },
        onFirstRemoteVideoFrame: (connection, remoteUid, width, height, elapsed) {
          print(
            'Agora: onFirstRemoteVideoFrame uid=$remoteUid size=${width}x$height',
          );
        },
        onRemoteVideoStateChanged: (connection, remoteUid, state, reason, elapsed) {
          print(
            'Agora: onRemoteVideoStateChanged uid=$remoteUid state=$state reason=$reason',
          );
        },
        onUserOffline: (connection, remoteUid, reason) {
          print('Agora: onUserOffline uid=$remoteUid reason=$reason');
          if (_remoteUid == remoteUid) {
            _remoteUid = null;
          }
          _statusMessage = 'غادر مشارك الغرفة';
          _notifyIfActive();
        },
        onConnectionStateChanged: (connection, state, reason) {
          print(
            'Agora: onConnectionStateChanged state=$state reason=$reason channel=${connection.channelId}',
          );
        },
        onLeaveChannel: (connection, stats) {
          _joined = false;
          _remoteUid = null;
          _statusMessage = null;
          _isBusy = false;
          print('Agora: onLeaveChannel channel=${connection.channelId}');
          _notifyIfActive();
        },
        onError: (error, message) {
          _errorMessage = 'خطأ Agora: $message';
          _isBusy = false;
          print('Agora: onError code=$error message=$message');
          _notifyIfActive();
        },
        onPermissionError: (permissionType) {
          _errorMessage = 'لم يتم منح الأذونات من النظام';
          _isBusy = false;
          print('Agora: onPermissionError type=$permissionType');
          _notifyIfActive();
        },
      ),
    );
    await _engine.enableVideo();
    await _engine.enableAudio();
    await _engine.setChannelProfile(
      ChannelProfileType.channelProfileCommunication,
    );
    await _engine.setDefaultAudioRouteToSpeakerphone(true);

    _initialized = true;
    _statusMessage = null;
    _notifyIfActive();
  }

  Future<void> joinChannel({
    required String channelName,
    required bool asHost,
  }) async {
    if (_isBusy) {
      return;
    }

    final trimmedChannelName = channelName.trim();
    if (trimmedChannelName.isEmpty) {
      throw StateError('اسم القناة مطلوب');
    }
    if (!hasValidAgoraConfig) {
      throw StateError('اضف معرف تطبيق Agora في lib/core/app_constants.dart');
    }

    _isBusy = true;
    _errorMessage = null;
    _statusMessage = null;
    _channelName = trimmedChannelName;
    _notifyIfActive();

    try {
      await initialize();
      await _engine.startPreview();
      await _engine.joinChannel(
        token: AppConstants.agoraToken.trim(),
        channelId: trimmedChannelName,
        uid: 0,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileCommunication,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
          autoSubscribeAudio: true,
          autoSubscribeVideo: true,
          publishMicrophoneTrack: true,
          publishCameraTrack: true,
          enableAudioRecordingOrPlayout: true,
        ),
      );
      _isFrontCamera = true;
      _isMuted = false;
      _isVideoEnabled = true;
    } on Object catch (error) {
      _errorMessage = error.toString();
      _isBusy = false;
      rethrow;
    } finally {
      _notifyIfActive();
    }
  }

  Future<void> toggleMute() async {
    if (!_initialized) {
      return;
    }

    _isMuted = !_isMuted;
    _notifyIfActive();
    await _engine.muteLocalAudioStream(_isMuted);
  }

  Future<void> toggleVideo() async {
    if (!_initialized) {
      return;
    }

    _isVideoEnabled = !_isVideoEnabled;
    _notifyIfActive();
    await _engine.muteLocalVideoStream(!_isVideoEnabled);
    if (_isVideoEnabled) {
      await _engine.startPreview();
    } else {
      await _engine.stopPreview();
    }
  }

  Future<void> switchCamera() async {
    if (!_initialized || !_isVideoEnabled) {
      return;
    }

    await _engine.switchCamera();
    _isFrontCamera = !_isFrontCamera;
    _notifyIfActive();
  }

  Future<void> leaveChannel() async {
    if (!_initialized) {
      return;
    }

    _isBusy = true;
    _notifyIfActive();

    await _engine.stopPreview();
    await _engine.leaveChannel();

    _isBusy = false;
    _notifyIfActive();
  }

  Future<void> _ensurePermissions() async {
    final cameraStatus = await Permission.camera.request();
    final microphoneStatus = await Permission.microphone.request();

    if (!cameraStatus.isGranted || !microphoneStatus.isGranted) {
      throw StateError('تتطلب الأذونات الكاميرا والميكروفون');
    }
  }

  void _notifyIfActive() {
    if (_isDisposed) {
      return;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    if (_initialized) {
      _engine.release();
    }
    super.dispose();
  }
}

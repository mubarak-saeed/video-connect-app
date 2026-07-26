class AppConstants {
  const AppConstants._();

  static const String appName = 'V-Connect';
  static const String appTagline =
      'إجراء مكالمات فيديو وصوت مباشرة بجودة عالية';
  static const String agoraAppId =  'YOUR_AGORA_APP_ID';
  static const String agoraToken = 'YOUR_AGORA_TOKEN';
  static const String defaultChannelName = 'vconnect-room';

  static bool get hasValidAgoraConfig {
    final trimmedAppId = agoraAppId.trim();
    return trimmedAppId.isNotEmpty && !trimmedAppId.startsWith('YOUR_');
  }
}

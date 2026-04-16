class LiveKitTokenModel {
  final String token;
  final String wsUrl;

  LiveKitTokenModel({
    required this.token,
    required this.wsUrl,
  });

  factory LiveKitTokenModel.fromJson(Map<String, dynamic> json) {
    final rawUrl = (json['url'] as String?)?.trim() ?? '';
    // final wsUrl = _toWsUrl(rawUrl);
    final wsUrl = rawUrl;

    return LiveKitTokenModel(
      token: json['token'] as String? ?? '',
      wsUrl: wsUrl,
    );
  }

  /// Converts HTTP(S) URLs to WS(S) URLs required by LiveKit.
  /// e.g. http://3.6.145.246:7880 → ws://3.6.145.246:7880
  ///      https://livekit.example.com → wss://livekit.example.com
  // static String _toWsUrl(String url) {
  //   if (url.startsWith('https://')) {
  //     return url.replaceFirst('https://', 'wss://');
  //   } else if (url.startsWith('http://')) {
  //     return url.replaceFirst('http://', 'ws://');
  //   }
  //   // Already ws:// or wss:// — return as-is
  //   return url;
  // }

  //
}

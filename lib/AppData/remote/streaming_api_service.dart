import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:streaming_demo_app/Models/livekit_token_model.dart';

/// API service for the live streaming backend.
/// Base: http://3.6.145.246:3000
class StreamingApiService {
  static const String _baseUrl = 'http://3.6.145.246:3000';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // ========================= TOKEN ========================= //

  /// GET /getToken?room={room}&identity={name}&role={role}
  /// Returns [LiveKitTokenModel] with token + wsUrl (auto-converted to ws://).
  Future<LiveKitTokenModel?> getToken({
    required String identity,
    String room = 'test-room',
    String role = 'Presenter',
  }) async {
    try {
      final payload = {
        'room': room,
        'identity': identity,
        'role': role,
      };
      debugPrint('StreamingApiService getToken params: $payload');
      final response = await _dio.get('/getToken', queryParameters: payload);
      debugPrint('StreamingApiService getToken response: ${response.data}');
      return LiveKitTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('StreamingApiService getToken error: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('StreamingApiService getToken unexpected error: $e');
      return null;
    }
  }

  /// GET /getToken for an invited player.
  /// Uses role='Guest' as per the backend API contract.
  Future<LiveKitTokenModel?> getPlayerToken({required String identity}) async {
    return getToken(identity: identity, role: 'Guest');
  }

  // ========================= Start STREAM ========================= //

  /// POST /start-stream  (no payload)
  Future<bool> startStream() async {
    try {
      final response = await _dio.post('/start-stream');
      debugPrint('StreamingApiService startStream: ${response.data}');
      debugPrint('StreamingApiService startStream: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('StreamingApiService startStream error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('StreamingApiService startStream unexpected error: $e');
      return false;
    }
  }

  // ========================= Stop STREAM ========================= //

  /// POST /stop-stream  (no payload)
  Future<bool> stopStream() async {
    try {
      final response = await _dio.post('/stop-stream');
      debugPrint('StreamingApiService stopStream: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      debugPrint('StreamingApiService startStream error: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('StreamingApiService startStream unexpected error: $e');
      return false;
    }
  }

  //
}

/// Global singleton
final StreamingApiService streamingApiService = StreamingApiService();

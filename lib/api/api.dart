import 'package:dio/dio.dart';
import 'package:timberr/core/env/env.dart';
import 'http_manager.dart';

/// ApiService provides app-specific API endpoint helpers.
class ApiService {
  final HttpManager _httpManager;

  ApiService(this._httpManager);

  // Example auth endpoints
  Future<Response<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    return _httpManager.post<Map<String, dynamic>>(
      '/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<Response<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    return _httpManager.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        'username': name,
      },
    );
  }

  Future<Response<Map<String, dynamic>>> logout() async {
    return _httpManager.post<Map<String, dynamic>>('/auth/logout');
  }

  // Example generic user profile
  Future<Response<Map<String, dynamic>>> getUserProfile() async {
    return _httpManager.get<Map<String, dynamic>>('/user/profile');
  }

  Future<Response<List<dynamic>>> getProducts() async {
    return _httpManager.get<List<dynamic>>('/products');
  }

  // --- Meshy AI endpoints (text-to-3d) ---------------------------------
  Options get _meshyAuthOptions => Options(headers: {
        'Authorization': 'Bearer ${Env.meshyKey}',
        'Content-Type': 'application/json',
      });

  Future<Response<Map<String, dynamic>>> createMeshyPreview({
    required Map<String, dynamic> body,
  }) async {
    return _httpManager.post<Map<String, dynamic>>(
      '/openapi/v2/text-to-3d',
      data: body,
      options: _meshyAuthOptions,
    );
  }

  Future<Response<Map<String, dynamic>>> getMeshyTask({
    required String taskId,
  }) async {
    return _httpManager.get<Map<String, dynamic>>(
      '/openapi/v2/text-to-3d/$taskId',
      options: _meshyAuthOptions,
    );
  }


  // Add more endpoints here mirroring the project's needs.
}

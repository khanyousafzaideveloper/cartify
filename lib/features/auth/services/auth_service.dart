import 'package:cartify/core/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../models/login_model.dart';

class AuthService {
  final Dio dio;

  AuthService(this.dio);

  Future<LoginModel> login(String username, String password) async {
    final response = await dio.post(
      ApiConstants.login,
      data: {
        "username": username,
        "password": password,
      },
    );

    return LoginModel.fromJson(response.data);
  }
}

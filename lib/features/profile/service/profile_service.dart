import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';

class ProfileService {
  final Dio dio;

  ProfileService(this.dio);

  Future<Map<String, dynamic>> getUser(int id) async {
    final response =
    await dio.get("${ApiConstants.users}/$id");

    return response.data;
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../shared/storage/secure_storage_service.dart';
import '../services/auth_service.dart';
import 'auth_state.dart';


class AuthCubit extends Cubit<AuthState> {
  final AuthService service;
  final SecureStorageService storage;

  AuthCubit(this.service, this.storage) : super(AuthInitial());

  Future<void> login(String username, String password) async {
    emit(AuthLoading());
    try {
      final result = await service.login(username, password);
      await storage.saveToken(result.token);
      emit(AuthSuccess());
    } catch (e) {
      emit(AuthError("Invalid credentials"));
    }
  }

  Future<void> checkAuth() async {
    emit(AuthLoading());

    final token = await storage.getToken();

    if (token != null && token.isNotEmpty) {
      emit(AuthSuccess());
    } else {
      emit(AuthInitial());
    }
  }

}

import 'package:cartify/features/auth/views/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../home/homeScreen.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_cubit.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is AuthSuccess) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}

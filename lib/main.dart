import 'package:cartify/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/themes/theme_cubit.dart';
import 'core/network/dio_client.dart';
import 'features/auth/views/authWrapper.dart';
import 'features/auth/bloc/auth_cubit.dart';
import 'features/auth/services/auth_service.dart';
import 'features/carts/bloc/cart_cubit.dart';
import 'features/carts/views/cart_screen.dart';
import 'features/carts/services/cart_service.dart';
import 'features/home/homeScreen.dart';
import 'features/products/models/product_model.dart';
import 'features/products/bloc/product_cubit.dart';
import 'features/products/services/product_service.dart';
import 'features/products/views/product_detail_screen.dart';
import 'features/profile/views/profile_screen.dart';
import 'shared/storage/secure_storage_service.dart';


void main() {
  final dioClient = DioClient();
  final dio = dioClient.dio;

  final authService = AuthService(dio);
  final productService = ProductService(dio);
  final cartService = CartService(dio);
  final storage = SecureStorageService();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(authService, storage)..checkAuth(),
        ),
        BlocProvider(
          create: (_) => ProductCubit(productService),
        ),
        BlocProvider(
          create: (_) => CartCubit(cartService),
        ),
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cartify',

          themeMode: themeMode,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          initialRoute: AppRoutes.auth,
          routes: {
            AppRoutes.auth: (_) => const AuthWrapper(),
            AppRoutes.home: (_) => const HomeScreen(),
            AppRoutes.cart: (_) => const CartScreen(),
            AppRoutes.profile: (_) => const ProfileScreen(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == AppRoutes.productDetails) {
              final product = settings.arguments as ProductModel;
              return MaterialPageRoute(
                builder: (_) => ProductDetailScreen(productId: product.id,),
              );
            }
            return null;
          },

        );
      },
    );
  }
}

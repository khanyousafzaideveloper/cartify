import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../products/models/product_model.dart';
import '../models/cart_model.dart';

class CartService {
  final Dio dio;

  CartService(this.dio);

  Future<List<CartItem>> getUserCart(int userId) async {
    final response =
    await dio.get("${ApiConstants.carts}/user/$userId");

    final data = response.data[0]['products'] as List;

    return data.map((e) => CartItem.fromJson(e)).toList();
  }

  Future<ProductModel> getProduct(int id) async {
    final response =
    await dio.get("${ApiConstants.products}/$id");

    return ProductModel.fromJson(response.data);
  }
}

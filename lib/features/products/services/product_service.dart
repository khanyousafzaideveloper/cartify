import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio dio;

  ProductService(this.dio);

  Future<List<ProductModel>> getProducts() async {
    final response = await dio.get(ApiConstants.products);

    return (response.data as List)
        .map((e) => ProductModel.fromJson(e))
        .toList();
  }

  Future<ProductModel> getProductById(int id) async {
    final response = await dio.get("${ApiConstants.products}/$id");
    return ProductModel.fromJson(response.data);
  }

  Future<List<String>> getCategories() async {
    final response = await dio.get('/products/categories');
    return List<String>.from(response.data);
  }

  Future<List<ProductModel>> getProductsByCategory(String category) async {
    final response = await dio.get('/products/category/$category');

    return (response.data as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

}

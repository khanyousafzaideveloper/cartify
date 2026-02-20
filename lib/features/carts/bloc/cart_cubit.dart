import 'package:flutter_bloc/flutter_bloc.dart';
import '../../products/models/product_model.dart';
import '../services/cart_service.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CartService service;

  CartCubit(this.service) : super(CartInitial());

  Future<void> fetchCart(int userId) async {
    emit(CartLoading());

    try {
      final cartItems = await service.getUserCart(userId);
      final Map<int, int> quantities = {};


      double total = 0;
      final List<ProductModel> products = [];

      for (var item in cartItems) {
        final product = await service.getProduct(item.productId);

        total += product.price * item.quantity;

        products.add(product);

        quantities[product.id] = item.quantity; // store quantity
      }


      emit(CartLoaded(products, total, quantities));
    } catch (e) {
      emit(CartError("Failed to load cart"));
    }
  }
}

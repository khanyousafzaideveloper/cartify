import 'package:equatable/equatable.dart';

import '../../products/models/product_model.dart';
import '../models/cart_model.dart';

abstract class CartState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}
class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<ProductModel> products;
final double total;
final Map<int, int> quantities;



CartLoaded(this.products, this.total, this.quantities);


  @override
  List<Object?> get props => [products, total];
}

class CartError extends CartState {
  final String message;

  CartError(this.message);

  @override
  List<Object?> get props => [message];
}

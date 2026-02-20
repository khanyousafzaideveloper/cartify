import 'package:equatable/equatable.dart';
import '../models/product_model.dart';

abstract class ProductState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductModel> products;
  final List<String> categories;
  final String? selectedCategory;

  ProductLoaded(
      this.products,
      this.categories, {
        this.selectedCategory,
      });

  @override
  List<Object?> get props => [products, categories, selectedCategory];
}

class ProductEmpty extends ProductState {}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);

  @override
  List<Object?> get props => [message];
}
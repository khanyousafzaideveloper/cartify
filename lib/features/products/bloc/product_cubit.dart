import 'package:cartify/features/products/bloc/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductService service;

  ProductCubit(this.service) : super(ProductInitial());

  List<ProductModel> _allProducts = [];
  List<String> _categories = [];
  String? _selectedCategory;
  String _searchQuery = '';

  // Future<void> fetchProducts() async {
  //   emit(ProductLoading());
  //   try {
  //     final products = await service.getProducts();
  //     _allProducts = products;
  //     _categories = products.map((p) => p.category).toSet().toList();
  //     _selectedCategory = null;
  //     _searchQuery = '';
  //
  //     if (products.isEmpty) {
  //       emit(ProductEmpty());
  //     } else {
  //       _emitFiltered();
  //     }
  //   } catch (e) {
  //     emit(ProductError("Failed to load products"));
  //   }
  // }
  Future<void> fetchProducts() async {
    emit(ProductLoading());
    try {
      final products = await service.getProducts();
      _allProducts = products;
      _categories = products.map((p) => p.category).toSet().toList();

      print(' Products loaded: ${products.length}');
      print(' Categories found: $_categories');
      print('First product category: ${products.isNotEmpty ? products.first.category : "EMPTY"}');

      _selectedCategory = null;
      _searchQuery = '';
      if (products.isEmpty) {
        emit(ProductEmpty());
      } else {
        _emitFiltered();
      }
    } catch (e) {
      print(' Error: $e');
      emit(ProductError("Failed to load products"));
    }
  }

  void filterByCategory(String? category) {
    _selectedCategory = category;
    _searchQuery = '';
    _emitFiltered();
  }

  void search(String query) {
    _searchQuery = query;
    _emitFiltered();
  }

  void clearSearch() {
    _searchQuery = '';
    _emitFiltered();
  }

  void clearCategory() {
    _selectedCategory = null;
    _searchQuery = '';
    _emitFiltered();
  }

  void _emitFiltered() {
    var result = _allProducts;

    if (_selectedCategory != null) {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      result = result
          .where((p) =>
          p.title.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    emit(ProductLoaded(
      result,
      _categories,
      selectedCategory: _selectedCategory,
    ));
  }
}
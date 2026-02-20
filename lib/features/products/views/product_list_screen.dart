import 'package:cartify/features/products/views/product_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/widgets/product_card.dart';
import '../bloc/product_cubit.dart';
import '../bloc/product_state.dart';


class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchFocused = false;
  List<String> _cats = [];
  String? _selected;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _fmt(String s) => s
      .split(' ')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join(' ');

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F6F2);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSub = isDark
        ? Colors.white.withOpacity(0.4)
        : const Color(0xFF1A1A1A).withOpacity(0.4);
    const accent = Color(0xFF8B7355);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: RichText(
                      text: TextSpan(children: [
                        TextSpan(
                          text: 'Discover ',
                          style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              letterSpacing: -0.8),
                        ),
                        const TextSpan(
                          text: 'Products',
                          style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 26,
                              fontWeight: FontWeight.w300,
                              color: accent,
                              letterSpacing: -0.8,
                              fontStyle: FontStyle.italic),
                        ),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() {
                        _cats = [];
                        _selected = null;
                      });
                      context.read<ProductCubit>().fetchProducts();
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black.withOpacity(0.07),
                              blurRadius: 10,
                              offset: const Offset(0, 3))
                        ],
                      ),
                      child:
                      Icon(Icons.refresh_rounded, color: textPrimary, size: 20),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _isSearchFocused
                        ? accent.withOpacity(0.5)
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _isSearchFocused
                          ? accent.withOpacity(0.2)
                          : Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Focus(
                  onFocusChange: (f) => setState(() => _isSearchFocused = f),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: 15, color: textPrimary),
                    onChanged: (v) => v.isEmpty
                        ? context.read<ProductCubit>().clearSearch()
                        : context.read<ProductCubit>().search(v),
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      hintStyle: TextStyle(color: textSub, fontSize: 15),
                      prefixIcon: Icon(Icons.search_rounded,
                          color: _isSearchFocused ? accent : textSub, size: 22),
                      suffixIcon: ValueListenableBuilder(
                        valueListenable: _searchController,
                        builder: (_, val, __) =>
                        (val as TextEditingValue).text.isEmpty
                            ? const SizedBox()
                            : GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            context.read<ProductCubit>().clearSearch();
                          },
                          child: Icon(Icons.close_rounded,
                              color: textSub, size: 20),
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Chips — rendered from widget state, always visible ──
            if (_cats.isNotEmpty)
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _chip('All', _selected == null, accent, surface, textSub,
                        isDark, () {
                          setState(() => _selected = null);
                          _searchController.clear();
                          context.read<ProductCubit>().clearCategory();
                        }),
                    ..._cats.map((cat) => _chip(
                      _fmt(cat),
                      _selected == cat,
                      accent,
                      surface,
                      textSub,
                      isDark,
                          () {
                        setState(() => _selected = cat);
                        _searchController.clear();
                        context.read<ProductCubit>().filterByCategory(cat);
                      },
                    )),
                  ],
                ),
              ),

            if (_cats.isNotEmpty) const SizedBox(height: 10),

            // Grid
            Expanded(
              child: BlocConsumer<ProductCubit, ProductState>(
                buildWhen: (_, __) => true,
                listener: (context, state) {
                  if (state is ProductLoaded && state.categories.isNotEmpty) {
                    // Write categories into widget state — this is what drives the chips
                    setState(() {
                      _cats = List<String>.from(state.categories);
                      _selected = state.selectedCategory;
                    });
                  }
                },
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(accent),
                      ),
                    );
                  }

                  if (state is ProductError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wifi_off_rounded,
                              color: const Color(0xFFE53935), size: 40),
                          const SizedBox(height: 12),
                          Text(state.message,
                              style: TextStyle(color: textSub, fontSize: 14)),
                          const SizedBox(height: 20),
                          GestureDetector(
                            onTap: () =>
                                context.read<ProductCubit>().fetchProducts(),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              decoration: BoxDecoration(
                                  color: textPrimary,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text('Try again',
                                  style: TextStyle(
                                      color: bg, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      return Center(
                        child: Text('No products found',
                            style: TextStyle(color: textSub, fontSize: 15)),
                      );
                    }

                    return RefreshIndicator(
                      color: accent,
                      backgroundColor: surface,
                      onRefresh: () =>
                          context.read<ProductCubit>().fetchProducts(),
                      child: GridView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: state.products.length,
                        gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.7,
                        ),
                        itemBuilder: (context, index) {
                          final p = state.products[index];
                          return ProductCard(
                            product: p,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ProductDetailScreen(productId: p.id),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(String label, bool selected, Color accent, Color surface,
      Color textSub, bool isDark, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? accent : surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? accent
                : isDark
                ? Colors.white.withOpacity(0.12)
                : Colors.black.withOpacity(0.1),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
                color: accent.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : textSub,
          ),
        ),
      ),
    );
  }
}
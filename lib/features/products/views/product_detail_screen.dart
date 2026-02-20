import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/product_model.dart';
import '../bloc/product_cubit.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  ProductModel? product;
  bool isLoading = true;
  bool _addedToCart = false;

  late AnimationController _contentController;
  late AnimationController _buttonController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _imageScale;
  late Animation<double> _buttonScale;

  @override
  void initState() {
    super.initState();

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
    ));
    _imageScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );
    _buttonScale = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeInOut),
    );

    _loadProduct();
  }

  @override
  void dispose() {
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    final service = context.read<ProductCubit>().service;
    final result = await service.getProductById(widget.productId);
    setState(() {
      product = result;
      isLoading = false;
    });
    _contentController.forward();
  }

  void _handleAddToCart() async {
    await _buttonController.forward();
    await _buttonController.reverse();
    setState(() => _addedToCart = true);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF8B7355), size: 20),
            SizedBox(width: 10),
            Text('Added to your cart',
                style: TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _addedToCart = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F6F2);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final imageBg = isDark ? const Color(0xFF252525) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark
        ? Colors.white.withOpacity(0.45)
        : const Color(0xFF1A1A1A).withOpacity(0.45);
    const accent = Color(0xFF8B7355);

    if (isLoading) {
      return Scaffold(
        backgroundColor: bg,
        body: const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(accent),
          ),
        ),
      );
    }

    final p = product!;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [

              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: bg,
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(8),
                  child: _CircleButton(
                    icon: Icons.arrow_back_rounded,
                    surface: surface,
                    iconColor: textPrimary,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: _CircleButton(
                      icon: Icons.favorite_border_rounded,
                      surface: surface,
                      iconColor: textPrimary,
                      onTap: () {},
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: ScaleTransition(
                    scale: _imageScale,
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(20, 80, 20, 16),
                      decoration: BoxDecoration(
                        color: imageBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(isDark ? 0.4 : 0.07),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          p.image,
                          fit: BoxFit.contain,
                          loadingBuilder: (_, child, progress) {
                            if (progress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                value: progress.expectedTotalBytes != null
                                    ? progress.cumulativeBytesLoaded /
                                    progress.expectedTotalBytes!
                                    : null,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    accent),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _contentFade,
                  child: SlideTransition(
                    position: _contentSlide,
                    child: Container(
                      color: bg,
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category chip
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.category.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: accent,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          Text(
                            p.title,
                            style: TextStyle(
                              fontFamily: 'Georgia',
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                              height: 1.3,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 16),

                          Row(
                            children: [
                              Text(
                                '\$${p.price.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontFamily: 'Georgia',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w700,
                                  color: textPrimary,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFFFFB800), size: 20),
                                const SizedBox(width: 4),
                                Text(
                                  '5',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: textPrimary),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '14',
                                  style: TextStyle(
                                      fontSize: 13, color: textSecondary),
                                ),
                              ],
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Container(
                              height: 1,
                              color: textPrimary.withOpacity(0.08)),

                          const SizedBox(height: 24),

                          Text(
                            'Description',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: accent,
                              letterSpacing: 0.8,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            p.description,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.7,
                              color: textSecondary,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _contentFade,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                decoration: BoxDecoration(
                  color: bg,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, -8),
                    ),
                  ],
                ),
                child: ScaleTransition(
                  scale: _buttonScale,
                  child: GestureDetector(
                    onTap: _addedToCart ? null : _handleAddToCart,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                          const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_addedToCart
                                ? const Color(0xFF4CAF50)
                                : isDark
                                ? accent
                                : const Color(0xFF1A1A1A))
                                .withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _addedToCart
                              ? const Row(
                            key: ValueKey('added'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_rounded,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Added to Cart',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3)),
                            ],
                          )
                              : const Row(
                            key: ValueKey('add'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shopping_bag_outlined,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text('Add to Cart',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Circle Button

class _CircleButton extends StatefulWidget {
  final IconData icon;
  final Color surface;
  final Color iconColor;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.surface,
    required this.iconColor,
    required this.onTap,
  });

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _scale = Tween<double>(begin: 1.0, end: 0.88)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) async {
        await _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3)),
            ],
          ),
          child: Icon(widget.icon, color: widget.iconColor, size: 20),
        ),
      ),
    );
  }
}
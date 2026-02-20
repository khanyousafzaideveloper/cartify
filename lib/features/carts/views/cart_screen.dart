import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _listController;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;
  late Animation<double> _bottomFade;
  late Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();

    _headerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _headerFade =
        CurvedAnimation(parent: _headerController, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(
      begin: const Offset(0, -0.25),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeOutCubic));

    _bottomFade =
        CurvedAnimation(parent: _listController, curve: Curves.easeOut);
    _bottomSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic));

    _headerController.forward();
    context.read<CartCubit>().fetchCart(1);
  }

  @override
  void dispose() {
    _headerController.dispose();
    _listController.dispose();
    super.dispose();
  }

  void _onLoaded() {
    if (!_listController.isCompleted) _listController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F6F2);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark
        ? Colors.white.withOpacity(0.4)
        : const Color(0xFF1A1A1A).withOpacity(0.4);
    const accent = Color(0xFF8B7355);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                SlideTransition(
                  position: _headerSlide,
                  child: FadeTransition(
                    opacity: _headerFade,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 16, 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 34,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                    height: 1.1,
                                    letterSpacing: -1.0,
                                  ),
                                ),
                                const Text(
                                  'Cart',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 34,
                                    fontWeight: FontWeight.w300,
                                    color: accent,
                                    height: 1.1,
                                    letterSpacing: -1.0,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Body
                Expanded(
                  child: BlocConsumer<CartCubit, CartState>(
                    listener: (context, state) {
                      if (state is CartLoaded) _onLoaded();
                    },
                    builder: (context, state) {
                      if (state is CartLoading) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                AlwaysStoppedAnimation<Color>(accent),
                              ),
                              const SizedBox(height: 16),
                              Text('Loading your cart...',
                                  style: TextStyle(
                                      color: textSecondary, fontSize: 14)),
                            ],
                          ),
                        );
                      }

                      if (state is CartError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 72,
                                  height: 72,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE53935)
                                        .withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.wifi_off_rounded,
                                      color: Color(0xFFE53935), size: 32),
                                ),
                                const SizedBox(height: 20),
                                Text('Something went wrong',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary)),
                                const SizedBox(height: 8),
                                Text(state.message,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14, color: textSecondary)),
                                const SizedBox(height: 28),
                                GestureDetector(
                                  onTap: () =>
                                      context.read<CartCubit>().fetchCart(1),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 28, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: textPrimary,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text('Try again',
                                        style: TextStyle(
                                            color: bg,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      if (state is CartLoaded) {
                        if (state.products.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 84,
                                  height: 84,
                                  decoration: BoxDecoration(
                                    color: accent.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.shopping_bag_outlined,
                                      color: accent.withOpacity(0.6), size: 38),
                                ),
                                const SizedBox(height: 20),
                                Text('Your cart is empty',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: textPrimary)),
                                const SizedBox(height: 8),
                                Text('Add some products to get started',
                                    style: TextStyle(
                                        fontSize: 14, color: textSecondary)),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(

                        padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 140),
                          itemCount: state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            final qty = state.quantities[product.id] ?? 1;
                            return _AnimatedCartItem(
                              index: index,
                              child: _CartItemCard(
                                product: product,
                                quantity: qty,
                                surface: surface,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                imageBg: isDark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF8F6F2),
                              ),
                            );
                          },
                        );
                      }

                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),

            // ─── Checkout Bar ───
            BlocBuilder<CartCubit, CartState>(
              builder: (context, state) {
                if (state is! CartLoaded) return const SizedBox();
                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SlideTransition(
                    position: _bottomSlide,
                    child: FadeTransition(
                      opacity: _bottomFade,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
                        decoration: BoxDecoration(
                          color: bg,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withOpacity(isDark ? 0.4 : 0.07),
                              blurRadius: 24,
                              offset: const Offset(0, -10),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: textSecondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '\$${state.total.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: _CheckoutButton(
                                  itemCount: state.products.length),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Cart Item Card

class _CartItemCard extends StatelessWidget {
  final dynamic product;
  final int quantity;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color imageBg;

  const _CartItemCard({
    required this.product,
    required this.quantity,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.imageBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Image
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: imageBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  product.image,
                  fit: BoxFit.contain,
                  loadingBuilder: (_, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF8B7355)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF8B7355),
                        ),
                      ),
                      Text(
                        'Qty: $quantity',
                        style: TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                      ]
                  )

                ],
              ),
            ),

            // Delete icon
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: textSecondary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    size: 18, color: textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Cart Item ───────────────────────────────────────────────────────

class _AnimatedCartItem extends StatefulWidget {
  final int index;
  final Widget child;
  const _AnimatedCartItem({required this.index, required this.child});

  @override
  State<_AnimatedCartItem> createState() => _AnimatedCartItemState();
}

class _AnimatedCartItemState extends State<_AnimatedCartItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0.08, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
        opacity: _fade,
        child: SlideTransition(position: _slide, child: widget.child));
  }
}

// ─── Checkout Button ──────────────────────────────────────────────────────────

class _CheckoutButton extends StatefulWidget {
  final int itemCount;
  const _CheckoutButton({required this.itemCount});

  @override
  State<_CheckoutButton> createState() => _CheckoutButtonState();
}

class _CheckoutButtonState extends State<_CheckoutButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.95).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A1A1A).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_bag_outlined,
                    color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text(
                  'Checkout · ${widget.itemCount} ${widget.itemCount == 1 ? 'item' : 'items'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Circle Button ────────────────────────────────────────────────────────────

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
    _scale = Tween<double>(begin: 1.0, end: 0.88).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
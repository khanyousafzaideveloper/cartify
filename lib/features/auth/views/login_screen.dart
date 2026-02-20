import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _usernameFocused = false;
  bool _passwordFocused = false;

  late AnimationController _logoController;
  late AnimationController _formController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    _usernameController.text = 'mor_2314';
    _passwordController.text = '83r5^_';

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.easeOutBack),
    );
    _logoFade = CurvedAnimation(parent: _logoController, curve: Curves.easeOut);
    _formFade = CurvedAnimation(parent: _formController, curve: Curves.easeOut);
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _formController, curve: Curves.easeOutCubic));

    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _formController.forward();
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _logoController.dispose();
    _formController.dispose();
    super.dispose();
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
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                backgroundColor:
                isDark ? const Color(0xFF2A2A2A) : const Color(0xFF1A1A1A),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                content: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: Color(0xFFE53935), size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(state.message,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 14)),
                    ),
                  ],
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

                        // Logo and  Title
                        ScaleTransition(
                          scale: _logoScale,
                          child: FadeTransition(
                            opacity: _logoFade,
                            child: Column(
                              children: [
                                // Logo mark
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF8B7355),
                                        Color(0xFFC4A882)
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(22),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withOpacity(0.35),
                                        blurRadius: 24,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'C',
                                      style: TextStyle(
                                        fontFamily: 'Georgia',
                                        fontSize: 42,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Text(
                                  'Cartify',
                                  style: TextStyle(
                                    fontFamily: 'Georgia',
                                    fontSize: 38,
                                    fontWeight: FontWeight.w700,
                                    color: textPrimary,
                                    letterSpacing: -1.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sign in to continue shopping',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textSecondary,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // ─── Form ───
                        FadeTransition(
                          opacity: _formFade,
                          child: SlideTransition(
                            position: _formSlide,
                            child: Column(
                              children: [
                                // Username field
                                _buildField(
                                  controller: _usernameController,
                                  label: 'Username',
                                  icon: Icons.person_outline_rounded,
                                  isFocused: _usernameFocused,
                                  onFocusChange: (f) =>
                                      setState(() => _usernameFocused = f),
                                  surface: surface,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  accent: accent,
                                  isDark: isDark,
                                ),

                                const SizedBox(height: 14),

                                // Password area
                                _buildField(
                                  controller: _passwordController,
                                  label: 'Password',
                                  icon: Icons.lock_outline_rounded,
                                  isFocused: _passwordFocused,
                                  onFocusChange: (f) =>
                                      setState(() => _passwordFocused = f),
                                  obscureText: _obscurePassword,
                                  surface: surface,
                                  textPrimary: textPrimary,
                                  textSecondary: textSecondary,
                                  accent: accent,
                                  isDark: isDark,
                                  suffix: GestureDetector(
                                    onTap: () => setState(
                                            () => _obscurePassword = !_obscurePassword),
                                    child: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: textSecondary,
                                      size: 20,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 28),

                                // Login button
                                _LoginButton(
                                  isLoading: isLoading,
                                  onTap: isLoading
                                      ? null
                                      : () {
                                    context.read<AuthCubit>().login(
                                      _usernameController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        const Spacer(flex: 3),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool isFocused,
    required ValueChanged<bool> onFocusChange,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color accent,
    required bool isDark,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return Focus(
      onFocusChange: onFocusChange,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isFocused
                  ? accent.withOpacity(0.22)
                  : Colors.black.withOpacity(isDark ? 0.25 : 0.05),
              blurRadius: isFocused ? 18 : 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
            isFocused ? accent.withOpacity(0.5) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 15,
            color: textPrimary,
            letterSpacing: 0.2,
          ),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: TextStyle(
              color: isFocused ? accent : textSecondary,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              color: isFocused ? accent : textSecondary,
              size: 20,
            ),
            suffixIcon: suffix != null
                ? Padding(
              padding: const EdgeInsets.only(right: 4),
              child: suffix,
            )
                : null,
            border: InputBorder.none,
            contentPadding:
            const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
          ),
        ),
      ),
    );
  }
}

// ─── Login Button ─────────────────────────────────────────────────────────────

class _LoginButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback? onTap;

  const _LoginButton({required this.isLoading, required this.onTap});

  @override
  State<_LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<_LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 140));
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
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
      onTapDown: (_) {
        if (!widget.isLoading) _controller.forward();
      },
      onTapUp: (_) async {
        await _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B7355), Color(0xFFA08060)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B7355).withOpacity(0.4),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: widget.isLoading
                  ? const SizedBox(
                key: ValueKey('loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Row(
                key: ValueKey('idle'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sign In',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded,
                      color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
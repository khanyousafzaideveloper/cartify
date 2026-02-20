import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/dio_client.dart';
import '../../../core/themes/theme_cubit.dart';
import '../../auth/bloc/auth_cubit.dart';
import '../service/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? user;
  bool isLoading = true;
  bool _loggingOut = false;

  late AnimationController _avatarController;
  late AnimationController _contentController;
  late Animation<double> _avatarScale;
  late Animation<double> _avatarFade;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();

    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _avatarScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.easeOutBack),
    );

    _avatarFade = CurvedAnimation(
      parent: _avatarController,
      curve: Curves.easeOut,
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));

    _loadUser();
  }

  @override
  void dispose() {
    _avatarController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final service = ProfileService(DioClient().dio);
    final data = await service.getUser(2);
    setState(() {
      user = data;
      isLoading = false;
    });
    _avatarController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _contentController.forward();
    });
  }

  String get _initials {
    final first = (user!['name']['firstname'] as String? ?? '').isNotEmpty
        ? (user!['name']['firstname'] as String)[0].toUpperCase()
        : '';
    final last = (user!['name']['lastname'] as String? ?? '').isNotEmpty
        ? (user!['name']['lastname'] as String)[0].toUpperCase()
        : '';
    return '$first$last';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F6F2);
    final surface = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final textSecondary = isDark
        ? Colors.white.withOpacity(0.45)
        : const Color(0xFF1A1A1A).withOpacity(0.45);

    if (isLoading) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor:
            const AlwaysStoppedAnimation<Color>(Color(0xFF8B7355)),
          ),
        ),
      );
    }

    final fullName =
        '${user!['name']['firstname']} ${user!['name']['lastname']}';
    final email = user!['email'] as String;
    final city = user!['address']['city'] as String;
    final street = user!['address']['street'] as String? ?? '';
    final phone = user!['phone'] as String? ?? '';

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ─── Top Bar ───
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profile',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    // Dark mode toggle pill
                    GestureDetector(
                      onTap: () => context.read<ThemeCubit>().toggleTheme(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        width: 64,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF8B7355)
                              : surface,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            AnimatedPositioned(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOutCubic,
                              left: isDark ? 32 : 4,
                              top: 4,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF8B7355),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isDark
                                      ? Icons.dark_mode_rounded
                                      : Icons.light_mode_rounded,
                                  size: 14,
                                  color: isDark
                                      ? const Color(0xFF8B7355)
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─── Avatar ───
              ScaleTransition(
                scale: _avatarScale,
                child: FadeTransition(
                  opacity: _avatarFade,
                  child: Column(
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF8B7355), Color(0xFFC4A882)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                              const Color(0xFF8B7355).withOpacity(0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _initials,
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        fullName.split(' ').map((w) =>
                        w[0].toUpperCase() + w.substring(1)).join(' '),
                        style: TextStyle(
                          fontFamily: 'Georgia',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: TextStyle(fontSize: 14, color: textSecondary),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ─── Info Cards ───
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionLabel(label: 'Account Info', color: textSecondary),
                        const SizedBox(height: 10),
                        _InfoCard(
                          surface: surface,
                          items: [
                            _InfoRow(
                              icon: Icons.person_outline_rounded,
                              label: 'Full Name',
                              value: fullName.split(' ').map((w) =>
                              w[0].toUpperCase() + w.substring(1)).join(' '),
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                            _Divider(color: textSecondary),
                            _InfoRow(
                              icon: Icons.mail_outline_rounded,
                              label: 'Email',
                              value: email,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                            if (phone.isNotEmpty) ...[
                              _Divider(color: textSecondary),
                              _InfoRow(
                                icon: Icons.phone_outlined,
                                label: 'Phone',
                                value: phone,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 20),

                        _SectionLabel(label: 'Address', color: textSecondary),
                        const SizedBox(height: 10),
                        _InfoCard(
                          surface: surface,
                          items: [
                            _InfoRow(
                              icon: Icons.location_city_outlined,
                              label: 'City',
                              value: city[0].toUpperCase() + city.substring(1),
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                            ),
                            if (street.isNotEmpty) ...[
                              _Divider(color: textSecondary),
                              _InfoRow(
                                icon: Icons.map_outlined,
                                label: 'Street',
                                value: street,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 32),

                        // ─── Logout Button ───
                        _LogoutButton(
                          isLoading: _loggingOut,
                          onTap: () async {
                            setState(() => _loggingOut = true);
                            await Future.delayed(
                                const Duration(milliseconds: 600));
                            if (!mounted) return;
                            context.read<AuthCubit>().storage.clear();
                            context.read<AuthCubit>().checkAuth();
                          },
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Section Label ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.2,
      ),
    );
  }
}

// ─── Info Card ────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final Color surface;
  final List<Widget> items;
  const _InfoCard({required this.surface, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: items),
    );
  }
}

// ─── Info Row ─────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSecondary;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF8B7355).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF8B7355)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      fontSize: 11, color: textSecondary, letterSpacing: 0.3),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Divider ─────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  final Color color;
  const _Divider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 68),
      child: Container(height: 1, color: color.withOpacity(0.12)),
    );
  }
}

// ─── Logout Button ────────────────────────────────────────────────────────────

class _LogoutButton extends StatefulWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LogoutButton({required this.isLoading, required this.onTap});

  @override
  State<_LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<_LogoutButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
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
        if (!widget.isLoading) widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEDED),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE53935).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Center(
            child: widget.isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE53935)),
              ),
            )
                : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded,
                    color: Color(0xFFE53935), size: 18),
                SizedBox(width: 8),
                Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Color(0xFFE53935),
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
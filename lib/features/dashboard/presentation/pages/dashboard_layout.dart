import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/constants/app_links.dart';
import 'package:admin_dashboard/core/demo/demo_mode.dart';
import 'package:admin_dashboard/core/widgets/pressable.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  /// Below this width the sidebar would leave too little room for the
  /// content (at 390 px the page titles broke one letter per line), so it
  /// becomes a drawer opened from a slim top bar.
  static const compactBreakpoint = 1000.0;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final compact = MediaQuery.sizeOf(context).width < compactBreakpoint;

    if (compact) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shape: const Border(bottom: BorderSide(color: AppColors.border)),
          iconTheme: const IconThemeData(color: AppColors.ink),
          titleSpacing: 4,
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(width: 28, height: 28, child: Image.asset('assets/images/logo.png')),
              ),
              const SizedBox(width: 10),
              const Text(
                'Portfolio Admin',
                style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600, fontSize: 15, letterSpacing: -0.2),
              ),
              if (demoMode) ...[const SizedBox(width: 10), const _DemoBadge()],
            ],
          ),
        ),
        drawer: Drawer(
          width: 280,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(),
          child: SafeArea(child: _Sidebar(location: location, inDrawer: true)),
        ),
        body: child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(location: location),
          const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
          // The page area's navigator puts a route barrier on top that hides
          // everything painted before it from screen readers, and the sidebar
          // is painted first. A separate semantics container keeps the barrier
          // inside the page area.
          Expanded(child: Semantics(container: true, child: child)),
        ],
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final String location;

  /// Shown inside the compact layout's drawer: fills the drawer's width and
  /// closes the drawer when a page is chosen.
  final bool inDrawer;

  const _Sidebar({required this.location, this.inDrawer = false});

  static const _navItems = [
    _NavItem(icon: Icons.grid_view_rounded,       label: 'Dashboard',     route: '/'),
    _NavItem(icon: Icons.person_outline_rounded,  label: 'Profile Info',  route: '/profile-info'),
    _NavItem(icon: Icons.rocket_launch_outlined,  label: 'Projects',      route: '/projects'),
    _NavItem(icon: Icons.auto_awesome_outlined,   label: 'Expertise',     route: '/expertise'),
    _NavItem(icon: Icons.timeline_rounded,        label: 'Experience',    route: '/experience'),
    _NavItem(icon: Icons.rate_review_outlined,    label: 'Testimonials',  route: '/testimonials'),
    _NavItem(icon: Icons.emoji_events_outlined,   label: 'Why Choose Me', route: '/why-choose-me'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: inDrawer ? null : 240,
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBrand(),
          _buildNavSection(context),
          const Spacer(),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 36,
              height: 36,
              child: Image.asset('assets/images/logo.png'),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Portfolio',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    letterSpacing: -0.2,
                    height: 1.2,
                  ),
                ),
                Text(
                  'Admin',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (demoMode) const _DemoBadge(),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 12, bottom: 6, top: 4),
        child: Text(
          text,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      );

  Widget _buildNavSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Content'),
          ..._navItems.map((item) {
            final isSelected = item.route == '/'
                ? location == '/'
                : location.startsWith(item.route);
            return _SidebarItem(
              item: item,
              isSelected: isSelected,
              onTap: () {
                if (inDrawer) Navigator.of(context).pop();
                context.go(item.route);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final email = demoMode
            ? 'Demo mode, no account'
            : state is Authenticated
                ? (state.user.email ?? '')
                : '';
        final initial = demoMode
            ? 'D'
            : email.isNotEmpty
                ? email[0].toUpperCase()
                : 'A';

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _PreviewPortfolioButton(),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              // User row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Admin',
                            style: TextStyle(
                              color: AppColors.ink,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            email,
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: 'Log out',
                      child: Pressable(
                        semanticLabel: 'Log out',
                        onTap: () {
                          if (demoMode) {
                            context.go('/login');
                          } else {
                            context.read<AuthCubit>().logout();
                          }
                        },
                        builder: (context, hovered) => AnimatedContainer(
                          duration: AppMotion.of(context, AppMotion.fast),
                          curve: AppMotion.ease,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: hovered
                                ? const Color(0xFFFEF3F2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: hovered
                                ? AppColors.danger
                                : AppColors.textTertiary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DemoBadge extends StatelessWidget {
  const _DemoBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Text(
        'DEMO',
        style: AppFonts.monoStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: AppColors.warning,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Preview Portfolio button ──────────────────────────────────────────────────

class _PreviewPortfolioButton extends StatelessWidget {
  const _PreviewPortfolioButton();

  Future<void> _open() async {
    final uri = Uri.parse(AppLinks.portfolio);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: _open,
      semanticLabel: 'Preview portfolio',
      builder: (context, hovered) => AnimatedContainer(
        duration: AppMotion.of(context, AppMotion.fast),
        curve: AppMotion.ease,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: hovered ? AppColors.background : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: const Row(
          children: [
            Icon(Icons.open_in_new_rounded, color: AppColors.ink, size: 16),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Preview portfolio',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            Icon(Icons.arrow_outward_rounded,
                size: 14, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}

// ── Nav item data class ────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final String label;
  final String route;
  const _NavItem({required this.icon, required this.label, required this.route});
}

// ── Sidebar item ──────────────────────────────────────────────────────────────

class _SidebarItem extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      semanticLabel: item.label,
      builder: (context, hovered) {
        final Color bg = isSelected
            ? AppColors.primarySoft
            : hovered
                ? AppColors.ink.withValues(alpha: 0.04)
                : Colors.transparent;
        final Color fg = isSelected
            ? AppColors.primary
            : hovered
                ? AppColors.ink
                : AppColors.textSecondary;
        return AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.fast),
          curve: AppMotion.ease,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(item.icon, size: 18, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                    letterSpacing: -0.1,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

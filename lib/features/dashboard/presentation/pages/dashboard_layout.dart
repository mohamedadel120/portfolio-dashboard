import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/constants/app_links.dart';

class DashboardLayout extends StatelessWidget {
  final Widget child;

  const DashboardLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _Sidebar(location: location),
          Container(
            width: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.3, 1.0],
              ),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────────────

class _Sidebar extends StatelessWidget {
  final String location;
  const _Sidebar({required this.location});

  static const _navItems = [
    _NavItem(icon: Icons.grid_view_rounded,       label: 'Dashboard',     route: '/'),
    _NavItem(icon: Icons.person_outline_rounded,  label: 'Profile Info',  route: '/profile-info'),
    _NavItem(icon: Icons.rocket_launch_rounded,   label: 'Projects',      route: '/projects'),
    _NavItem(icon: Icons.auto_awesome_rounded,    label: 'Expertise',     route: '/expertise'),
    _NavItem(icon: Icons.timeline_rounded,        label: 'Experience',    route: '/experience'),
    _NavItem(icon: Icons.rate_review_rounded,     label: 'Testimonials',  route: '/testimonials'),
    _NavItem(icon: Icons.emoji_events_rounded,    label: 'Why Choose Me', route: '/why-choose-me'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        color: AppColors.surface,
        // Very subtle radial glow at the top from the cyan brand color
        gradient: RadialGradient(
          center: const Alignment(-0.6, -0.85),
          radius: 0.9,
          colors: [
            AppColors.primary.withValues(alpha: 0.055),
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBrand(),
          const SizedBox(height: 4),
          _buildNavSection(context),
          const Spacer(),
          _buildBottomSection(context),
        ],
      ),
    );
  }

  Widget _buildBrand() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 26, 18, 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05)),
        ),
      ),
      child: Row(
        children: [
          // Logo mark
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, Color(0xFF0099BB)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: Colors.black, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Portfolio',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  letterSpacing: 0.1,
                  height: 1.1,
                ),
              ),
              Text(
                'ADMIN',
                style: TextStyle(
                  color: AppColors.primary.withValues(alpha: 0.6),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 8),
            child: Row(
              children: [
                Text(
                  'NAVIGATION',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.18),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Divider(
                    color: Colors.white.withValues(alpha: 0.06),
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          ..._navItems.map((item) {
            final isSelected = item.route == '/'
                ? location == '/'
                : location.startsWith(item.route);
            return _SidebarItem(
              item: item,
              isSelected: isSelected,
              onTap: () => context.go(item.route),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final email =
            state is Authenticated ? (state.user.email ?? '') : '';
        final initial =
            email.isNotEmpty ? email[0].toUpperCase() : 'A';

        return Column(
          children: [
            // Preview Portfolio button
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: _PreviewPortfolioButton(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10, bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          'ACCOUNT',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.18),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.8,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Divider(
                            color: Colors.white.withValues(alpha: 0.06),
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SidebarItem(
                    item: const _NavItem(
                      icon: Icons.logout_rounded,
                      label: 'Logout',
                      route: '',
                    ),
                    isSelected: false,
                    isDestructive: true,
                    onTap: () => context.read<AuthCubit>().logout(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // User card
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.06),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    // Avatar with gradient + glow
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.primary, AppColors.secondary],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
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
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.32),
                              fontSize: 10,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Preview Portfolio button ──────────────────────────────────────────────────

class _PreviewPortfolioButton extends StatefulWidget {
  @override
  State<_PreviewPortfolioButton> createState() =>
      _PreviewPortfolioButtonState();
}

class _PreviewPortfolioButtonState extends State<_PreviewPortfolioButton> {
  bool _hovered = false;

  Future<void> _open() async {
    final uri = Uri.parse(AppLinks.portfolio);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _hovered
                  ? [
                      AppColors.primary.withValues(alpha: 0.2),
                      AppColors.secondary.withValues(alpha: 0.12),
                    ]
                  : [
                      AppColors.primary.withValues(alpha: 0.08),
                      AppColors.secondary.withValues(alpha: 0.04),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hovered
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.primary.withValues(alpha: 0.18),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.18),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.25),
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.open_in_new_rounded,
                    color: AppColors.primary, size: 15),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Preview Portfolio',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: _hovered
                        ? AppColors.primary
                        : Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: _hovered
                    ? AppColors.primary.withValues(alpha: 0.7)
                    : Colors.white.withValues(alpha: 0.2),
              ),
            ],
          ),
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

class _SidebarItem extends StatefulWidget {
  final _NavItem item;
  final bool isSelected;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final accent =
        widget.isDestructive ? Colors.redAccent : AppColors.primary;
    final isActive = widget.isSelected;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      accent.withValues(alpha: 0.18),
                      accent.withValues(alpha: 0.04),
                    ],
                  )
                : _hovered
                    ? LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.05),
                          Colors.transparent,
                        ],
                      )
                    : null,
            borderRadius: BorderRadius.circular(12),
            border: isActive
                ? Border.all(color: accent.withValues(alpha: 0.22))
                : null,
          ),
          child: Row(
            children: [
              // Left accent line for active
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: isActive ? 3 : 0,
                height: isActive ? 20 : 0,
                margin: EdgeInsets.only(right: isActive ? 6 : 0),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: accent.withValues(alpha: 0.7),
                            blurRadius: 8,
                          )
                        ]
                      : [],
                ),
              ),
              // Icon
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (isActive || _hovered)
                      ? accent.withValues(alpha: 0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(
                  widget.item.icon,
                  size: 17,
                  color: isActive
                      ? accent
                      : _hovered
                          ? Colors.white.withValues(alpha: 0.7)
                          : Colors.white.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  widget.item.label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                        isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive
                        ? accent
                        : _hovered
                            ? Colors.white.withValues(alpha: 0.75)
                            : Colors.white.withValues(alpha: 0.38),
                    letterSpacing: 0.1,
                  ),
                ),
              ),
              if (isActive)
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accent,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.8),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

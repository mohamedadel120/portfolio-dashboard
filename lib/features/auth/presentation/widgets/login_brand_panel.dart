import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/dot_grid_painter.dart';
import 'package:admin_dashboard/core/widgets/fade_slide_in.dart';
import 'package:admin_dashboard/core/widgets/typewriter_text.dart';

/// The login screen's right-hand branding panel: dot-grid texture, drifting
/// glow orbs, the app logo with a continuous breathing glow, a short list
/// of feature highlights, and a typewriter quote pinned to the bottom.
///
/// Manages its own ambient (looping) animation for the glow effects, but
/// takes the page's one-shot [entrance] controller so its own reveal stays
/// in sync with the rest of the login screen's staggered entrance.
class LoginBrandPanel extends StatefulWidget {
  final AnimationController entrance;

  const LoginBrandPanel({super.key, required this.entrance});

  @override
  State<LoginBrandPanel> createState() => _LoginBrandPanelState();
}

class _LoginBrandPanelState extends State<LoginBrandPanel>
    with SingleTickerProviderStateMixin {
  static const _featureHighlights = [
    (
      icon: Icons.rocket_launch_rounded,
      label: 'Manage Projects & Case Studies',
    ),
    (
      icon: Icons.rate_review_rounded,
      label: 'Curate Testimonials & Experience',
    ),
    (icon: Icons.bar_chart_rounded, label: 'Track Real-Time Analytics'),
  ];

  /// Slow, continuous loop driving the ambient effects (glow orbs,
  /// breathing logo glow) — separate from [LoginBrandPanel.entrance] since
  /// those keep animating for as long as the panel is on screen, not just
  /// once on load.
  late final AnimationController _ambient;

  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _ambient.dispose();
    super.dispose();
  }

  Animation<double> _stagger(double start, double end) {
    return staggerInterval(widget.entrance, start, end);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(-0.3, -0.6),
            radius: 1.3,
            colors: [
              AppColors.primary.withValues(alpha: 0.16),
              AppColors.background,
            ],
          ),
          border: const Border(left: BorderSide(color: Colors.white12)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: DotGridPainter(
                  color: AppColors.primary.withValues(alpha: 0.05),
                ),
              ),
            ),
            _GlowOrb(
              ambient: _ambient,
              alignment: const Alignment(-0.75, -0.7),
              size: 240,
              phase: 0.0,
            ),
            _GlowOrb(
              ambient: _ambient,
              alignment: const Alignment(0.85, 0.35),
              size: 180,
              phase: 0.4,
            ),
            _GlowOrb(
              ambient: _ambient,
              alignment: const Alignment(0.6, -0.85),
              size: 130,
              phase: 0.75,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _stagger(0.1, 0.75),
                    child: _BreathingLogo(ambient: _ambient),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'PORTFOLIO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'ADMIN',
                    style: TextStyle(
                      color: AppColors.primary.withValues(alpha: 0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 6,
                    ),
                  ),
                  const SizedBox(height: 36),
                  FadeSlideIn(
                    animation: _stagger(0.3, 0.8),
                    child: _FeatureHighlights(items: _featureHighlights),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(48, 40, 0, 48),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.background.withValues(alpha: 0),
                      AppColors.background.withValues(alpha: 0.9),
                    ],
                  ),
                ),
                child: const Column(
                  children: [
                    Typewriter(
                      text:
                          '"Great portfolios aren\'t built once — they\'re maintained."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      '— Portfolio Admin',
                      style: TextStyle(color: Colors.white54, fontSize: 12.5),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreathingLogo extends StatelessWidget {
  final Animation<double> ambient;

  const _BreathingLogo({required this.ambient});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ambient,
      child: Image.asset('assets/images/logo.png'),
      builder: (context, child) {
        final wave = (math.sin(ambient.value * 2 * math.pi) + 1) / 2;
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.32 + wave * 0.22),
                blurRadius: 40 + wave * 20,
                spreadRadius: 4 + wave * 4,
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final Animation<double> ambient;
  final Alignment alignment;
  final double size;
  final double phase;

  const _GlowOrb({
    required this.ambient,
    required this.alignment,
    required this.size,
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedBuilder(
        animation: ambient,
        builder: (context, _) {
          final wave =
              (math.sin((ambient.value + phase) * 2 * math.pi) + 1) / 2;
          return Opacity(
            opacity: 0.10 + wave * 0.12,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.55),
                    AppColors.primary.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeatureHighlights extends StatelessWidget {
  final List<({IconData icon, String label})> items;

  const _FeatureHighlights({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(item.icon, color: AppColors.primary, size: 15),
                ),
                const SizedBox(width: 12),
                Text(
                  item.label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

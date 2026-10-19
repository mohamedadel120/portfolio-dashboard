import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/dot_grid_painter.dart';
import 'package:admin_dashboard/core/widgets/fade_slide_in.dart';
import 'package:admin_dashboard/core/widgets/typewriter_text.dart';

/// The login screen's right-hand branding panel, in the light direction:
/// a white surface with a faint ink dot grid, the logo on a softly shadowed
/// tile, a short list of what the dashboard manages, and a typewriter quote
/// pinned to the bottom. No glows and no looping ambient motion.
///
/// Takes the page's one-shot [entrance] controller so its reveal stays in
/// sync with the rest of the login screen's staggered entrance.
class LoginBrandPanel extends StatelessWidget {
  final AnimationController entrance;

  const LoginBrandPanel({super.key, required this.entrance});

  static const _featureHighlights = [
    (icon: Icons.rocket_launch_outlined, label: 'Projects and case studies'),
    (icon: Icons.rate_review_outlined, label: 'Testimonials and experience'),
    (icon: Icons.bar_chart_rounded, label: 'Live visitor analytics'),
  ];

  Animation<double> _stagger(double start, double end) =>
      staggerInterval(entrance, start, end);

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(left: BorderSide(color: AppColors.border)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: DotGridPainter(
                  color: AppColors.ink.withValues(alpha: 0.07),
                  spacing: 24,
                  dotRadius: 1.1,
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeSlideIn(
                      animation: _stagger(0.1, 0.6),
                      offsetY: 10,
                      child: Container(
                        width: 88,
                        height: 88,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppShadows.raised,
                        ),
                        child: Image.asset('assets/images/logo.png'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Portfolio Admin',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Everything the portfolio site shows, in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    FadeSlideIn(
                      animation: _stagger(0.3, 0.8),
                      child: const _FeatureHighlights(items: _featureHighlights),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 48,
              right: 48,
              bottom: 40,
              child: Column(
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 20),
                  Typewriter(
                    text:
                        '"Great portfolios aren\'t built once — they\'re maintained."',
                    style: TextStyle(
                      color: AppColors.ink.withValues(alpha: 0.85),
                      fontSize: 15,
                      height: 1.5,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureHighlights extends StatelessWidget {
  final List<({IconData icon, String label})> items;

  const _FeatureHighlights({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, item) in items.indexed) ...[
            if (i > 0) const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Icon(item.icon, color: AppColors.primary, size: 16),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 220,
                    child: Text(
                      item.label,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

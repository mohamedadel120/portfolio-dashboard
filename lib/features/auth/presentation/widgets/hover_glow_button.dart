import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/widgets/app_button.dart';

/// Full-width primary sign-in button: a teal pill that darkens on hover and
/// scales to 0.97 on press (no glow). Shows a spinner while [isLoading].
///
/// The name is kept from the earlier dark theme so call sites stay stable.
class HoverGlowButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;

  const HoverGlowButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: AppButton(
        label: label,
        isLoading: isLoading,
        onPressed: onPressed,
        expand: true,
      ),
    );
  }
}

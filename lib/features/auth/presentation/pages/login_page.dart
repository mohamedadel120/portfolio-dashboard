import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import '../widgets/login_brand_panel.dart';
import '../widgets/login_form.dart';

/// Below this width the brand/quote panel is dropped in favor of a
/// single centered form column (there isn't room for both side by side).
const double _splitScreenBreakpoint = 860;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  /// Drives the one-shot staggered entrance of both the form and the brand
  /// panel, so they reveal in sync even though each owns its own fields.
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSplitScreen = MediaQuery.sizeOf(context).width >= _splitScreenBreakpoint;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 380),
                  child: LoginForm(entrance: _entrance),
                ),
              ),
            ),
          ),
          if (isSplitScreen)
            Expanded(child: LoginBrandPanel(entrance: _entrance)),
        ],
      ),
    );
  }
}

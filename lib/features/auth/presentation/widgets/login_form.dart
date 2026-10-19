import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/demo/demo_mode.dart';
import 'package:admin_dashboard/core/widgets/app_button.dart';
import 'package:admin_dashboard/core/widgets/fade_slide_in.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import 'hover_glow_button.dart';

/// The email/password sign-in form: owns its own field state and staggers
/// its own reveal off the page's shared [entrance] controller.
class LoginForm extends StatefulWidget {
  final AnimationController entrance;

  const LoginForm({super.key, required this.entrance});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Animation<double> _stagger(double start, double end) {
    return staggerInterval(widget.entrance, start, end);
  }

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthCubit>().loginWithEmailAndPassword(email, password);
    }
  }

  static const _labelStyle = TextStyle(
    color: AppColors.ink,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          animation: _stagger(0.0, 0.5),
          child: const Text(
            'Welcome back',
            style: TextStyle(
              color: AppColors.ink,
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.7,
            ),
          ),
        ),
        const SizedBox(height: 6),
        FadeSlideIn(
          animation: _stagger(0.05, 0.55),
          child: const Text(
            'Sign in to manage your portfolio.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
        ),
        if (demoMode) ...[
          const SizedBox(height: 20),
          const _DemoNotice(),
        ],
        const SizedBox(height: 28),
        FadeSlideIn(
          animation: _stagger(0.15, 0.65),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Email', style: _labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                decoration: const InputDecoration(hintText: 'you@example.com'),
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                textInputAction: TextInputAction.next,
                onSubmitted: (_) {
                  if (_passwordController.text.isEmpty) {
                    _passwordFocusNode.requestFocus();
                  } else {
                    _onLoginPressed();
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        FadeSlideIn(
          animation: _stagger(0.25, 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Password', style: _labelStyle),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                focusNode: _passwordFocusNode,
                style: const TextStyle(color: AppColors.ink, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    tooltip:
                        _obscurePassword ? 'Show password' : 'Hide password',
                  ),
                ),
                obscureText: _obscurePassword,
                autofillHints: const [AutofillHints.password],
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onLoginPressed(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FadeSlideIn(
          animation: _stagger(0.35, 0.85),
          child: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.danger,
                  ),
                );
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return HoverGlowButton(
                label: 'Sign in',
                isLoading: isLoading,
                onPressed: isLoading ? null : _onLoginPressed,
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Shown only in demo builds: sign-in is off, so offer a way in.
class _DemoNotice extends StatelessWidget {
  const _DemoNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Demo build: sign-in is off and all data is sample data.',
              style: TextStyle(
                  color: AppColors.ink, fontSize: 13, height: 1.4),
            ),
          ),
          const SizedBox(width: 10),
          AppButton(
            label: 'Open',
            compact: true,
            variant: AppButtonVariant.secondary,
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }
}

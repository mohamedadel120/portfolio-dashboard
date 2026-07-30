import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

/// Below this width the brand/quote panel is dropped in favor of a
/// single centered form column (there isn't room for both side by side).
const double _splitScreenBreakpoint = 860;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
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

  void _onLoginPressed() {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isNotEmpty && password.isNotEmpty) {
      context.read<AuthCubit>().loginWithEmailAndPassword(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSplitScreen =
        MediaQuery.sizeOf(context).width >= _splitScreenBreakpoint;

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
                  child: _buildForm(context),
                ),
              ),
            ),
          ),
          if (isSplitScreen)
            Expanded(child: _buildBrandPanel()),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Welcome back',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Sign in to manage your portfolio',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 32),
        const Text('Email', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(hint: 'you@example.com'),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            if (_passwordController.text.isEmpty) {
              _passwordFocusNode.requestFocus();
            } else {
              _onLoginPressed();
            }
          },
        ),
        const SizedBox(height: 20),
        const Text('Password', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(hint: 'Password').copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white54,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              tooltip: _obscurePassword ? 'Show password' : 'Hide password',
            ),
          ),
          obscureText: _obscurePassword,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => _onLoginPressed(),
        ),
        const SizedBox(height: 28),
        BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is AuthLoading;
            return SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : _onLoginPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : const Text('SIGN IN'),
              ),
            );
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white30, fontSize: 14),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.03),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.white12)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
    );
  }

  Widget _buildBrandPanel() {
    return Container(
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
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 48,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Image.asset('assets/images/logo.png'),
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
              ],
            ),
          ),
          Positioned(
            left: 48,
            right: 48,
            bottom: 56,
            child: Container(
              padding: const EdgeInsets.only(top: 32),
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
              child: Column(
                children: [
                  const _Typewriter(
                    text: '"Great portfolios aren\'t built once — they\'re maintained."',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '— Portfolio Admin',
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One-shot typewriter reveal (no loop/delete) — a login screen isn't sat
/// on indefinitely, so a repeating animation would just be distracting.
class _Typewriter extends StatefulWidget {
  final String text;
  final TextStyle? style;

  static const _speed = Duration(milliseconds: 45);

  const _Typewriter({required this.text, this.style});

  @override
  State<_Typewriter> createState() => _TypewriterState();
}

class _TypewriterState extends State<_Typewriter> {
  String _displayed = '';
  bool _showCursor = true;
  Timer? _typeTimer;
  Timer? _cursorTimer;

  @override
  void initState() {
    super.initState();
    _startTyping();
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) setState(() => _showCursor = !_showCursor);
    });
  }

  void _startTyping() {
    var index = 0;
    _typeTimer = Timer.periodic(_Typewriter._speed, (timer) {
      if (index >= widget.text.length) {
        timer.cancel();
        return;
      }
      setState(() => _displayed += widget.text[index]);
      index++;
    });
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _cursorTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.style?.color ?? Colors.white;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: widget.style,
        children: [
          TextSpan(text: _displayed),
          TextSpan(
            text: '|',
            style: TextStyle(color: color.withValues(alpha: _showCursor ? 1 : 0)),
          ),
        ],
      ),
    );
  }
}

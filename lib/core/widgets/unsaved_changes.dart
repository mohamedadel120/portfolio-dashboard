import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import 'app_button.dart';

/// Guards a form against losing edits. While [isDirty] returns true, every
/// way of closing it that goes through `Navigator.maybePop` (Esc, a click on
/// the dialog barrier, the browser's back, a Cancel/Close button that calls
/// `maybePop`) first asks "Discard changes?". A plain `Navigator.pop` (used
/// after a successful save) still closes at once.
///
/// [isDirty] is asked only when someone tries to close, so the form does not
/// need to rebuild on every keystroke to keep it current.
class UnsavedChangesGuard extends StatelessWidget {
  final bool Function() isDirty;
  final Widget child;

  const UnsavedChangesGuard({super.key, required this.isDirty, required this.child});

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final navigator = Navigator.of(context);
        if (!isDirty() || await confirmDiscard(context)) navigator.pop(result);
      },
      child: child,
    );
  }
}

/// "Discard changes?" with Keep editing and Discard; Esc or a click outside
/// keeps editing.
/// Returns true when the owner chooses to discard.
Future<bool> confirmDiscard(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Discard changes?'),
      content: const Text(
        'You have edits that are not saved. They will be lost.',
        style: TextStyle(fontFamily: AppFonts.sans, color: AppColors.textSecondary, fontSize: 14, height: 1.5),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      actions: [
        AppButton(
          label: 'Keep editing',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.pop(ctx, false),
        ),
        AppButton(
          label: 'Discard',
          variant: AppButtonVariant.danger,
          onPressed: () => Navigator.pop(ctx, true),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// A fingerprint of a form's current values, for comparing against the one
/// taken when the form opened. Pass every value the form edits, in a fixed
/// order (text, flags, lists).
String formSnapshot(List<Object?> values) => values
    .map((v) => switch (v) {
          TextEditingController c => c.text,
          List<Object?> l => l.join('\u0001'),
          _ => '$v',
        })
    .join('\u0000');

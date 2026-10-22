import 'package:admin_dashboard/core/widgets/unsaved_changes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Opens a dialog whose body is wrapped in [UnsavedChangesGuard] with the
/// given dirty state, plus a Cancel button that goes through maybePop and a
/// Save button that pops directly (as the forms do after saving).
Future<void> openGuardedDialog(WidgetTester tester, {required bool Function() isDirty}) async {
  await tester.pumpWidget(MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () => showDialog<void>(
              context: context,
              builder: (_) => UnsavedChangesGuard(
                isDirty: isDirty,
                child: Builder(
                  builder: (ctx) => AlertDialog(
                    content: const Text('THE FORM'),
                    actions: [
                      TextButton(onPressed: () => Navigator.maybePop(ctx), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Save')),
                    ],
                  ),
                ),
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  expect(find.text('THE FORM'), findsOneWidget);
}

void main() {
  testWidgets('a form without changes closes straight away', (tester) async {
    await openGuardedDialog(tester, isDirty: () => false);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('THE FORM'), findsNothing);
    expect(find.text('Discard changes?'), findsNothing);
  });

  testWidgets('a changed form asks first; Keep editing keeps it open', (tester) async {
    await openGuardedDialog(tester, isDirty: () => true);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
    await tester.tap(find.text('Keep editing'));
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsNothing);
    expect(find.text('THE FORM'), findsOneWidget);
  });

  testWidgets('Discard closes the changed form', (tester) async {
    await openGuardedDialog(tester, isDirty: () => true);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Discard'));
    await tester.pumpAndSettle();
    expect(find.text('THE FORM'), findsNothing);
  });

  testWidgets('Esc goes through the same question', (tester) async {
    await openGuardedDialog(tester, isDirty: () => true);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Discard changes?'), findsOneWidget);
  });

  testWidgets('closing after a save is not held back', (tester) async {
    await openGuardedDialog(tester, isDirty: () => true);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('THE FORM'), findsNothing);
    expect(find.text('Discard changes?'), findsNothing);
  });

  test('the snapshot sees an edit, and an edit undone as no change', () {
    final name = TextEditingController(text: 'Gomla');
    final tags = ['Flutter'];
    final initial = formSnapshot([name, true, tags]);
    name.text = 'Gomla Mobile App';
    expect(formSnapshot([name, true, tags]), isNot(initial));
    name.text = 'Gomla';
    expect(formSnapshot([name, true, tags]), initial);
    expect(formSnapshot([name, false, tags]), isNot(initial));
    expect(formSnapshot([name, true, [...tags, 'Bloc']]), isNot(initial));
  });
}

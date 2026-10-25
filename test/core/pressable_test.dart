import 'package:admin_dashboard/core/widgets/pressable.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget host(Widget child) => MaterialApp(home: Scaffold(body: Center(child: child)));

  // The ring is the first foreground border under that Pressable; it is
  // always there and turns teal when shown.
  bool ringOn(WidgetTester tester, Finder pressable) {
    final box = tester.widget<DecoratedBox>(find
        .descendant(of: pressable, matching: find.byWidgetPredicate((w) => w is DecoratedBox && w.position == DecorationPosition.foreground))
        .first);
    final border = (box.decoration as BoxDecoration).border! as Border;
    return border.top.color != Colors.transparent;
  }

  testWidgets('Tab reaches it; Enter and Space run it', (tester) async {
    var taps = 0;
    await tester.pumpWidget(host(Pressable(
      onTap: () => taps++,
      semanticLabel: 'Save',
      builder: (_, _) => const SizedBox(width: 80, height: 40),
    )));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();

    expect(taps, 2);
  });

  testWidgets('shows a focus ring only with keyboard focus', (tester) async {
    await tester.pumpWidget(host(Pressable(
      onTap: () {},
      builder: (_, _) => const SizedBox(width: 80, height: 40),
    )));
    expect(ringOn(tester, find.byType(Pressable)), isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(ringOn(tester, find.byType(Pressable)), isTrue);
  });

  testWidgets('a card shows no ring while its own button has focus', (tester) async {
    await tester.pumpWidget(host(Pressable(
      key: const Key('card'),
      onTap: () {},
      builder: (_, _) => SizedBox(
        width: 200,
        height: 100,
        child: Center(child: Pressable(key: const Key('edit'), onTap: () {}, builder: (_, _) => const SizedBox(width: 32, height: 32))),
      ),
    )));
    bool on(String key) => ringOn(tester, find.byKey(Key(key)));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect((on('card'), on('edit')), (true, false));

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect((on('card'), on('edit')), (false, true));
  });

  testWidgets('disabled: not reachable by keyboard', (tester) async {
    await tester.pumpWidget(host(Pressable(
      semanticLabel: 'Save',
      builder: (_, _) => const SizedBox(width: 80, height: 40),
    )));
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<Pressable>(), isNull);
  });

  testWidgets('screen readers get the name, role and on/off state', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(host(Column(mainAxisSize: MainAxisSize.min, children: [
      Pressable(onTap: () {}, semanticLabel: 'Delete', builder: (_, _) => const SizedBox(width: 40, height: 40)),
      Pressable(onTap: () {}, semanticLabel: 'Featured project', toggled: true, builder: (_, _) => const SizedBox(width: 40, height: 40)),
    ])));

    expect(
      tester.getSemantics(find.bySemanticsLabel('Delete')),
      matchesSemantics(label: 'Delete', isButton: true, hasEnabledState: true, isEnabled: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Featured project')),
      matchesSemantics(label: 'Featured project', hasToggledState: true, isToggled: true, hasEnabledState: true, isEnabled: true, isFocusable: true, hasTapAction: true, hasFocusAction: true),
    );
    handle.dispose();
  });
}

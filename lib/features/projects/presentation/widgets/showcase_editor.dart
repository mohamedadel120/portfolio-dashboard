import 'package:flutter/material.dart';

import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/image_upload_field.dart';
import 'package:admin_dashboard/core/widgets/multiple_image_upload_field.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import 'package:admin_dashboard/core/widgets/pressable.dart';
import '../../domain/entities/showcase.dart';

/// Edits how the site shows a project (Firestore `showcase`) and what the
/// stores show for it (`storeListings`):
///  - the display mode: app screens, store artwork or the screen recording;
///  - the screens, their order and names;
///  - the inspector labels: tap a screenshot to place one at that height,
///    drag it to adjust, and name the widget it points at;
///  - each store's title, developer and icon, for the site's previews.
/// It writes straight into [showcase] and [listings].
class ShowcaseEditor extends StatefulWidget {
  final ValueNotifier<Showcase> showcase;
  final ValueNotifier<List<StoreListing>> listings;

  /// The project's gallery, offered as screens to add.
  final List<String> gallery;
  final bool hasPlay;
  final bool hasIos;
  final bool hasVideo;

  const ShowcaseEditor({
    super.key,
    required this.showcase,
    required this.listings,
    required this.gallery,
    required this.hasPlay,
    required this.hasIos,
    required this.hasVideo,
  });

  @override
  State<ShowcaseEditor> createState() => _ShowcaseEditorState();
}

class _ShowcaseEditorState extends State<ShowcaseEditor> {
  final _uploads = ValueNotifier<List<String>>([]);
  final _storeControllers = <String, ({TextEditingController title, TextEditingController developer, TextEditingController icon})>{};

  Showcase get _value => widget.showcase.value;
  set _value(Showcase v) => setState(() => widget.showcase.value = v);
  ShowcaseMode get _mode => _value.mode ?? ShowcaseMode.screens;

  @override
  void initState() {
    super.initState();
    _uploads.addListener(_takeUploads);
    for (final store in ['play', 'ios']) {
      StoreListing? l;
      for (final x in widget.listings.value) {
        if (x.store == store) l = x;
      }
      final c = (
        title: TextEditingController(text: l?.title ?? ''),
        developer: TextEditingController(text: l?.developer ?? ''),
        icon: TextEditingController(text: l?.iconUrl ?? ''),
      );
      for (final t in [c.title, c.developer, c.icon]) {
        t.addListener(_syncListings);
      }
      _storeControllers[store] = c;
    }
  }

  @override
  void dispose() {
    _uploads.dispose();
    for (final c in _storeControllers.values) {
      c.title.dispose();
      c.developer.dispose();
      c.icon.dispose();
    }
    super.dispose();
  }

  /// New uploads become screens at the end of the list.
  void _takeUploads() {
    if (_uploads.value.isEmpty) return;
    final added = [for (final url in _uploads.value) ShowcaseScreen(url: url, caption: 'Screen ${_value.screens.length + 1}')];
    _value = _value.copyWith(mode: _mode, screens: [..._value.screens, ...added]);
    WidgetsBinding.instance.addPostFrameCallback((_) => _uploads.value = []);
  }

  void _syncListings() {
    widget.listings.value = [
      for (final MapEntry(key: store, value: c) in _storeControllers.entries)
        if (c.title.text.trim().isNotEmpty)
          StoreListing(store: store, title: c.title.text.trim(), developer: c.developer.text.trim(), iconUrl: c.icon.text.trim().isEmpty ? null : c.icon.text.trim()),
    ];
  }

  void _setScreen(int i, ShowcaseScreen s) {
    final list = [..._value.screens]..[i] = s;
    _value = _value.copyWith(mode: _mode, screens: list);
  }

  void _move(int i, int by) {
    final j = i + by;
    if (j < 0 || j >= _value.screens.length) return;
    final list = [..._value.screens];
    final s = list.removeAt(i);
    list.insert(j, s);
    _value = _value.copyWith(screens: list);
  }

  void _remove(int i) => _value = _value.copyWith(screens: [..._value.screens]..removeAt(i));

  @override
  Widget build(BuildContext context) {
    final used = {for (final s in _value.screens) s.url};
    final fromGallery = [for (final g in widget.gallery) if (!used.contains(g)) g];
    return Column(
      key: const ValueKey('showcase'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Heading('On the site', 'How the project stage shows this app.'),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final m in ShowcaseMode.values)
            _Choice(label: m.label, selected: _mode == m, onTap: () => _value = _value.copyWith(mode: m)),
        ]),
        const SizedBox(height: 8),
        Text(
          switch (_mode) {
            ShowcaseMode.screens => 'Real app screens in a phone. Tap a screenshot to place an inspector label where a widget is.',
            ShowcaseMode.art => 'Store artwork in a plain frame, with no phone and no labels. For projects without app screenshots.',
            ShowcaseMode.video => widget.hasVideo
                ? 'The screen recording from Media → Video demo URL plays in the phone.'
                : 'Add the recording in Media → Video demo URL first; until then the site shows nothing here.',
          },
          style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.45),
        ),
        if (_mode != ShowcaseMode.video) ...[
          const SizedBox(height: 22),
          _Heading(_mode == ShowcaseMode.art ? 'Artwork' : 'Screens', 'In the order the site plays them. The first one leads.'),
          const SizedBox(height: 12),
          if (_value.screens.isEmpty)
            const Text('No screens yet. Add from the gallery or upload below.', style: TextStyle(fontSize: 13, color: AppColors.textTertiary)),
          for (final (i, s) in _value.screens.indexed)
            _ScreenRow(
              key: ValueKey('${s.url}#$i'),
              index: i,
              count: _value.screens.length,
              screen: s,
              labels: _mode == ShowcaseMode.screens,
              onChanged: (v) => _setScreen(i, v),
              onMove: (by) => _move(i, by),
              onRemove: () => _remove(i),
            ),
          if (fromGallery.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text('Add from the gallery', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: AppColors.ink)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final g in fromGallery)
                Tooltip(
                  message: 'Add this screen',
                  child: Pressable(
                    semanticLabel: 'Add gallery screen',
                    onTap: () => _value = _value.copyWith(mode: _mode, screens: [..._value.screens, ShowcaseScreen(url: g, caption: 'Screen ${_value.screens.length + 1}')]),
                    builder: (context, hovered) => Container(
                      width: 54,
                      height: 96,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: hovered ? AppColors.primary : AppColors.border, width: hovered ? 2 : 1)),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(g, fit: BoxFit.cover, alignment: Alignment.topCenter, errorBuilder: (_, _, _) => const SizedBox()),
                    ),
                  ),
                ),
            ]),
          ],
          const SizedBox(height: 16),
          MultipleImageUploadField(label: 'Upload screens', imagesNotifier: _uploads, storagePath: 'projects/showcase'),
        ],
        if (widget.hasPlay || widget.hasIos) ...[
          const SizedBox(height: 26),
          const _Heading('Store listings', 'As each store shows the app: used by the preview card on the site.'),
          for (final store in ['play', 'ios'])
            if (store == 'play' ? widget.hasPlay : widget.hasIos) ...[
              const SizedBox(height: 14),
              Text(store == 'play' ? 'Google Play' : 'App Store', style: AppFonts.monoStyle(fontSize: 12, color: AppColors.primary)),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(child: _input(_storeControllers[store]!.title, 'App name on the store')),
                const SizedBox(width: 12),
                Expanded(child: _input(_storeControllers[store]!.developer, 'Developer')),
              ]),
              const SizedBox(height: 10),
              ImageUploadField(label: 'Store icon', controller: _storeControllers[store]!.icon, storagePath: 'projects/store-icons'),
            ],
        ],
      ],
    );
  }

  Widget _input(TextEditingController c, String label) => TextField(
        controller: c,
        style: const TextStyle(color: AppColors.ink, fontSize: 14),
        decoration: InputDecoration(labelText: label, isDense: true),
      );
}

class _Heading extends StatelessWidget {
  final String title;
  final String sub;
  const _Heading(this.title, this.sub);

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.ink)),
        const SizedBox(height: 2),
        Text(sub, style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
      ]);
}

class _Choice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Choice({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => Pressable(
        onTap: onTap,
        semanticLabel: label,
        toggled: selected,
        focusRadius: 999,
        builder: (context, hovered) => AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.fast),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primarySoft : (hovered ? AppColors.background : AppColors.surface),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border),
          ),
          child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textSecondary)),
        ),
      );
}

/// One screen: the screenshot with its labels (tap to add, drag to move),
/// its name, the label list, and order/remove controls.
class _ScreenRow extends StatefulWidget {
  final int index;
  final int count;
  final ShowcaseScreen screen;
  final bool labels;
  final ValueChanged<ShowcaseScreen> onChanged;
  final ValueChanged<int> onMove;
  final VoidCallback onRemove;

  const _ScreenRow({
    super.key,
    required this.index,
    required this.count,
    required this.screen,
    required this.labels,
    required this.onChanged,
    required this.onMove,
    required this.onRemove,
  });

  @override
  State<_ScreenRow> createState() => _ScreenRowState();
}

class _ScreenRowState extends State<_ScreenRow> {
  static const _w = 150.0;
  static const _h = _w * 19.5 / 9;
  late final _caption = TextEditingController(text: widget.screen.caption);
  final _labelControllers = <TextEditingController>[];
  final _focus = <FocusNode>[];

  @override
  void initState() {
    super.initState();
    _caption.addListener(() => widget.onChanged(widget.screen.copyWith(caption: _caption.text)));
    for (final n in widget.screen.notes) {
      _addController(n.label);
    }
  }

  void _addController(String text) {
    final c = TextEditingController(text: text);
    final i = _labelControllers.length;
    c.addListener(() {
      final notes = [...widget.screen.notes];
      if (i < notes.length) {
        notes[i] = notes[i].copyWith(label: c.text);
        widget.onChanged(widget.screen.copyWith(notes: notes));
      }
    });
    _labelControllers.add(c);
    _focus.add(FocusNode());
  }

  @override
  void dispose() {
    _caption.dispose();
    for (final c in _labelControllers) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    super.dispose();
  }

  void _addAt(double dy) {
    final y = (dy / _h * 100).round().clamp(0, 100);
    _addController('');
    widget.onChanged(widget.screen.copyWith(notes: [...widget.screen.notes, ScreenNote(label: '', y: y)]));
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.last.requestFocus());
  }

  void _setY(int i, int y) {
    final notes = [...widget.screen.notes]..[i] = widget.screen.notes[i].copyWith(y: y.clamp(0, 100));
    widget.onChanged(widget.screen.copyWith(notes: notes));
  }

  void _removeNote(int i) {
    final notes = [...widget.screen.notes]..removeAt(i);
    _labelControllers.removeAt(i).dispose();
    _focus.removeAt(i).dispose();
    // Re-bind listeners to the new positions.
    final texts = [for (final c in _labelControllers) c.text];
    for (final c in _labelControllers) {
      c.dispose();
    }
    for (final f in _focus) {
      f.dispose();
    }
    _labelControllers.clear();
    _focus.clear();
    widget.onChanged(widget.screen.copyWith(notes: notes));
    for (final t in texts) {
      _addController(t);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notes = widget.screen.notes;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The screenshot, with the labels drawn where they will point.
          // With the screen reader tree on (web), a tap on a semantics node
          // arrives as a tap at its centre, so the screenshot stays out of
          // that tree and gets real pointer positions. Keyboard and screen
          // reader users add labels with the button and type the height.
          Semantics(
            label: 'Screenshot ${widget.index + 1}',
            image: true,
            child: MouseRegion(
              cursor: widget.labels ? SystemMouseCursors.precise : SystemMouseCursors.basic,
              child: GestureDetector(
                excludeFromSemantics: true,
                onTapUp: widget.labels ? (d) => _addAt(d.localPosition.dy) : null,
                child: SizedBox(
                  width: _w,
                  height: _h,
                  child: Stack(clipBehavior: Clip.none, children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(widget.screen.url, fit: BoxFit.cover, alignment: Alignment.topCenter, errorBuilder: (_, _, _) => const ColoredBox(color: AppColors.border)),
                      ),
                    ),
                    if (widget.labels)
                      for (final (i, n) in notes.indexed)
                        Positioned(
                          left: 0,
                          right: 0,
                          top: n.y / 100 * _h - 9,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            excludeFromSemantics: true,
                            onVerticalDragUpdate: (d) => _setY(i, ((n.y / 100 * _h + d.delta.dy) / _h * 100).round()),
                            child: MouseRegion(
                              cursor: SystemMouseCursors.resizeUpDown,
                              child: Row(children: [
                                Expanded(child: Container(height: 1.5, color: AppColors.primary)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(5), border: Border.all(color: AppColors.primary)),
                                  child: Text(n.label.isEmpty ? '…' : n.label, style: AppFonts.monoStyle(fontSize: 9.5, color: AppColors.primary)),
                                ),
                              ]),
                            ),
                          ),
                        ),
                  ]),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _caption,
                      style: const TextStyle(color: AppColors.ink, fontSize: 14),
                      decoration: const InputDecoration(labelText: 'Screen name', isDense: true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconActionButton(icon: Icons.arrow_upward_rounded, tooltip: 'Move up', onPressed: widget.index > 0 ? () => widget.onMove(-1) : null),
                  const SizedBox(width: 6),
                  IconActionButton(icon: Icons.arrow_downward_rounded, tooltip: 'Move down', onPressed: widget.index < widget.count - 1 ? () => widget.onMove(1) : null),
                  const SizedBox(width: 6),
                  IconActionButton(icon: Icons.delete_outline_rounded, tooltip: 'Remove screen', destructive: true, onPressed: widget.onRemove),
                ]),
                if (widget.labels) ...[
                  const SizedBox(height: 14),
                  Row(children: [
                    Expanded(
                      child: Text(
                        notes.isEmpty ? 'No labels yet: tap the screenshot where a widget is.' : 'Labels: tap the screenshot to add, drag a label to move it.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                    IconActionButton(icon: Icons.add_rounded, tooltip: 'Add label', onPressed: () => _addAt(_h / 2)),
                  ]),
                  for (final (i, n) in notes.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(children: [
                        SizedBox(width: 84, child: _HeightField(value: n.y, onChanged: (y) => _setY(i, y))),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: i < _labelControllers.length ? _labelControllers[i] : null,
                            focusNode: i < _focus.length ? _focus[i] : null,
                            style: AppFonts.monoStyle(fontSize: 13, color: AppColors.ink),
                            decoration: const InputDecoration(hintText: 'WidgetName, e.g. CartBar', isDense: true),
                          ),
                        ),
                        const SizedBox(width: 6),
                        IconActionButton(icon: Icons.close_rounded, tooltip: 'Remove label', onPressed: () => _removeNote(i)),
                      ]),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A label's height on the screen, 0-100, as a small number field: the
/// keyboard way to place a label, and a precise one for everybody.
class _HeightField extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _HeightField({required this.value, required this.onChanged});

  @override
  State<_HeightField> createState() => _HeightFieldState();
}

class _HeightFieldState extends State<_HeightField> {
  late final _c = TextEditingController(text: '${widget.value}');

  @override
  void didUpdateWidget(_HeightField old) {
    super.didUpdateWidget(old);
    // Follow drags on the screenshot without fighting the user's typing.
    if (int.tryParse(_c.text) != widget.value) _c.text = '${widget.value}';
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => TextField(
        controller: _c,
        keyboardType: TextInputType.number,
        style: AppFonts.monoStyle(fontSize: 13, color: AppColors.ink),
        decoration: const InputDecoration(suffixText: '%', isDense: true, labelText: 'Height'),
        onChanged: (v) {
          final y = int.tryParse(v.trim());
          if (y != null) widget.onChanged(y.clamp(0, 100));
        },
      );
}

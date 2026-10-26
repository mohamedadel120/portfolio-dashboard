import 'package:equatable/equatable.dart';

/// How a project is shown on the site's project stage (Firestore
/// `showcase`): which screens, in what order, and the inspector labels on
/// each. Read by the site's design D.
enum ShowcaseMode {
  /// Real app screens in a phone, with inspector labels.
  screens('screens', 'App screens'),

  /// Store artwork only: a plain frame, no device claims, no labels.
  art('art', 'Store artwork'),

  /// The project's screen recording (`videoUrl`) playing in the phone.
  video('video', 'Screen recording');

  const ShowcaseMode(this.key, this.label);
  final String key;
  final String label;

  static ShowcaseMode? fromKey(Object? key) {
    for (final m in values) {
      if (m.key == key) return m;
    }
    return null;
  }
}

/// One inspector label: the widget's name and its height on the screen as a
/// share of the screen (0 top, 100 bottom).
class ScreenNote extends Equatable {
  final String label;
  final int y;
  const ScreenNote({required this.label, required this.y});

  ScreenNote copyWith({String? label, int? y}) => ScreenNote(label: label ?? this.label, y: y ?? this.y);

  @override
  List<Object?> get props => [label, y];
}

class ShowcaseScreen extends Equatable {
  final String url;
  final String caption;
  final List<ScreenNote> notes;
  const ShowcaseScreen({required this.url, this.caption = '', this.notes = const []});

  ShowcaseScreen copyWith({String? url, String? caption, List<ScreenNote>? notes}) =>
      ShowcaseScreen(url: url ?? this.url, caption: caption ?? this.caption, notes: notes ?? this.notes);

  @override
  List<Object?> get props => [url, caption, notes];
}

class Showcase extends Equatable {
  final ShowcaseMode? mode;
  final List<ShowcaseScreen> screens;
  const Showcase({this.mode, this.screens = const []});

  bool get isEmpty => mode == null && screens.isEmpty;

  Showcase copyWith({ShowcaseMode? mode, List<ShowcaseScreen>? screens}) =>
      Showcase(mode: mode ?? this.mode, screens: screens ?? this.screens);

  /// Unknown or missing data gives an empty showcase rather than an error.
  factory Showcase.fromJson(Object? raw) {
    if (raw is! Map) return const Showcase();
    return Showcase(
      mode: ShowcaseMode.fromKey(raw['mode']),
      screens: [
        if (raw['screens'] case final List list)
          for (final s in list)
            if (s is Map && s['url'] is String && (s['url'] as String).trim().isNotEmpty)
              ShowcaseScreen(
                url: (s['url'] as String).trim(),
                caption: s['caption'] is String ? (s['caption'] as String).trim() : '',
                notes: [
                  if (s['notes'] case final List notes)
                    for (final n in notes)
                      if (n is Map && n['label'] is String && (n['label'] as String).trim().isNotEmpty && n['y'] is num)
                        ScreenNote(label: (n['label'] as String).trim(), y: (n['y'] as num).toInt().clamp(0, 100)),
                ],
              ),
      ],
    );
  }

  /// Null when empty, so a project never set up stays without the field.
  Map<String, dynamic>? toJson() => isEmpty
      ? null
      : {
          'mode': (mode ?? ShowcaseMode.screens).key,
          'screens': [
            for (final s in screens)
              {
                'url': s.url,
                'caption': s.caption.trim().isEmpty ? 'Screen' : s.caption.trim(),
                'notes': [for (final n in s.notes) if (n.label.trim().isNotEmpty) {'label': n.label.trim(), 'y': n.y}],
              },
          ],
        };

  @override
  List<Object?> get props => [mode, screens];
}

/// What a store shows for the app (Firestore `storeListings`), for the
/// site's store preview cards.
class StoreListing extends Equatable {
  /// 'play' or 'ios'.
  final String store;
  final String title;
  final String developer;
  final String? iconUrl;
  const StoreListing({required this.store, required this.title, this.developer = '', this.iconUrl});

  StoreListing copyWith({String? title, String? developer, String? iconUrl}) =>
      StoreListing(store: store, title: title ?? this.title, developer: developer ?? this.developer, iconUrl: iconUrl ?? this.iconUrl);

  static List<StoreListing> listFromJson(Object? raw) => [
        if (raw case final List list)
          for (final l in list)
            if (l is Map && (l['store'] == 'play' || l['store'] == 'ios') && l['title'] is String && (l['title'] as String).trim().isNotEmpty)
              StoreListing(
                store: l['store'] as String,
                title: (l['title'] as String).trim(),
                developer: l['developer'] is String ? (l['developer'] as String).trim() : '',
                iconUrl: l['iconUrl'] is String && (l['iconUrl'] as String).trim().isNotEmpty ? (l['iconUrl'] as String).trim() : null,
              ),
      ];

  Map<String, dynamic> toJson() => {
        'store': store,
        'title': title.trim(),
        'developer': developer.trim(),
        if (iconUrl != null && iconUrl!.trim().isNotEmpty) 'iconUrl': iconUrl!.trim(),
      };

  @override
  List<Object?> get props => [store, title, developer, iconUrl];
}

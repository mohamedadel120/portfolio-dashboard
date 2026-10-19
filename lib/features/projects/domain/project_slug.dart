/// Case-study URLs (`/projects/<slug>`), using the same rules as the
/// portfolio site (jaspr_site/lib/data/project_slug.dart). Keep in sync.
class ProjectSlug {
  static const String siteOrigin = 'https://muhammed-adel.web.app';

  static final RegExp _mobileApp = RegExp(r'\bmobile app\b');
  static final RegExp _nonAlnum = RegExp(r'[^a-z0-9]+');
  static final RegExp _edgeDashes = RegExp(r'^-+|-+$');

  /// The slug the site generates from a project title: lowercase; drop the
  /// words "mobile app"; every run of characters other than a-z/0-9 becomes
  /// "-"; trim leading/trailing "-"; an empty result becomes "project".
  ///
  /// "Gomla Mobile App" -> "gomla", "DrugZa - TagPharma" -> "drugza-tagpharma".
  static String fromTitle(String title) {
    final slug = title
        .toLowerCase()
        .replaceAll(_mobileApp, ' ')
        .replaceAll(_nonAlnum, '-')
        .replaceAll(_edgeDashes, '');
    return slug.isEmpty ? 'project' : slug;
  }

  /// The owner's own slug cleaned the way the site cleans it, or null when
  /// it is blank or has nothing usable.
  static String? clean(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final cleaned = raw
        .trim()
        .toLowerCase()
        .replaceAll(_nonAlnum, '-')
        .replaceAll(_edgeDashes, '');
    return cleaned.isEmpty ? null : cleaned;
  }

  /// The slug for one project: the owner's (cleaned) when set, otherwise
  /// one made from the title. Does not account for duplicates; see [unique].
  static String effective({String? slug, required String title}) =>
      clean(slug) ?? fromTitle(title);

  /// Gives every project a unique slug exactly like the site does: the site
  /// lists projects by `sortOrder` with featured ones first, and a repeated
  /// slug gets `-2`, `-3`, ... in that order. Returns one slug per input, in
  /// the input order.
  static List<String> unique(
    List<({String title, String? slug, bool featured, int sortOrder})>
        projects,
  ) {
    final indexed = projects.indexed.toList()
      ..sort((a, b) {
        final byOrder = a.$2.sortOrder.compareTo(b.$2.sortOrder);
        return byOrder != 0 ? byOrder : a.$1.compareTo(b.$1);
      });
    final siteOrder = [
      ...indexed.where((e) => e.$2.featured),
      ...indexed.where((e) => !e.$2.featured),
    ];
    final taken = <String>{};
    final result = List<String>.filled(projects.length, '');
    for (final (index, p) in siteOrder) {
      final base = effective(slug: p.slug, title: p.title);
      var candidate = base;
      for (var n = 2; taken.contains(candidate); n++) {
        candidate = '$base-$n';
      }
      taken.add(candidate);
      result[index] = candidate;
    }
    return result;
  }

  /// Full case-study URL for a slug.
  static String urlFor(String slug) => '$siteOrigin/projects/$slug';
}

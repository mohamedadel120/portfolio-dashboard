import 'package:flutter_test/flutter_test.dart';
import 'package:admin_dashboard/features/projects/domain/project_slug.dart';

void main() {
  group('ProjectSlug.fromTitle (same rules as the site)', () {
    test('drops "mobile app" and punctuation', () {
      expect(ProjectSlug.fromTitle('Gomla Mobile App'), 'gomla');
      expect(ProjectSlug.fromTitle('DrugZa - TagPharma'), 'drugza-tagpharma');
      expect(ProjectSlug.fromTitle('to-let'), 'to-let');
      expect(ProjectSlug.fromTitle('  ureva  '), 'ureva');
      expect(ProjectSlug.fromTitle('Stock MOBILE APP'), 'stock');
    });

    test('keeps "mobile app" inside other words alone', () {
      expect(ProjectSlug.fromTitle('Automobile Apps'), 'automobile-apps');
    });

    test('a title with nothing usable becomes "project"', () {
      expect(ProjectSlug.fromTitle(''), 'project');
      expect(ProjectSlug.fromTitle('جملة'), 'project');
      expect(ProjectSlug.fromTitle('Mobile App'), 'project');
    });
  });

  group('ProjectSlug.clean / effective', () {
    test('the owner slug is cleaned like the site cleans it', () {
      expect(ProjectSlug.clean(' Gomla Beauty '), 'gomla-beauty');
      expect(ProjectSlug.clean('---'), isNull);
      expect(ProjectSlug.clean('   '), isNull);
      expect(ProjectSlug.clean(null), isNull);
    });

    test('an empty slug falls back to the title', () {
      expect(ProjectSlug.effective(slug: '', title: 'Gomla Mobile App'), 'gomla');
      expect(ProjectSlug.effective(slug: 'gomla-app', title: 'Gomla'), 'gomla-app');
    });

    test('builds the case study URL', () {
      expect(ProjectSlug.urlFor('gomla'),
          'https://muhammed-adel.web.app/projects/gomla');
    });
  });

  test('unique() matches the site: featured first, repeats get -2, -3', () {
    final slugs = ProjectSlug.unique([
      (title: 'Stock', slug: null, featured: false, sortOrder: 0),
      (title: 'Stock Mobile App', slug: null, featured: false, sortOrder: 1),
      (title: 'Gomla', slug: ' Gomla Beauty ', featured: false, sortOrder: 2),
      (title: 'جملة', slug: null, featured: false, sortOrder: 3),
      (title: 'عربي', slug: null, featured: false, sortOrder: 4),
    ]);
    expect(slugs, ['stock', 'stock-2', 'gomla-beauty', 'project', 'project-2']);

    // A featured project is listed first on the site, so it keeps the plain
    // slug and the earlier one gets the suffix. Order of results follows input.
    final withFeatured = ProjectSlug.unique([
      (title: 'Stock', slug: null, featured: false, sortOrder: 0),
      (title: 'Stock', slug: null, featured: true, sortOrder: 1),
    ]);
    expect(withFeatured, ['stock-2', 'stock']);
  });
}

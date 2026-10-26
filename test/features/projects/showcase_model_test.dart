import 'package:admin_dashboard/features/projects/data/models/project_model.dart';
import 'package:admin_dashboard/features/projects/domain/entities/showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final json = {
    'title': 'Stock Mobile App',
    'description': 'd',
    'tech': ['Flutter'],
    'downloads': '10,000+',
    'showcase': {
      'mode': 'screens',
      'screens': [
        {'url': 'https://img.test/1.webp', 'caption': 'Home', 'notes': [{'label': 'CartBar', 'y': 93}, {'label': ' ', 'y': 4}]},
        {'caption': 'no url'},
      ],
    },
    'storeListings': [
      {'store': 'play', 'title': 'Stock', 'developer': 'Stock Developer', 'iconUrl': 'https://img.test/i.webp'},
      {'store': 'other', 'title': 'x'},
    ],
  };

  test('reads the showcase and store listings, dropping broken entries', () {
    final p = ProjectModel.fromJson(json, 'id');
    expect(p.showcase.mode, ShowcaseMode.screens);
    expect(p.showcase.screens.single.notes.single, const ScreenNote(label: 'CartBar', y: 93));
    expect(p.storeListings.single.developer, 'Stock Developer');
  });

  test('saving writes them back unchanged (nothing lost on an edit)', () {
    final out = ProjectModel.fromJson(json, 'id').toJson();
    expect(out['showcase'], {
      'mode': 'screens',
      'screens': [
        {'url': 'https://img.test/1.webp', 'caption': 'Home', 'notes': [{'label': 'CartBar', 'y': 93}]},
      ],
    });
    expect(out['storeListings'], [
      {'store': 'play', 'title': 'Stock', 'developer': 'Stock Developer', 'iconUrl': 'https://img.test/i.webp'},
    ]);
  });

  test('a project never set up stays without the fields', () {
    final out = ProjectModel.fromJson({'title': 'Old', 'tech': <String>[]}, 'id').toJson();
    expect(out['showcase'], isNull);
    expect(out['storeListings'], isNull);
  });
}

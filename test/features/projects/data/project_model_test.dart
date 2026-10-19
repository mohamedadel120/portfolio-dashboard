import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:admin_dashboard/features/projects/data/models/project_model.dart';
import 'package:admin_dashboard/features/projects/domain/entities/project_entity.dart';

void main() {
  const full = ProjectModel(
    id: 'p1',
    title: 'Gomla Mobile App',
    description: 'Marketplace',
    tech: ['Flutter'],
    color: Color(0xFFE4572E),
    downloads: '10,000+',
    sortOrder: 3,
    featured: true,
    highlight: 'Rated 4.8',
    problem: 'P',
    role: 'R',
    outcome: 'O',
    slug: 'gomla',
  );

  test('new fields survive toJson -> fromJson', () {
    final back = ProjectModel.fromJson(full.toJson(), 'p1');
    expect(back, full);
    expect(back.featured, isTrue);
    expect(back.highlight, 'Rated 4.8');
    expect(back.problem, 'P');
    expect(back.role, 'R');
    expect(back.outcome, 'O');
    expect(back.slug, 'gomla');
  });

  test('fromEntity keeps the new fields', () {
    const entity = Project(
      id: 'p2',
      title: 't',
      description: 'd',
      tech: [],
      color: Color(0xFF000000),
      downloads: '',
      featured: true,
      highlight: 'h',
      problem: 'p',
      role: 'r',
      outcome: 'o',
      slug: 's',
    );
    final m = ProjectModel.fromEntity(entity);
    expect(m.props, entity.props);
  });

  test('blank strings are written as null so the site treats them as absent', () {
    const blanks = ProjectModel(
      id: 'p3',
      title: 't',
      description: 'd',
      tech: [],
      color: Color(0xFF000000),
      downloads: '',
      highlight: '   ',
      problem: '',
      role: ' ',
      outcome: '',
      slug: '',
    );
    final json = blanks.toJson();
    for (final key in ['highlight', 'problem', 'role', 'outcome', 'slug']) {
      expect(json.containsKey(key), isTrue, reason: key);
      expect(json[key], isNull, reason: key);
    }
    expect(json['featured'], isFalse);
  });

  test('reads documents written before the new fields existed', () {
    final m = ProjectModel.fromJson({
      'title': 'Old',
      'description': 'd',
      'tech': ['Dart'],
      'color': 0xFF00D9FF,
      'downloads': '1k',
    }, 'old');
    expect(m.featured, isFalse);
    expect(m.highlight, isNull);
    expect(m.slug, isNull);
  });

  test('accepts the flag and colour formats the site accepts', () {
    final m = ProjectModel.fromJson({
      'title': 'x',
      'featured': 'TRUE',
      'color': '0xFF155E75',
      'highlight': '  trimmed  ',
    }, 'x');
    expect(m.featured, isTrue);
    expect(m.color, const Color(0xFF155E75));
    expect(m.highlight, 'trimmed');
  });

  test('equality includes the new fields', () {
    final other = ProjectModel.fromJson({...full.toJson(), 'outcome': 'X'}, 'p1');
    expect(other == full, isFalse);
  });
}

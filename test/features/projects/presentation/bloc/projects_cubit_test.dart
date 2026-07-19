// ignore_for_file: avoid_implementing_value_types

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_dashboard/features/projects/data/datasources/projects_remote_data_source.dart';
import 'package:admin_dashboard/features/projects/data/models/project_model.dart';
import 'package:admin_dashboard/features/projects/data/repositories/projects_repository.dart';
import 'package:admin_dashboard/features/projects/presentation/bloc/projects_cubit.dart';
import 'package:admin_dashboard/features/projects/presentation/bloc/projects_state.dart';

// ── Configurable fake data source ─────────────────────────────────────────────

class _FakeDataSource implements ProjectsRemoteDataSource {
  List<ProjectModel> projectsToReturn;
  Exception? errorToThrow;

  _FakeDataSource({this.projectsToReturn = const [], this.errorToThrow});

  @override
  Future<List<ProjectModel>> getProjects() async {
    if (errorToThrow != null) throw errorToThrow!;
    return projectsToReturn;
  }

  @override
  Future<void> addProject(ProjectModel project) async {
    if (errorToThrow != null) throw errorToThrow!;
    projectsToReturn = [...projectsToReturn, project];
  }

  @override
  Future<void> updateProject(ProjectModel project) async {
    if (errorToThrow != null) throw errorToThrow!;
    projectsToReturn = [
      for (final p in projectsToReturn)
        if (p.id == project.id) project else p,
    ];
  }

  @override
  Future<void> deleteProject(String id) async {
    if (errorToThrow != null) throw errorToThrow!;
    projectsToReturn = projectsToReturn.where((p) => p.id != id).toList();
  }
}

// ── Test fixtures ──────────────────────────────────────────────────────────────

const _projectA = ProjectModel(
  id: 'a1',
  title: 'Alpha',
  description: 'First project',
  tech: ['Flutter', 'Firebase'],
  color: Colors.blue,
  downloads: '1K+',
);

const _projectB = ProjectModel(
  id: 'b2',
  title: 'Beta',
  description: 'Second project',
  tech: ['React', 'Node'],
  color: Colors.green,
  downloads: '5K+',
);

// ── Helper ─────────────────────────────────────────────────────────────────────

/// Collects all states emitted while [action] runs.
/// [pumpEventQueue] drains pending microtasks so deferred stream events
/// (e.g. from the unawaited fetchProjects() re-fetch inside mutations)
/// are delivered before the subscription is cancelled.
Future<List<ProjectsState>> _collectStates(
  ProjectsCubit cubit,
  Future<void> Function() action,
) async {
  final states = <ProjectsState>[];
  final sub = cubit.stream.listen(states.add);
  await action();
  // Pump the event queue so any unawaited Futures inside the cubit
  // (e.g. the re-fetch after a successful mutation) finish delivering
  // their states before we cancel the subscription.
  await pumpEventQueue();
  await sub.cancel();
  return states;
}

// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('ProjectsCubit', () {
    // ── fetchProjects ──────────────────────────────────────────────────────────

    group('fetchProjects()', () {
      test('starts in ProjectsInitial', () {
        final ds = _FakeDataSource();
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));
        expect(cubit.state, isA<ProjectsInitial>());
      });

      test('emits [Loading, Loaded] with returned projects on success', () async {
        final ds = _FakeDataSource(projectsToReturn: [_projectA, _projectB]);
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, cubit.fetchProjects);

        expect(states, hasLength(2));
        expect(states[0], isA<ProjectsLoading>());
        final loaded = states[1] as ProjectsLoaded;
        expect(loaded.projects.length, 2);
        expect(loaded.projects.first.id, 'a1');
      });

      test('emits [Loading, Loaded([])] when no projects exist', () async {
        final ds = _FakeDataSource();
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, cubit.fetchProjects);

        expect(states[0], isA<ProjectsLoading>());
        expect((states[1] as ProjectsLoaded).projects, isEmpty);
      });

      test('emits [Loading, Error] when data source throws', () async {
        final ds = _FakeDataSource(errorToThrow: Exception('network timeout'));
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, cubit.fetchProjects);

        expect(states[0], isA<ProjectsLoading>());
        expect(states[1], isA<ProjectsError>());
        expect((states[1] as ProjectsError).message, contains('network timeout'));
      });
    });

    // ── addProject ─────────────────────────────────────────────────────────────
    //
    // On success: addProject emits Loading, then calls fetchProjects() without
    // awaiting it.  fetchProjects() emits another Loading then Loaded.
    // Total sequence: [Loading, Loading, Loaded].

    group('addProject()', () {
      test('emits [Loading, Loading, Loaded] and persists the new project on success', () async {
        final ds = _FakeDataSource(projectsToReturn: [_projectA]);
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, () => cubit.addProject(_projectB));

        // First Loading from addProject, second Loading + Loaded from re-fetch
        expect(states.first, isA<ProjectsLoading>());
        final loaded = states.last as ProjectsLoaded;
        expect(loaded.projects.any((p) => p.id == 'b2'), isTrue);
      });

      test('emits [Loading, Error] when data source throws', () async {
        final ds = _FakeDataSource(errorToThrow: Exception('write failed'));
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, () => cubit.addProject(_projectA));

        expect(states, hasLength(2));
        expect(states[0], isA<ProjectsLoading>());
        expect(states[1], isA<ProjectsError>());
        expect((states[1] as ProjectsError).message, contains('write failed'));
      });
    });

    // ── updateProject ──────────────────────────────────────────────────────────

    group('updateProject()', () {
      test('emits [Loading, Loading, Loaded] with updated project on success', () async {
        const updated = ProjectModel(
          id: 'a1',
          title: 'Alpha v2',
          description: 'Updated',
          tech: ['Flutter'],
          color: Colors.blue,
          downloads: '2K+',
        );

        final ds = _FakeDataSource(projectsToReturn: [_projectA]);
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, () => cubit.updateProject(updated));

        expect(states.first, isA<ProjectsLoading>());
        final loaded = states.last as ProjectsLoaded;
        expect(loaded.projects.first.title, 'Alpha v2');
      });

      test('emits [Loading, Error] when data source throws', () async {
        // Use a source that only fails on write, not on read, to isolate the mutation error.
        final ds = _FailOnWriteDataSource(existing: [_projectA]);
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, () => cubit.updateProject(_projectA));

        expect(states, hasLength(2));
        expect(states[0], isA<ProjectsLoading>());
        expect(states[1], isA<ProjectsError>());
      });
    });

    // ── deleteProject ──────────────────────────────────────────────────────────

    group('deleteProject()', () {
      test('emits [Loading, Loading, Loaded] without the deleted project on success', () async {
        final ds = _FakeDataSource(projectsToReturn: [_projectA, _projectB]);
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, () => cubit.deleteProject('a1'));

        expect(states.first, isA<ProjectsLoading>());
        final loaded = states.last as ProjectsLoaded;
        expect(loaded.projects.any((p) => p.id == 'a1'), isFalse);
        expect(loaded.projects.any((p) => p.id == 'b2'), isTrue);
      });

      test('emits [Loading, Error] when data source throws', () async {
        final ds = _FailOnWriteDataSource(existing: [_projectA]);
        final cubit = ProjectsCubit(repository: ProjectsRepository(remoteDataSource: ds));

        final states = await _collectStates(cubit, () => cubit.deleteProject('a1'));

        expect(states, hasLength(2));
        expect(states[0], isA<ProjectsLoading>());
        expect(states[1], isA<ProjectsError>());
      });
    });

    // ── state equality ─────────────────────────────────────────────────────────

    group('state equality (Equatable)', () {
      test('ProjectsLoaded with the same list are equal', () {
        const a = ProjectsLoaded([_projectA]);
        const b = ProjectsLoaded([_projectA]);
        expect(a, equals(b));
      });

      test('ProjectsError with the same message are equal', () {
        const a = ProjectsError('oops');
        const b = ProjectsError('oops');
        expect(a, equals(b));
      });

      test('ProjectsLoaded and ProjectsError are not equal', () {
        const a = ProjectsLoaded([_projectA]);
        const b = ProjectsError('oops');
        expect(a, isNot(equals(b)));
      });
    });
  });
}

// ── Fake that fails only on writes (reads succeed) ────────────────────────────
// Used for update/delete error tests so the cubit emits Error instead of
// triggering a successful re-fetch after the failed mutation.

class _FailOnWriteDataSource implements ProjectsRemoteDataSource {
  final List<ProjectModel> existing;
  _FailOnWriteDataSource({required this.existing});

  @override
  Future<List<ProjectModel>> getProjects() async => existing;

  @override
  Future<void> addProject(ProjectModel project) async =>
      throw Exception('write permission denied');

  @override
  Future<void> updateProject(ProjectModel project) async =>
      throw Exception('write permission denied');

  @override
  Future<void> deleteProject(String id) async =>
      throw Exception('write permission denied');
}

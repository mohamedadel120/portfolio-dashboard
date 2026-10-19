// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:admin_dashboard/features/profile_info/data/datasources/profile_info_remote_data_source.dart';
import 'package:admin_dashboard/features/profile_info/data/models/profile_info_model.dart';

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class _MockDoc extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  setUpAll(() => registerFallbackValue(SetOptions(merge: true)));

  test('saving profile info merges, so fields the dashboard does not know '
      '(downloadsCount, ratings, ...) are kept', () async {
    final firestore = _MockFirestore();
    final collection = _MockCollection();
    final mainDoc = _MockDoc();
    final techDoc = _MockDoc();
    when(() => firestore.collection('profile_info')).thenReturn(collection);
    when(() => collection.doc('main')).thenReturn(mainDoc);
    when(() => collection.doc('tech_stack')).thenReturn(techDoc);
    when(() => mainDoc.set(any(), any())).thenAnswer((_) async {});
    when(() => techDoc.set(any(), any())).thenAnswer((_) async {});

    const profile = ProfileInfoModel(
      name: 'n',
      title: 't',
      subtitle: 's',
      description: 'd',
      professionalSummary: 'p',
      email: 'e',
      phone: 'ph',
      location: 'l',
      cvUrl: 'c',
      techStack: ['Flutter'],
    );
    await ProfileInfoRemoteDataSource(firestore: firestore)
        .updateProfileInfo(profile);

    for (final doc in [mainDoc, techDoc]) {
      final options =
          verify(() => doc.set(any(), captureAny())).captured.single
              as SetOptions;
      expect(options.merge, isTrue);
    }
    verifyNever(() => mainDoc.set(any()));
    verifyNever(() => techDoc.set(any()));
  });
}

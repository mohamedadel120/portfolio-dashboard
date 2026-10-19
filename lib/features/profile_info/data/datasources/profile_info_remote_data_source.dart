import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/profile_info_model.dart';

class ProfileInfoRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProfileInfoRemoteDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<ProfileInfoModel> getProfileInfo() async {
    final mainDoc = await _firestore.collection('profile_info').doc('main').get();
    final techStackDoc = await _firestore.collection('profile_info').doc('tech_stack').get();

    final mainJson = mainDoc.data() ?? {};
    final items = (techStackDoc.data()?['items'] as List<dynamic>?) ?? [];

    return ProfileInfoModel.fromJson(mainJson, items);
  }

  /// Merge, never replace: the site may store fields on these documents
  /// that this model does not know (for example `downloadsCount` or
  /// `ratings`), and a plain `set()` would delete them.
  static final SetOptions writeOptions = SetOptions(merge: true);

  Future<void> updateProfileInfo(ProfileInfoModel profile) async {
    await _firestore
        .collection('profile_info')
        .doc('main')
        .set(profile.toMainJson(), writeOptions);
    await _firestore
        .collection('profile_info')
        .doc('tech_stack')
        .set(profile.toTechStackJson(), writeOptions);
  }
}

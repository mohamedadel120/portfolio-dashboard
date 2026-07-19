import '../../domain/entities/profile_info_entity.dart';
import '../datasources/profile_info_remote_data_source.dart';
import '../models/profile_info_model.dart';

class ProfileInfoRepository {
  final ProfileInfoRemoteDataSource _remoteDataSource;

  ProfileInfoRepository({required ProfileInfoRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<ProfileInfo> getProfileInfo() async {
    return await _remoteDataSource.getProfileInfo();
  }

  Future<void> updateProfileInfo(ProfileInfoModel profile) async {
    await _remoteDataSource.updateProfileInfo(profile);
  }
}

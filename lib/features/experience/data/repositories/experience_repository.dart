import '../../domain/entities/experience_entity.dart';
import '../datasources/experience_remote_data_source.dart';
import '../models/experience_model.dart';

class ExperienceRepository {
  final ExperienceRemoteDataSource _remoteDataSource;

  ExperienceRepository({required ExperienceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<List<Experience>> getExperiences() async {
    return await _remoteDataSource.getExperiences();
  }

  Future<void> addExperience(ExperienceModel experience) async {
    await _remoteDataSource.addExperience(experience);
  }

  Future<void> updateExperience(ExperienceModel experience) async {
    await _remoteDataSource.updateExperience(experience);
  }

  Future<void> deleteExperience(String id) async {
    await _remoteDataSource.deleteExperience(id);
  }
}

import '../../domain/entities/expertise_entity.dart';
import '../datasources/expertise_remote_data_source.dart';
import '../models/expertise_model.dart';

class ExpertiseRepository {
  final ExpertiseRemoteDataSource _remoteDataSource;

  ExpertiseRepository({required ExpertiseRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<List<Expertise>> getExpertise() async {
    return await _remoteDataSource.getExpertise();
  }

  Future<void> addExpertise(ExpertiseModel expertise) async {
    await _remoteDataSource.addExpertise(expertise);
  }

  Future<void> updateExpertise(ExpertiseModel expertise) async {
    await _remoteDataSource.updateExpertise(expertise);
  }

  Future<void> deleteExpertise(String id) async {
    await _remoteDataSource.deleteExpertise(id);
  }
}

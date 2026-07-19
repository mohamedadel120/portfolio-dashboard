import '../../domain/entities/why_choose_me_entity.dart';
import '../datasources/why_choose_me_remote_data_source.dart';
import '../models/why_choose_me_model.dart';

class WhyChooseMeRepository {
  final WhyChooseMeRemoteDataSource _remoteDataSource;

  WhyChooseMeRepository({required WhyChooseMeRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  Future<List<WhyChooseMeItem>> getItems() async {
    return await _remoteDataSource.getItems();
  }

  Future<void> addItem(WhyChooseMeModel item) async {
    await _remoteDataSource.addItem(item);
  }

  Future<void> updateItem(WhyChooseMeModel item) async {
    await _remoteDataSource.updateItem(item);
  }

  Future<void> deleteItem(String id) async {
    await _remoteDataSource.deleteItem(id);
  }
}

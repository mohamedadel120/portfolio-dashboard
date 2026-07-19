import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/why_choose_me_repository.dart';
import '../../data/models/why_choose_me_model.dart';
import 'why_choose_me_state.dart';

class WhyChooseMeCubit extends Cubit<WhyChooseMeState> {
  final WhyChooseMeRepository _repository;

  WhyChooseMeCubit({required WhyChooseMeRepository repository})
      : _repository = repository,
        super(WhyChooseMeInitial());

  Future<void> fetchItems() async {
    emit(WhyChooseMeLoading());
    try {
      final data = await _repository.getItems();
      emit(WhyChooseMeLoaded(items: data));
    } catch (e) {
      emit(WhyChooseMeError(message: e.toString()));
    }
  }

  Future<void> addItem(WhyChooseMeModel item) async {
    try {
      await _repository.addItem(item);
      await fetchItems();
    } catch (e) {
      emit(WhyChooseMeError(message: e.toString()));
    }
  }

  Future<void> updateItem(WhyChooseMeModel item) async {
    try {
      await _repository.updateItem(item);
      await fetchItems();
    } catch (e) {
      emit(WhyChooseMeError(message: e.toString()));
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      await _repository.deleteItem(id);
      await fetchItems();
    } catch (e) {
      emit(WhyChooseMeError(message: e.toString()));
    }
  }
}

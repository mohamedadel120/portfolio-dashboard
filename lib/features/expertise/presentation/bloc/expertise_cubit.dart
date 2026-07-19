import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/expertise_repository.dart';
import '../../data/models/expertise_model.dart';
import 'expertise_state.dart';

class ExpertiseCubit extends Cubit<ExpertiseState> {
  final ExpertiseRepository _repository;

  ExpertiseCubit({required ExpertiseRepository repository})
      : _repository = repository,
        super(ExpertiseInitial());

  Future<void> fetchExpertise() async {
    emit(ExpertiseLoading());
    try {
      final data = await _repository.getExpertise();
      // Sort expertise by percentage descending by default
      data.sort((a, b) => b.percentage.compareTo(a.percentage));
      emit(ExpertiseLoaded(expertise: data));
    } catch (e) {
      emit(ExpertiseError(message: e.toString()));
    }
  }

  Future<void> addExpertise(ExpertiseModel expertise) async {
    try {
      await _repository.addExpertise(expertise);
      await fetchExpertise();
    } catch (e) {
      emit(ExpertiseError(message: e.toString()));
    }
  }

  Future<void> updateExpertise(ExpertiseModel expertise) async {
    try {
      await _repository.updateExpertise(expertise);
      await fetchExpertise();
    } catch (e) {
      emit(ExpertiseError(message: e.toString()));
    }
  }

  Future<void> deleteExpertise(String id) async {
    try {
      await _repository.deleteExpertise(id);
      await fetchExpertise();
    } catch (e) {
      emit(ExpertiseError(message: e.toString()));
    }
  }
}

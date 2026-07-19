import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/experience_repository.dart';
import '../../data/models/experience_model.dart';
import 'experience_state.dart';

class ExperienceCubit extends Cubit<ExperienceState> {
  final ExperienceRepository _repository;

  ExperienceCubit({required ExperienceRepository repository})
      : _repository = repository,
        super(ExperienceInitial());

  Future<void> fetchExperiences() async {
    emit(ExperienceLoading());
    try {
      final data = await _repository.getExperiences();
      
      // Sort experiences by startDate descending (newest first)
      data.sort((a, b) {
        DateTime parseStrDate(String dateStr) {
          try {
            final parts = dateStr.trim().split(' ');
            if (parts.length == 2) {
              final year = int.parse(parts[1]);
              final months = ['jan', 'feb', 'mar', 'apr', 'may', 'jun', 'jul', 'aug', 'sep', 'oct', 'nov', 'dec'];
              final month = months.indexWhere((m) => parts[0].toLowerCase().startsWith(m)) + 1;
              return DateTime(year, month > 0 ? month : 1);
            }
            if (parts.length == 1) {
              final year = int.tryParse(parts[0]);
              if (year != null) return DateTime(year);
            }
          } catch (_) {}
          return DateTime(1970); // Default fallback
        }
        return parseStrDate(b.startDate).compareTo(parseStrDate(a.startDate));
      });

      emit(ExperienceLoaded(experiences: data));
    } catch (e) {
      emit(ExperienceError(message: e.toString()));
    }
  }

  Future<void> addExperience(ExperienceModel experience) async {
    try {
      await _repository.addExperience(experience);
      await fetchExperiences();
    } catch (e) {
      emit(ExperienceError(message: e.toString()));
    }
  }

  Future<void> updateExperience(ExperienceModel experience) async {
    try {
      await _repository.updateExperience(experience);
      await fetchExperiences();
    } catch (e) {
      emit(ExperienceError(message: e.toString()));
    }
  }

  Future<void> deleteExperience(String id) async {
    try {
      await _repository.deleteExperience(id);
      await fetchExperiences();
    } catch (e) {
      emit(ExperienceError(message: e.toString()));
    }
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/profile_info_repository.dart';
import '../../data/models/profile_info_model.dart';
import 'profile_info_state.dart';

class ProfileInfoCubit extends Cubit<ProfileInfoState> {
  final ProfileInfoRepository _repository;

  ProfileInfoCubit({required ProfileInfoRepository repository})
      : _repository = repository,
        super(ProfileInfoInitial());

  Future<void> fetchProfileInfo() async {
    emit(ProfileInfoLoading());
    try {
      final data = await _repository.getProfileInfo();
      emit(ProfileInfoLoaded(profile: data));
    } catch (e) {
      emit(ProfileInfoError(message: e.toString()));
    }
  }

  Future<void> updateProfileInfo(ProfileInfoModel profile) async {
    final current = state;
    if (current is ProfileInfoLoaded) {
      emit(ProfileInfoLoaded(profile: current.profile, isSaving: true));
    }
    try {
      await _repository.updateProfileInfo(profile);
      emit(ProfileInfoLoaded(profile: profile));
    } catch (e) {
      emit(ProfileInfoError(message: e.toString()));
    }
  }
}

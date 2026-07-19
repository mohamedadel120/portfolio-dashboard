import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_info_entity.dart';

abstract class ProfileInfoState extends Equatable {
  const ProfileInfoState();

  @override
  List<Object?> get props => [];
}

class ProfileInfoInitial extends ProfileInfoState {}

class ProfileInfoLoading extends ProfileInfoState {}

class ProfileInfoLoaded extends ProfileInfoState {
  final ProfileInfo profile;
  final bool isSaving;

  const ProfileInfoLoaded({required this.profile, this.isSaving = false});

  @override
  List<Object?> get props => [profile, isSaving];
}

class ProfileInfoError extends ProfileInfoState {
  final String message;

  const ProfileInfoError({required this.message});

  @override
  List<Object?> get props => [message];
}

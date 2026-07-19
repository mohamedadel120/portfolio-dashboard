import 'package:equatable/equatable.dart';
import '../../domain/entities/experience_entity.dart';

abstract class ExperienceState extends Equatable {
  const ExperienceState();

  @override
  List<Object?> get props => [];
}

class ExperienceInitial extends ExperienceState {}

class ExperienceLoading extends ExperienceState {}

class ExperienceLoaded extends ExperienceState {
  final List<Experience> experiences;

  const ExperienceLoaded({required this.experiences});

  @override
  List<Object?> get props => [experiences];
}

class ExperienceError extends ExperienceState {
  final String message;

  const ExperienceError({required this.message});

  @override
  List<Object?> get props => [message];
}

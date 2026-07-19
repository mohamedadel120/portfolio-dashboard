import 'package:equatable/equatable.dart';
import '../../domain/entities/expertise_entity.dart';

abstract class ExpertiseState extends Equatable {
  const ExpertiseState();

  @override
  List<Object?> get props => [];
}

class ExpertiseInitial extends ExpertiseState {}

class ExpertiseLoading extends ExpertiseState {}

class ExpertiseLoaded extends ExpertiseState {
  final List<Expertise> expertise;

  const ExpertiseLoaded({required this.expertise});

  @override
  List<Object?> get props => [expertise];
}

class ExpertiseError extends ExpertiseState {
  final String message;

  const ExpertiseError({required this.message});

  @override
  List<Object?> get props => [message];
}

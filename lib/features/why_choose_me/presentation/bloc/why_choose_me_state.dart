import 'package:equatable/equatable.dart';
import '../../domain/entities/why_choose_me_entity.dart';

abstract class WhyChooseMeState extends Equatable {
  const WhyChooseMeState();

  @override
  List<Object?> get props => [];
}

class WhyChooseMeInitial extends WhyChooseMeState {}

class WhyChooseMeLoading extends WhyChooseMeState {}

class WhyChooseMeLoaded extends WhyChooseMeState {
  final List<WhyChooseMeItem> items;

  const WhyChooseMeLoaded({required this.items});

  @override
  List<Object?> get props => [items];
}

class WhyChooseMeError extends WhyChooseMeState {
  final String message;

  const WhyChooseMeError({required this.message});

  @override
  List<Object?> get props => [message];
}

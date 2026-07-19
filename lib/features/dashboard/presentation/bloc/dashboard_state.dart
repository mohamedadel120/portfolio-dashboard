import 'package:equatable/equatable.dart';
import '../../domain/entities/analytics_entity.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final AnalyticsEntity analytics;
  final int period; // 7, 30, or 90 days

  const DashboardLoaded(this.analytics, {this.period = 7});

  @override
  List<Object?> get props => [analytics, period];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'dart:async';
import 'package:admin_dashboard/features/dashboard/domain/entities/analytics_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/firestore_analytics_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final AnalyticsRepository _repository;
  StreamSubscription<AnalyticsEntity>? _analyticsSubscription;
  AnalyticsEntity? _rawAnalytics;
  int _periodDays = 7;

  DashboardCubit(this._repository) : super(DashboardInitial());

  void startWatchingAnalytics() {
    emit(DashboardLoading());
    _analyticsSubscription?.cancel();
    _analyticsSubscription = _repository.watchDashboardAnalytics().listen(
      (analytics) {
        _rawAnalytics = analytics;
        _emitFiltered();
      },
      onError: (error) {
        emit(DashboardError('Failed to load analytics: $error'));
      },
    );
  }

  void setPeriod(int days) {
    _periodDays = days;
    _emitFiltered();
  }

  void _emitFiltered() {
    final raw = _rawAnalytics;
    if (raw == null) return;
    final cutoff = DateTime.now().subtract(Duration(days: _periodDays));
    final filtered = Map.fromEntries(
      raw.visitsOverTime.entries
          .where((e) => e.key.isAfter(cutoff) || e.key.isAtSameMomentAs(cutoff)),
    );
    final filteredAnalytics = AnalyticsEntity(
      totalVisits: raw.totalVisits,
      uniqueVisitors: raw.uniqueVisitors,
      totalClicks: raw.totalClicks,
      averageTimeOnSite: raw.averageTimeOnSite,
      visitsOverTime: filtered,
      topProjects: raw.topProjects,
      timeSpentPerSection: raw.timeSpentPerSection,
      interactionsPerSection: raw.interactionsPerSection,
    );
    emit(DashboardLoaded(filteredAnalytics, period: _periodDays));
  }

  @override
  Future<void> close() {
    _analyticsSubscription?.cancel();
    return super.close();
  }
}

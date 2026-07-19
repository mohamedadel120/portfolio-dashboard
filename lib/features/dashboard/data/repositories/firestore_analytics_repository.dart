import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/analytics_entity.dart';

abstract class AnalyticsRepository {
  Stream<AnalyticsEntity> watchDashboardAnalytics();
}

class FirestoreAnalyticsRepository implements AnalyticsRepository {
  final FirebaseFirestore _firestore;

  FirestoreAnalyticsRepository({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<AnalyticsEntity> watchDashboardAnalytics() {
    return _firestore
        .collection('analytics')
        .doc('summary')
        .snapshots()
        .map((docSnapshot) {
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        return _getEmptyAnalytics();
      }

      final data = docSnapshot.data()!;

      // Parse visits over time
      final Map<DateTime, int> visitsOverTime = {};
      final rawVisits = data['visitsOverTime'] as Map<String, dynamic>? ?? {};
      rawVisits.forEach((key, value) {
        try {
          final date = DateTime.parse(key);
          visitsOverTime[DateTime(date.year, date.month, date.day)] =
              (value as num).toInt();
        } catch (_) {
          // Ignore parse errors for individual dates
        }
      });

      if (visitsOverTime.isEmpty) {
        final now = DateTime.now();
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          visitsOverTime[DateTime(date.year, date.month, date.day)] = 0;
        }
      }

      // Parse top projects
      final Map<String, int> topProjects = {};
      final rawProjects = data['topProjects'] as Map<String, dynamic>? ?? {};
      rawProjects.forEach((key, value) {
        topProjects[key] = (value as num).toInt();
      });

      if (topProjects.isEmpty) {
        topProjects['No data yet'] = 0;
      }

      // Parse time spent per section
      final Map<String, int> timeSpentPerSection = {};
      final rawTimeSpent = data['timeSpentPerSection'] as Map<String, dynamic>? ?? {};
      rawTimeSpent.forEach((key, value) {
        timeSpentPerSection[key] = (value as num).toInt();
      });

      // Parse interactions per section
      final Map<String, int> interactionsPerSection = {};
      final rawInteractions = data['interactionsPerSection'] as Map<String, dynamic>? ?? {};
      rawInteractions.forEach((key, value) {
        interactionsPerSection[key] = (value as num).toInt();
      });

      return AnalyticsEntity(
        totalVisits: (data['totalVisits'] as num?)?.toInt() ?? 0,
        uniqueVisitors: (data['uniqueVisitors'] as num?)?.toInt() ?? 0,
        totalClicks: (data['totalClicks'] as num?)?.toInt() ?? 0,
        averageTimeOnSite:
            (data['averageTimeOnSite'] as num?)?.toDouble() ?? 0.0,
        visitsOverTime: visitsOverTime,
        topProjects: topProjects,
        timeSpentPerSection: timeSpentPerSection,
        interactionsPerSection: interactionsPerSection,
      );
    });
  }

  AnalyticsEntity _getEmptyAnalytics() {
    final Map<DateTime, int> visitsOverTime = {};
    final now = DateTime.now();
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      visitsOverTime[DateTime(date.year, date.month, date.day)] = 0;
    }

    return AnalyticsEntity(
      totalVisits: 0,
      uniqueVisitors: 0,
      totalClicks: 0,
      averageTimeOnSite: 0.0,
      visitsOverTime: visitsOverTime,
      topProjects: {'No data yet': 0},
      timeSpentPerSection: {},
      interactionsPerSection: {},
    );
  }
}

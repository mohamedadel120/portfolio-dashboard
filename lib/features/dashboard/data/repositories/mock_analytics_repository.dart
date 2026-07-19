import 'dart:math';

import '../../domain/entities/analytics_entity.dart';
import 'firestore_analytics_repository.dart'; // import for AnalyticsRepository

class MockAnalyticsRepository implements AnalyticsRepository {
  @override
  Stream<AnalyticsEntity> watchDashboardAnalytics() async* {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));

    final random = Random();
    
    // Generate mock data for the last 7 days
    final now = DateTime.now();
    final Map<DateTime, int> visitsOverTime = {};
    int totalVisits = 0;
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      // Random visits between 50 and 250
      final dailyVisits = 50 + random.nextInt(200);
      // Ensure date only contains year, month, day to ignore time variations
      final normalizedDate = DateTime(date.year, date.month, date.day);
      visitsOverTime[normalizedDate] = dailyVisits;
      totalVisits += dailyVisits;
    }

    // Top projects mock data
    final topProjects = {
      'E-Commerce App UI': 342,
      'Admin Dashboard UI': 289,
      'Fintech Wallet App': 215,
      'Real Estate Platform': 156,
      'Social Media Concept': 98,
    };

    // Time spent per section mock data (in seconds)
    final timeSpentPerSection = {
      'Hero': 15 + random.nextInt(20),
      'About': 45 + random.nextInt(30),
      'Projects': 120 + random.nextInt(60),
      'Experience': 80 + random.nextInt(40),
      'Contact': 20 + random.nextInt(15),
    };

    // Interactions per section mock data
    final interactionsPerSection = {
      'Hero': 2 + random.nextInt(5),
      'About': 1 + random.nextInt(3),
      'Projects': 15 + random.nextInt(20),
      'Experience': 4 + random.nextInt(8),
      'Contact': 1 + random.nextInt(2),
    };

    yield AnalyticsEntity(
      totalVisits: totalVisits + 1200, // Make total look larger than just 7 days
      uniqueVisitors: (totalVisits * 0.6).round() + 800,
      totalClicks: (totalVisits * 2.5).round() + 3000,
      averageTimeOnSite: 2.4, // 2 minutes 24 seconds
      visitsOverTime: visitsOverTime,
      topProjects: topProjects,
      timeSpentPerSection: timeSpentPerSection,
      interactionsPerSection: interactionsPerSection,
    );
  }
}

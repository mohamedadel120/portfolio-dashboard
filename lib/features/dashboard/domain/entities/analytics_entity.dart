class AnalyticsEntity {
  final int totalVisits;
  final int uniqueVisitors;
  final int totalClicks;
  final double averageTimeOnSite; // in minutes
  final Map<DateTime, int> visitsOverTime; // 7 days of data
  final Map<String, int> topProjects; // Project title -> clicks/views
  final Map<String, int> timeSpentPerSection; // Section name -> time in seconds
  final Map<String, int> interactionsPerSection; // Section name -> interactions

  const AnalyticsEntity({
    required this.totalVisits,
    required this.uniqueVisitors,
    required this.totalClicks,
    required this.averageTimeOnSite,
    required this.visitsOverTime,
    required this.topProjects,
    required this.timeSpentPerSection,
    required this.interactionsPerSection,
  });
}

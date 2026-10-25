import 'package:flutter/material.dart';
import 'package:admin_dashboard/core/demo/demo_mode.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
import 'package:admin_dashboard/core/widgets/page_parts.dart';
import 'package:admin_dashboard/core/widgets/pressable.dart';
import '../../domain/entities/analytics_entity.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:admin_dashboard/features/auth/presentation/bloc/auth_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (demoMode || authState is Authenticated) {
      final state = context.read<DashboardCubit>().state;
      if (state is DashboardInitial || state is DashboardError) {
        context.read<DashboardCubit>().startWatchingAnalytics();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          final dState = context.read<DashboardCubit>().state;
          if (dState is DashboardInitial || dState is DashboardError) {
            context.read<DashboardCubit>().startWatchingAnalytics();
          }
        }
      },
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return _buildShimmer();
          } else if (state is DashboardError) {
            return _buildError(state.message);
          } else if (state is DashboardLoaded) {
            return _buildLoaded(context, state.analytics, state.period);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Shimmer ────────────────────────────────────────────────────────────────

  Widget _buildShimmer() {
    Widget block(double h, {double? w, double r = 16}) => Container(
          height: h,
          width: w,
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(r),
          ),
        );
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceLight,
      highlightColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(40, 36, 40, 40),
        children: [
          block(34, w: 220, r: 10),
          const SizedBox(height: 8),
          block(18, w: 340, r: 6),
          const SizedBox(height: 32),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: i < 2 ? 16 : 0),
                  child: block(124),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          block(420),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return EmptyState(
      icon: Icons.cloud_off_rounded,
      title: 'Could not load analytics',
      message: message,
      actionLabel: 'Retry',
      actionIcon: Icons.refresh_rounded,
      isError: true,
      onAction: () => context.read<DashboardCubit>().startWatchingAnalytics(),
    );
  }

  // ── Loaded ─────────────────────────────────────────────────────────────────

  Widget _buildLoaded(BuildContext context, AnalyticsEntity analytics, int period) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(40, 36, 40, 40),
      children: [
        _buildHeader(period),
        const SizedBox(height: 28),
        _buildStatCards(analytics),
        const SizedBox(height: 20),
        _buildVisitsChart(analytics, period),
        const SizedBox(height: 20),
        _buildTopProjects(analytics),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildPieChart(analytics)),
            const SizedBox(width: 20),
            Expanded(child: _buildBarChart(analytics)),
          ],
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(int period) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return PageHeader(
      title: 'Overview',
      subtitle: '$greeting. Here is how the portfolio site is doing.',
      actions: [
        _PeriodToggle(selectedDays: period),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Text(
                demoMode ? 'Sample data' : 'Live data',
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stat cards ─────────────────────────────────────────────────────────────

  Widget _buildStatCards(AnalyticsEntity analytics) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total visits',
            value: analytics.totalVisits,
            icon: Icons.visibility_outlined,
            subtitle: 'All-time page views',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Unique visitors',
            value: analytics.uniqueVisitors,
            icon: Icons.person_outline_rounded,
            subtitle: 'Distinct sessions',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Total clicks',
            value: analytics.totalClicks,
            icon: Icons.ads_click_rounded,
            subtitle: 'Interactions tracked',
          ),
        ),
      ],
    );
  }

  // ── Visits line chart ──────────────────────────────────────────────────────

  Widget _buildVisitsChart(AnalyticsEntity analytics, int period) {
    return _ChartPanel(
      title: 'Visits',
      subtitle: 'Last $period days',
      height: 400,
      child: _LineChartWidget(data: analytics.visitsOverTime),
    );
  }

  // ── Top projects ───────────────────────────────────────────────────────────

  Widget _buildTopProjects(AnalyticsEntity analytics) {
    if (analytics.topProjects.isEmpty) return const SizedBox.shrink();
    final maxVal = analytics.topProjects.values
        .fold(0, (a, b) => a > b ? a : b);

    return _ChartPanel(
      title: 'Top projects',
      subtitle: 'By interaction count',
      child: Column(
        children: analytics.topProjects.entries.map((e) {
          final pct = maxVal == 0 ? 0.0 : e.value / maxVal;
          return _TopProjectRow(
              name: e.key, clicks: e.value, percentage: pct);
        }).toList(),
      ),
    );
  }

  // ── Pie chart ──────────────────────────────────────────────────────────────

  Widget _buildPieChart(AnalyticsEntity analytics) {
    return _ChartPanel(
      title: 'Attention',
      subtitle: 'Time spent per section',
      height: 340,
      child: _PieChartWidget(data: analytics.timeSpentPerSection),
    );
  }

  // ── Bar chart ──────────────────────────────────────────────────────────────

  Widget _buildBarChart(AnalyticsEntity analytics) {
    return _ChartPanel(
      title: 'Most interactive',
      subtitle: 'Actions per section',
      height: 340,
      child: _BarChartWidget(data: analytics.interactionsPerSection),
    );
  }
}

/// Thousands separators: 12345 -> 12,345.
String _formatInt(int n) {
  final s = n.abs().toString();
  final b = StringBuffer(n < 0 ? '-' : '');
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}

// ── Period toggle ─────────────────────────────────────────────────────────────

class _PeriodToggle extends StatelessWidget {
  final int selectedDays;
  const _PeriodToggle({required this.selectedDays});

  static const _options = [7, 30, 90];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((days) {
          final active = days == selectedDays;
          return Pressable(
            onTap: () => context.read<DashboardCubit>().setPeriod(days),
            semanticLabel: 'Last $days days',
            builder: (context, hovered) => AnimatedContainer(
              duration: AppMotion.of(context, AppMotion.medium),
              curve: AppMotion.ease,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                boxShadow: active
                    ? const [
                        BoxShadow(
                            color: Color(0x1A16171A),
                            blurRadius: 2,
                            offset: Offset(0, 1)),
                      ]
                    : null,
              ),
              child: Text(
                '${days}d',
                style: AppFonts.monoStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w500 : FontWeight.w400,
                  color: active || hovered
                      ? AppColors.ink
                      : AppColors.textSecondary,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Stat card ─────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(icon, color: AppColors.textTertiary, size: 18),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _formatInt(value),
            style: AppFonts.monoStyle(
              fontSize: 32,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12.5, color: AppColors.textTertiary),
          ),
        ],
      ),
    );
  }
}

// ── Chart panel wrapper ───────────────────────────────────────────────────────

class _ChartPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double? height;

  const _ChartPanel({
    required this.title,
    required this.subtitle,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),
          if (height != null) Expanded(child: child) else child,
        ],
      ),
    );
  }
}

// ── Top project row ───────────────────────────────────────────────────────────

class _TopProjectRow extends StatelessWidget {
  final String name;
  final int clicks;
  final double percentage;

  const _TopProjectRow({
    required this.name,
    required this.clicks,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.ink),
                ),
              ),
              Text(
                _formatInt(clicks),
                style: AppFonts.monoStyle(
                    fontSize: 12.5, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(height: 6, color: AppColors.surfaceLight),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(height: 6, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Line chart ────────────────────────────────────────────────────────────────

/// The smallest of 1, 2, 2.5 or 5 times a power of ten that is at least
/// [rough] (at least 1), so axis labels read 0, 50, 100 rather than 0, 42, 84.
double _niceStep(double rough) {
  var power = 1.0;
  while (power * 10 <= rough) {
    power *= 10;
  }
  for (final m in const [1.0, 2.0, 2.5, 5.0, 10.0]) {
    if (m * power >= rough) return m * power;
  }
  return 10 * power;
}

class _LineChartWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  const _LineChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = data.keys.toList()..sort();
    final spots = sortedKeys.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), data[e.value]!.toDouble());
    }).toList();

    // A round step for about five gridlines, and a top that is a whole step
    // above the highest day. With the top at the raw maximum (e.g. 208) its
    // label printed on top of the "200" label.
    final highest = spots.fold<double>(0, (m, s) => s.y > m ? s.y : m);
    final step = _niceStep(highest / 5);
    final top = ((highest / step).floor() + 1) * step;

    return LineChart(
      key: const ValueKey('visits_line_chart'),
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: step,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
            dashArray: const [3, 4],
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i >= sortedKeys.length) return const Text('');
                final date = sortedKeys[i];
                final isToday = date.day == DateTime.now().day &&
                    date.month == DateTime.now().month;
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    isToday ? 'Today' : '${date.day}/${date.month}',
                    style: TextStyle(
                        color: isToday
                            ? AppColors.primary
                            : AppColors.textTertiary,
                        fontSize: 11,
                        fontWeight: isToday
                            ? FontWeight.w600
                            : FontWeight.normal),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: step,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                    color: AppColors.textTertiary, fontSize: 11),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (sortedKeys.length - 1).toDouble(),
        minY: 0,
        maxY: top,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            // A smooth curve must not dip below 0 or above a real value.
            preventCurveOverShooting: true,
            color: AppColors.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: AppColors.surface,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.14),
                  AppColors.primary.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) => AppColors.ink,
            getTooltipItems: (spots) => spots
                .map((s) => LineTooltipItem(
                      '${s.y.toInt()} visits',
                      const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ── Pie chart ─────────────────────────────────────────────────────────────────

class _PieChartWidget extends StatelessWidget {
  final Map<String, int> data;
  const _PieChartWidget({required this.data});

  // One hue (the brand teal) in steps, then warm neutrals: readable on
  // white without adding new accent colours.
  static const _colors = [
    Color(0xFF0E7490),
    Color(0xFF3F8AA0),
    Color(0xFF8DBFCC),
    Color(0xFF4A4B50),
    Color(0xFFA19D92),
    Color(0xFFD3CFC4),
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text('No data yet',
            style: TextStyle(
                color: AppColors.textTertiary, fontSize: 14)),
      );
    }

    final total = data.values.fold(0, (s, v) => s + v);
    int ci = 0;
    final sections = data.entries.map((e) {
      final pct = total == 0 ? 0.0 : e.value / total * 100;
      final color = _colors[ci++ % _colors.length];
      return PieChartSectionData(
        color: color,
        value: e.value.toDouble(),
        title: '${pct.toStringAsFixed(0)}%',
        radius: 56,
        titleStyle: AppFonts.monoStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: color.computeLuminance() > 0.4
                ? AppColors.ink
                : Colors.white),
        badgeWidget: _PieBadge(label: e.key, color: color),
        badgePositionPercentageOffset: 1.45,
      );
    }).toList();

    return PieChart(
      key: const ValueKey('time_spent_pie_chart'),
      PieChartData(
        pieTouchData: PieTouchData(enabled: true),
        borderData: FlBorderData(show: false),
        sectionsSpace: 3,
        centerSpaceRadius: 38,
        sections: sections,
      ),
    );
  }
}

class _PieBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _PieBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 11, color: AppColors.ink)),
    );
  }
}

// ── Bar chart ─────────────────────────────────────────────────────────────────

class _BarChartWidget extends StatelessWidget {
  final Map<String, int> data;
  const _BarChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text('No data yet',
            style: TextStyle(
                color: AppColors.textTertiary, fontSize: 14)),
      );
    }

    final maxVal = data.values.fold(0, (m, v) => v > m ? v : m);
    int i = 0;
    final groups = data.entries.map((e) {
      final group = BarChartGroupData(
        x: i++,
        barRods: [
          BarChartRodData(
            toY: e.value.toDouble(),
            color: AppColors.primary,
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
          ),
        ],
      );
      return group;
    }).toList();

    return BarChart(
      key: const ValueKey('interactions_bar_chart'),
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxVal.toDouble() * 1.25,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => AppColors.ink,
            getTooltipItem: (group, gi, rod, ri) => BarTooltipItem(
              '${rod.toY.toInt()} actions',
              const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= data.keys.length) return const Text('');
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    data.keys.elementAt(idx),
                    style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval:
              maxVal > 0 ? (maxVal / 4).ceilToDouble() : 1,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.border,
            strokeWidth: 1,
            dashArray: const [3, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }
}

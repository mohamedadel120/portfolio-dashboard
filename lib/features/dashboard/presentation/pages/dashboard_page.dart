import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import 'package:admin_dashboard/core/constants/app_colors.dart';
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
    if (authState is Authenticated) {
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
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.04),
      highlightColor: Colors.white.withValues(alpha: 0.12),
      child: ListView(
        padding: const EdgeInsets.all(32),
        children: [
          // Header placeholder
          Container(
              height: 36,
              width: 220,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 8),
          Container(
              height: 18,
              width: 340,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6))),
          const SizedBox(height: 32),
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Container(
                  height: 130,
                  margin: EdgeInsets.only(right: i < 2 ? 20 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 420,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  height: 320,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────────────────

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: RadialGradient(colors: [
                Colors.redAccent.withValues(alpha: 0.15),
                Colors.transparent,
              ]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded,
                size: 32, color: Colors.redAccent),
          ),
          const SizedBox(height: 16),
          const Text('Failed to load analytics',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(message,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.38), fontSize: 13)),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: () =>
                context.read<DashboardCubit>().startWatchingAnalytics(),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(
                  color: AppColors.primary.withValues(alpha: 0.5)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loaded ─────────────────────────────────────────────────────────────────

  Widget _buildLoaded(BuildContext context, AnalyticsEntity analytics, int period) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 40),
      children: [
        _buildHeader(period),
        const SizedBox(height: 28),
        _buildStatCards(analytics),
        const SizedBox(height: 24),
        _buildVisitsChart(analytics, period),
        const SizedBox(height: 24),
        _buildTopProjects(analytics),
        const SizedBox(height: 24),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(Icons.grid_view_rounded,
                        color: AppColors.primary, size: 20),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$greeting 👋',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.45),
                          fontSize: 13,
                        ),
                      ),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        // Period toggle
        _PeriodToggle(selectedDays: period),
        const SizedBox(width: 12),
        // Live indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF4ADE80).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: const Color(0xFF4ADE80).withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Live data',
                style: TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
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
            title: 'Total Visits',
            value: analytics.totalVisits.toString(),
            icon: Icons.remove_red_eye_rounded,
            color: AppColors.primary,
            subtitle: 'All-time page views',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Unique Visitors',
            value: analytics.uniqueVisitors.toString(),
            icon: Icons.person_outline_rounded,
            color: AppColors.secondary,
            subtitle: 'Distinct sessions',
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _StatCard(
            title: 'Total Clicks',
            value: analytics.totalClicks.toString(),
            icon: Icons.touch_app_rounded,
            color: Colors.orangeAccent,
            subtitle: 'Interactions tracked',
          ),
        ),
      ],
    );
  }

  // ── Visits line chart ──────────────────────────────────────────────────────

  Widget _buildVisitsChart(AnalyticsEntity analytics, int period) {
    return _ChartPanel(
      title: 'Visits Overview',
      subtitle: 'Last $period days',
      icon: Icons.show_chart_rounded,
      height: 420,
      child: _LineChartWidget(data: analytics.visitsOverTime),
    );
  }

  // ── Top projects ───────────────────────────────────────────────────────────

  Widget _buildTopProjects(AnalyticsEntity analytics) {
    if (analytics.topProjects.isEmpty) return const SizedBox.shrink();
    final maxVal = analytics.topProjects.values
        .fold(0, (a, b) => a > b ? a : b);

    return _ChartPanel(
      title: 'Top Projects',
      subtitle: 'By interaction count',
      icon: Icons.leaderboard_rounded,
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
      title: 'Attention Heatmap',
      subtitle: 'Time spent per section',
      icon: Icons.pie_chart_rounded,
      height: 340,
      child: _PieChartWidget(data: analytics.timeSpentPerSection),
    );
  }

  // ── Bar chart ──────────────────────────────────────────────────────────────

  Widget _buildBarChart(AnalyticsEntity analytics) {
    return _ChartPanel(
      title: 'Most Interactive',
      subtitle: 'Actions per section',
      icon: Icons.bar_chart_rounded,
      height: 340,
      child: _BarChartWidget(data: analytics.interactionsPerSection),
    );
  }
}

// ── Period toggle ─────────────────────────────────────────────────────────────

class _PeriodToggle extends StatelessWidget {
  final int selectedDays;
  const _PeriodToggle({required this.selectedDays});

  static const _options = [7, 30, 90];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((days) {
          final active = days == selectedDays;
          return GestureDetector(
            onTap: () => context.read<DashboardCubit>().setPeriod(days),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                gradient: active
                    ? LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.25),
                          AppColors.primary.withValues(alpha: 0.08),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(9),
                border: active
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4))
                    : null,
              ),
              child: Text(
                '${days}d',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      active ? FontWeight.w700 : FontWeight.w500,
                  color: active
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 0.2,
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

class _StatCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard>
    with SingleTickerProviderStateMixin {
  bool _hovered = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 220));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovered = true);
        _ctrl.forward();
      },
      onExit: (_) {
        setState(() => _hovered = false);
        _ctrl.reverse();
      },
      child: AnimatedBuilder(
        animation: _anim,
        builder: (context, child) => AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          transform: Matrix4.translationValues(0, _hovered ? -4 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            // Gradient border outer container
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: 0.35 + 0.25 * _anim.value),
                Colors.white.withValues(alpha: 0.07),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.22 * _anim.value),
                blurRadius: 40,
                spreadRadius: -6,
                offset: const Offset(0, 14),
              ),
              BoxShadow(
                color: Colors.black.withValues(
                    alpha: _hovered ? 0.45 : 0.2),
                blurRadius: 20,
                spreadRadius: -8,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(1),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: 0.09),
                AppColors.background.withValues(alpha: 0.96),
                AppColors.surface,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colored top accent bar
              Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.color,
                      widget.color.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(2),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.42),
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Large value with ShaderMask gradient on hover
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _hovered
                              ? ShaderMask(
                                  shaderCallback: (bounds) =>
                                      LinearGradient(
                                    colors: [
                                      widget.color,
                                      Colors.white,
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    widget.value,
                                    key: const ValueKey('colored'),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -1.5,
                                      height: 1,
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.value,
                                  key: const ValueKey('white'),
                                  style: const TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -1.5,
                                    height: 1,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.26),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Icon — diamond-shaped container
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          widget.color.withValues(alpha: 0.25),
                          widget.color.withValues(alpha: 0.08),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: widget.color.withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withValues(
                              alpha: 0.3 * _anim.value),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: Icon(widget.icon,
                        color: widget.color, size: 22),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Chart panel wrapper ───────────────────────────────────────────────────────

class _ChartPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final double? height;

  const _ChartPanel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: Icon(icon, color: AppColors.primary, size: 15),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
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
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              Text(
                '$clicks interactions',
                style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.38)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Stack(
              children: [
                Container(
                  height: 6,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                FractionallySizedBox(
                  widthFactor: percentage,
                  child: Container(
                    height: 6,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.secondary, AppColors.primary],
                      ),
                    ),
                  ),
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

class _LineChartWidget extends StatelessWidget {
  final Map<DateTime, int> data;
  const _LineChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    final sortedKeys = data.keys.toList()..sort();
    final spots = sortedKeys.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), data[e.value]!.toDouble());
    }).toList();

    return LineChart(
      key: const ValueKey('visits_line_chart'),
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 50,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.04),
            strokeWidth: 1,
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
                            : Colors.white.withValues(alpha: 0.35),
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
              interval: 50,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (sortedKeys.length - 1).toDouble(),
        minY: 0,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) =>
                  FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: AppColors.background,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.25),
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
            getTooltipColor: (spot) => AppColors.surfaceLight,
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

  static const _colors = [
    AppColors.primary,
    AppColors.secondary,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.greenAccent,
    Colors.purpleAccent,
  ];

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text('No data yet',
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.35), fontSize: 14)),
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
        titleStyle: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
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
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label,
          style: const TextStyle(fontSize: 10, color: Colors.white70)),
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
                color: Colors.white.withValues(alpha: 0.35), fontSize: 14)),
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
            gradient: const LinearGradient(
              colors: [AppColors.secondary, AppColors.primary],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
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
            getTooltipColor: (group) => AppColors.surfaceLight,
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
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
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
            color: Colors.white.withValues(alpha: 0.04),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: groups,
      ),
    );
  }
}

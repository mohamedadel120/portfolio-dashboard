import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_layout.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/projects/presentation/pages/projects_page.dart';
import '../../features/expertise/presentation/pages/expertise_page.dart';
import '../../features/experience/presentation/pages/experience_page.dart';
import '../../features/testimonials/presentation/pages/testimonials_page.dart';
import '../../features/why_choose_me/presentation/pages/why_choose_me_page.dart';
import '../../features/profile_info/presentation/pages/profile_info_page.dart';
import 'dart:async';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

GoRouter createRouter(AuthCubit authCubit) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authCubit.stream),
    redirect: (context, state) {
      final authState = authCubit.state;
      final isGoingToLogin = state.matchedLocation == '/login';
      
      if (authState is Unauthenticated && !isGoingToLogin) {
        return '/login';
      }
      
      if (authState is Authenticated && isGoingToLogin) {
        return '/';
      }
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return DashboardLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: '/projects',
            builder: (context, state) => const ProjectsPage(),
          ),
          GoRoute(
            path: '/expertise',
            builder: (context, state) => const ExpertisePage(),
          ),
          GoRoute(
            path: '/experience',
            builder: (context, state) => const ExperiencePage(),
          ),
          GoRoute(
            path: '/testimonials',
            builder: (context, state) => const TestimonialsPage(),
          ),
          GoRoute(
            path: '/why-choose-me',
            builder: (context, state) => const WhyChooseMePage(),
          ),
          GoRoute(
            path: '/profile-info',
            builder: (context, state) => const ProfileInfoPage(),
          ),
        ],
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';
import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/di/injection_container.dart' as di;
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'features/projects/presentation/bloc/projects_cubit.dart';
import 'features/expertise/presentation/bloc/expertise_cubit.dart';
import 'features/experience/presentation/bloc/experience_cubit.dart';
import 'features/testimonials/presentation/bloc/testimonials_cubit.dart';
import 'features/why_choose_me/presentation/bloc/why_choose_me_cubit.dart';
import 'features/profile_info/presentation/bloc/profile_info_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await di.init();

  runApp(const AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(
          create: (context) => di.sl<DashboardCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<ProjectsCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<ExpertiseCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<ExperienceCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<TestimonialsCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<WhyChooseMeCubit>(),
        ),
        BlocProvider(
          create: (context) => di.sl<ProfileInfoCubit>(),
        ),
      ],
      child: const _AppRouterHost(),
    );
  }
}

class _AppRouterHost extends StatefulWidget {
  const _AppRouterHost();

  @override
  State<_AppRouterHost> createState() => _AppRouterHostState();
}

class _AppRouterHostState extends State<_AppRouterHost> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = createRouter(context.read<AuthCubit>());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Portfolio Admin',
      theme: AppTheme.darkTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

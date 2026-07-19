import 'package:admin_dashboard/features/dashboard/data/repositories/firestore_analytics_repository.dart';
import 'package:admin_dashboard/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/projects/data/datasources/projects_remote_data_source.dart';
import '../../features/projects/data/repositories/projects_repository.dart';
import '../../features/projects/presentation/bloc/projects_cubit.dart';
import '../../features/expertise/data/datasources/expertise_remote_data_source.dart';
import '../../features/expertise/data/repositories/expertise_repository.dart';
import '../../features/expertise/presentation/bloc/expertise_cubit.dart';
import '../../features/experience/data/datasources/experience_remote_data_source.dart';
import '../../features/experience/data/repositories/experience_repository.dart';
import '../../features/experience/presentation/bloc/experience_cubit.dart';
import '../../features/testimonials/data/datasources/testimonials_remote_data_source.dart';
import '../../features/testimonials/data/repositories/testimonials_repository.dart';
import '../../features/testimonials/presentation/bloc/testimonials_cubit.dart';
import '../../features/why_choose_me/data/datasources/why_choose_me_remote_data_source.dart';
import '../../features/why_choose_me/data/repositories/why_choose_me_repository.dart';
import '../../features/why_choose_me/presentation/bloc/why_choose_me_cubit.dart';
import '../../features/profile_info/data/datasources/profile_info_remote_data_source.dart';
import '../../features/profile_info/data/repositories/profile_info_repository.dart';
import '../../features/profile_info/presentation/bloc/profile_info_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Features - Dashboard
  sl.registerFactory(() => DashboardCubit(sl()));
  sl.registerLazySingleton<AnalyticsRepository>(
    () => FirestoreAnalyticsRepository(firestore: sl()),
  );

  // Features - Projects
  // Bloc
  sl.registerFactory(() => ProjectsCubit(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => ProjectsRepository(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton(() => ProjectsRemoteDataSource(firestore: sl()));

  // Features - Expertise
  // Bloc
  sl.registerFactory(() => ExpertiseCubit(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => ExpertiseRepository(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton(() => ExpertiseRemoteDataSource(firestore: sl()));

  // Features - Experience
  // Bloc
  sl.registerFactory(() => ExperienceCubit(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => ExperienceRepository(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton(() => ExperienceRemoteDataSource(firestore: sl()));

  // Features - Testimonials
  // Bloc
  sl.registerFactory(() => TestimonialsCubit(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => TestimonialsRepository(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton(() => TestimonialsRemoteDataSource(firestore: sl()));

  // Features - Why Choose Me
  // Bloc
  sl.registerFactory(() => WhyChooseMeCubit(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => WhyChooseMeRepository(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton(() => WhyChooseMeRemoteDataSource(firestore: sl()));

  // Features - Profile Info
  // Bloc
  sl.registerFactory(() => ProfileInfoCubit(repository: sl()));

  // Repository
  sl.registerLazySingleton(() => ProfileInfoRepository(remoteDataSource: sl()));

  // Data sources
  sl.registerLazySingleton(() => ProfileInfoRemoteDataSource(firestore: sl()));

  // External
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
}

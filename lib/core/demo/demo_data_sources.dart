import 'package:flutter/material.dart';

import '../../features/experience/data/datasources/experience_remote_data_source.dart';
import '../../features/experience/data/models/experience_model.dart';
import '../../features/expertise/data/datasources/expertise_remote_data_source.dart';
import '../../features/expertise/data/models/expertise_model.dart';
import '../../features/profile_info/data/datasources/profile_info_remote_data_source.dart';
import '../../features/profile_info/data/models/profile_info_model.dart';
import '../../features/testimonials/data/datasources/testimonials_remote_data_source.dart';
import '../../features/testimonials/data/models/testimonial_model.dart';
import '../../features/why_choose_me/data/datasources/why_choose_me_remote_data_source.dart';
import '../../features/why_choose_me/data/models/why_choose_me_model.dart';

// In-memory data sources for demo mode (see demo_mode.dart). They never touch
// Firestore; changes live only until the page is reloaded.

const _latency = Duration(milliseconds: 300);

class DemoExperienceDataSource implements ExperienceRemoteDataSource {
  final _items = <ExperienceModel>[
    const ExperienceModel(
      id: 'demo-exp-1',
      company: 'Demo Company',
      role: 'Senior Flutter Developer',
      startDate: 'Jan 2023',
      endDate: 'Present',
      description: 'Demo text. Leads the mobile team and owns the app '
          'architecture and release process.',
      location: 'Cairo, Egypt',
    ),
    const ExperienceModel(
      id: 'demo-exp-2',
      company: 'Another Studio',
      role: 'Flutter Developer',
      startDate: 'Mar 2021',
      endDate: 'Dec 2022',
      description: 'Demo text. Built and shipped client apps on Android '
          'and iOS.',
      location: 'Remote',
    ),
  ];

  @override
  Future<List<ExperienceModel>> getExperiences() async {
    await Future.delayed(_latency);
    return List.of(_items);
  }

  @override
  Future<void> addExperience(ExperienceModel experience) async {
    await Future.delayed(_latency);
    _items.add(experience);
  }

  @override
  Future<void> updateExperience(ExperienceModel experience) async {
    await Future.delayed(_latency);
    final i = _items.indexWhere((e) => e.id == experience.id);
    if (i != -1) _items[i] = experience;
  }

  @override
  Future<void> deleteExperience(String id) async {
    await Future.delayed(_latency);
    _items.removeWhere((e) => e.id == id);
  }
}

class DemoExpertiseDataSource implements ExpertiseRemoteDataSource {
  final _items = <ExpertiseModel>[
    const ExpertiseModel(
        id: 'demo-sk-1',
        title: 'Flutter',
        category: 'Mobile',
        percentage: 95,
        color: Color(0xFF0E7490)),
    const ExpertiseModel(
        id: 'demo-sk-2',
        title: 'Dart',
        category: 'Language',
        percentage: 92,
        color: Color(0xFF2563EB)),
    const ExpertiseModel(
        id: 'demo-sk-3',
        title: 'Firebase',
        category: 'Backend',
        percentage: 85,
        color: Color(0xFFE4572E)),
  ];

  @override
  Future<List<ExpertiseModel>> getExpertise() async {
    await Future.delayed(_latency);
    return List.of(_items);
  }

  @override
  Future<void> addExpertise(ExpertiseModel expertise) async {
    await Future.delayed(_latency);
    _items.add(expertise);
  }

  @override
  Future<void> updateExpertise(ExpertiseModel expertise) async {
    await Future.delayed(_latency);
    final i = _items.indexWhere((e) => e.id == expertise.id);
    if (i != -1) _items[i] = expertise;
  }

  @override
  Future<void> deleteExpertise(String id) async {
    await Future.delayed(_latency);
    _items.removeWhere((e) => e.id == id);
  }
}

class DemoTestimonialsDataSource implements TestimonialsRemoteDataSource {
  final _items = <TestimonialModel>[
    const TestimonialModel(
      id: 'demo-t-1',
      name: 'Demo Client',
      role: 'Product Manager',
      company: 'Demo Co.',
      opinion: 'Demo testimonial text, shown only in demo mode.',
      rating: 5,
    ),
  ];

  @override
  Future<List<TestimonialModel>> getTestimonials() async {
    await Future.delayed(_latency);
    return List.of(_items);
  }

  @override
  Future<void> addTestimonial(TestimonialModel testimonial) async {
    await Future.delayed(_latency);
    _items.add(testimonial);
  }

  @override
  Future<void> updateTestimonial(TestimonialModel testimonial) async {
    await Future.delayed(_latency);
    final i = _items.indexWhere((e) => e.id == testimonial.id);
    if (i != -1) _items[i] = testimonial;
  }

  @override
  Future<void> deleteTestimonial(String id) async {
    await Future.delayed(_latency);
    _items.removeWhere((e) => e.id == id);
  }
}

class DemoWhyChooseMeDataSource implements WhyChooseMeRemoteDataSource {
  final _items = <WhyChooseMeModel>[
    WhyChooseMeModel(
      id: 'demo-w-1',
      title: 'Clean architecture',
      description: 'Demo text. Code that is easy to test and to change.',
      color: const Color(0xFF0E7490),
      icon: Icons.architecture_rounded.codePoint,
    ),
    WhyChooseMeModel(
      id: 'demo-w-2',
      title: 'Shipped to the stores',
      description: 'Demo text. From first commit to store release.',
      color: const Color(0xFF15803D),
      icon: Icons.rocket_launch_rounded.codePoint,
    ),
  ];

  @override
  Future<List<WhyChooseMeModel>> getItems() async {
    await Future.delayed(_latency);
    return List.of(_items);
  }

  @override
  Future<void> addItem(WhyChooseMeModel item) async {
    await Future.delayed(_latency);
    _items.add(item);
  }

  @override
  Future<void> updateItem(WhyChooseMeModel item) async {
    await Future.delayed(_latency);
    final i = _items.indexWhere((e) => e.id == item.id);
    if (i != -1) _items[i] = item;
  }

  @override
  Future<void> deleteItem(String id) async {
    await Future.delayed(_latency);
    _items.removeWhere((e) => e.id == id);
  }
}

class DemoProfileInfoDataSource implements ProfileInfoRemoteDataSource {
  ProfileInfoModel _profile = const ProfileInfoModel(
    name: 'Demo Name',
    title: 'Flutter Developer',
    subtitle: 'Demo subtitle',
    description: 'Demo description, shown only in demo mode.',
    professionalSummary: 'Demo professional summary.',
    email: 'demo@example.com',
    phone: '+00 000 000 0000',
    location: 'Cairo, Egypt',
    cvUrl: '',
    techStack: ['Flutter', 'Dart', 'Firebase', 'Bloc'],
  );

  @override
  Future<ProfileInfoModel> getProfileInfo() async {
    await Future.delayed(_latency);
    return _profile;
  }

  @override
  Future<void> updateProfileInfo(ProfileInfoModel profile) async {
    await Future.delayed(_latency);
    _profile = profile;
  }
}

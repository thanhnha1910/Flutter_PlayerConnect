import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_remote_datasource.dart';
import '../models/onboarding_request_model.dart';
import '../models/tag_model.dart';
import '../models/sport_model.dart';
import '../../core/error/exceptions.dart';

@LazySingleton(as: OnboardingRepository)
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingRemoteDataSource remoteDataSource;

  OnboardingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<SportModel>> getAllActiveSports() async {
    try {
      return await remoteDataSource.getAllActiveSports();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to get active sports');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<List<TagModel>> getTagsBySport(int sportId) async {
    try {
      return await remoteDataSource.getTagsBySport(sportId);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to get tags');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<void> submitOnboarding(OnboardingRequestModel request) async {
    try {
      await remoteDataSource.submitOnboarding(request);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to submit onboarding');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<bool> checkOnboardingStatus() async {
    try {
      return await remoteDataSource.checkOnboardingStatus();
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Failed to check onboarding status');
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }
}
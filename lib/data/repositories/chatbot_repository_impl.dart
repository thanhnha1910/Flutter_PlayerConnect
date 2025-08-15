import '../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../domain/repositories/chatbot_repository.dart';
import '../datasources/chatbot_remote_datasource.dart';
import '../models/chatbot_models.dart';

@LazySingleton(as: ChatbotRepository)
class ChatbotRepositoryImpl implements ChatbotRepository {
  final ChatbotRemoteDataSource _remoteDataSource;

  ChatbotRepositoryImpl({required ChatbotRemoteDataSource remoteDataSource}) : _remoteDataSource = remoteDataSource;

  @override
  Future<Either<Failure, ChatbotResponseDTO>> sendMessage(
    ChatbotRequestDTO request
  ) async {
    try {
      final response = await _remoteDataSource.sendMessage(request);
      return Right(response);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkHealth() async {
    try {
      await _remoteDataSource.checkHealth();
      return const Right(true);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
import '../../repositories/chat_repository.dart';
import '../../../core/error/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@injectable
class ConnectWebSocketUseCase {
  final ChatRepository repository;

  ConnectWebSocketUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    print('🔌 [ConnectWebSocketUseCase] Starting WebSocket connection...');
    try {
      await repository.connectWebSocket();
      print('✅ [ConnectWebSocketUseCase] WebSocket connection successful');
      return const Right(null);
    } on ServerFailure catch (failure) {
      print('❌ [ConnectWebSocketUseCase] ServerFailure: ${failure.message}');
      return Left(failure);
    } catch (e) {
      print('💥 [ConnectWebSocketUseCase] Unexpected error: $e');
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
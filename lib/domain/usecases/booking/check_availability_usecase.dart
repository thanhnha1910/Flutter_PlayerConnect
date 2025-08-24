import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../core/error/failures.dart';
import '../../../data/models/booking_model.dart';
import '../../entities/booking.dart';
import '../../repositories/booking_repository.dart';

@injectable
class CheckAvailabilityUseCase {
  final BookingRepository repository;

  CheckAvailabilityUseCase(this.repository);

  Future<Either<Failure, List<TimeSlot>>> call({
    required int fieldId,
    required DateTime date,
  }) async {
    // Validation
    if (date.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
      return Left(ValidationFailure('Không thể kiểm tra khả năng cho ngày trong quá khứ'));
    }

    return await repository.checkAvailability(
      fieldId: fieldId,
      date: date,
    );
  }
}
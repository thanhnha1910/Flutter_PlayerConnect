import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../domain/entities/payment.dart';
import '../../../domain/usecases/auth/getpaymentstatus_usecase.dart';
import '../../../domain/usecases/auth/initiatepayment_usecase.dart'; // Add this import

part 'payment_event.dart';
part 'payment_state.dart';

@injectable // Add this annotation
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final InitiatePaymentUseCase initiatePaymentUseCase;
  final GetPaymentStatusUseCase getPaymentStatusUseCase;

  PaymentBloc({
    required this.initiatePaymentUseCase,
    required this.getPaymentStatusUseCase,
  }) : super(PaymentInitial()) {
    on<InitiatePaymentEvent>(_onInitiatePayment);
    on<GetPaymentStatusEvent>(_onGetPaymentStatus);
    on<ResetPaymentEvent>(_onResetPayment);
  }

  Future<void> _onInitiatePayment(
      InitiatePaymentEvent event,
      Emitter<PaymentState> emit,
      ) async {
    try {
      emit(PaymentLoading());

      final result = await initiatePaymentUseCase(
        payableId: event.payableId,
        payableType: event.payableType,
        amount: event.amount,
      );

      result.fold(
            (failure) => emit(PaymentFailure(
            failure.message ?? "Không thể khởi tạo thanh toán")),
            (paymentApproval) => emit(PaymentInitiated(
          approvalUrl: paymentApproval.approvalUrl,
          paymentId: paymentApproval.paymentId,
        )),
      );
    } catch (e) {
      emit(PaymentFailure("Lỗi không mong đợi: ${e.toString()}"));
    }
  }

  Future<void> _onGetPaymentStatus(
      GetPaymentStatusEvent event,
      Emitter<PaymentState> emit,
      ) async {
    try {
      emit(PaymentLoading());

      final result = await getPaymentStatusUseCase(event.paymentId);

      result.fold(
            (failure) => emit(PaymentFailure(
            failure.message ?? "Không thể lấy trạng thái thanh toán")),
            (payment) => emit(PaymentStatusLoaded(payment)),
      );
    } catch (e) {
      emit(PaymentFailure("Lỗi không mong đợi: ${e.toString()}"));
    }
  }

  void _onResetPayment(
      ResetPaymentEvent event,
      Emitter<PaymentState> emit,
      ) {
    emit(PaymentInitial());
  }
}
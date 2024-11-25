import 'package:bloc/bloc.dart';
import 'package:oezbooking/features/orders/domain/usecase/fetch_orders.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_event.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final FetchOrdersUseCase useCase;

  OrderBloc(this.useCase) : super(OrderInitial()) {
    on<FetchOrderList>(
      (event, emit) async {
        try {
          emit(OrderLoading());
          final orders = await useCase.call(event.organizerID);
          emit(OrdersLoaded(orders));
        } on Exception catch (e) {
          emit(OrderError(e.toString()));
        }
      },
    );
  }
}

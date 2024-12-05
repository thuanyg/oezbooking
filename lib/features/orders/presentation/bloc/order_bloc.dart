import 'package:bloc/bloc.dart';
import 'package:oezbooking/features/orders/data/model/order.dart';
import 'package:oezbooking/features/orders/domain/entity/order_entity.dart';
import 'package:oezbooking/features/orders/domain/usecase/fetch_orders.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_event.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final FetchOrdersUseCase useCase;
  List<OrderEntity> _orders = [];

  OrderBloc(this.useCase) : super(OrderInitial()) {
    on<FetchOrderList>(
      (event, emit) async {
        try {
          emit(OrderLoading());
          final orders = await useCase.call(event.organizerID);
          _orders = orders;
          emit(OrdersLoaded(orders));
        } on Exception catch (e) {
          emit(OrderError(e.toString()));
        }
      },
    );

    on<SearchOrder>(
      (event, emit) {
        try {
          emit(OrderLoading());

          if (event.query.isEmpty) {
            emit(OrdersLoaded(_orders));
            return;
          }
          final filteredOrders = _orders.where((order) {
            return order.fullName!.toLowerCase().contains(event.query) ||
                order.event.name.toLowerCase().contains(event.query) ||
                order.order.id.toLowerCase().contains(event.query);
          }).toList();

          emit(OrdersLoaded(filteredOrders));
        } on Exception catch (e) {
          emit(OrderError(e.toString()));
        }
      },
    );
  }
}

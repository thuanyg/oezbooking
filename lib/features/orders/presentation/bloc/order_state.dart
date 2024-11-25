import 'package:oezbooking/features/orders/data/model/order.dart';
import 'package:oezbooking/features/orders/domain/entity/order_entity.dart';

abstract class OrderState {}
class OrderInitial extends OrderState{}
class OrderLoading extends OrderState{}
class OrdersLoaded extends OrderState{
  final List<OrderEntity> orders;

  OrdersLoaded(this.orders);
}
class OrderError extends OrderState{
  final String error;

  OrderError(this.error);
}
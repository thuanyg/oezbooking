import 'package:oezbooking/features/orders/data/model/order.dart';
import 'package:oezbooking/features/orders/domain/entity/order_entity.dart';

abstract class OrderRepository {
  Future<List<Order>> fetchOrders(String organizer);
  Future<List<OrderEntity>> fetchOrdersEntity(String organizer);
}
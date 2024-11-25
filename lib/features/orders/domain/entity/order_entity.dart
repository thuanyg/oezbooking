import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/orders/data/model/order.dart';

class OrderEntity {
  Order order;
  Event event;
  // User
  String? fullName;

  OrderEntity(this.order, this.event, this.fullName);
}
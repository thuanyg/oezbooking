import 'package:oezbooking/features/events/data/model/event.dart';
import 'package:oezbooking/features/orders/data/model/order.dart';

abstract class OrderDatasource {
  Future<List<Order>> fetchOrders(String organizer);
  Future<Event> fetchEventOrder(String eventID);
  Future<String> fetchUserOrder(String userID);
}
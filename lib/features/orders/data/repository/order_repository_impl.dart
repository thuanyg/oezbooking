import 'package:oezbooking/features/orders/data/datasource/order_datasource.dart';
import 'package:oezbooking/features/orders/data/model/order.dart';
import 'package:oezbooking/features/orders/domain/entity/order_entity.dart';
import 'package:oezbooking/features/orders/domain/repository/order_repository.dart';

 class OrderRepositoryImpl extends OrderRepository{
   final OrderDatasource datasource;

   OrderRepositoryImpl(this.datasource);

  @override
  Future<List<Order>> fetchOrders(String organizer) async{
    return await datasource.fetchOrders(organizer);
  }

  @override
  Future<List<OrderEntity>> fetchOrdersEntity(String organizer) async {
    final orders = await datasource.fetchOrders(organizer);

    final results = await Future.wait(orders.map((order) async {
      // Fetch the associated event for the order
      final event = await datasource.fetchEventOrder(order.eventID);

      // Fetch additional user data if needed (e.g., fullName) - placeholder logic here
      String? fullName;
      fullName = await datasource.fetchUserOrder(order.userID);

      // Create and return an OrderEntity
      return OrderEntity(order, event, fullName);
    }));

    return results;
  }


}
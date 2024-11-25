import 'package:oezbooking/features/orders/data/model/order.dart';
import 'package:oezbooking/features/orders/domain/entity/order_entity.dart';
import 'package:oezbooking/features/orders/domain/repository/order_repository.dart';

class FetchOrdersUseCase {
  final OrderRepository repository;

  FetchOrdersUseCase(this.repository);

  Future<List<OrderEntity>> call(String organizer) async {
    return await repository.fetchOrdersEntity(organizer);
  }
}

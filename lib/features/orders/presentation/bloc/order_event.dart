abstract class OrderEvent {}
class FetchOrderList extends OrderEvent{
  String organizerID;

  FetchOrderList(this.organizerID);
}

class SearchOrder extends OrderEvent {
  final String query;

  SearchOrder(this.query);
}
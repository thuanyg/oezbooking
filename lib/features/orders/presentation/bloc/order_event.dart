abstract class OrderEvent {}
class FetchOrderList extends OrderEvent{
  String organizerID;

  FetchOrderList(this.organizerID);
}
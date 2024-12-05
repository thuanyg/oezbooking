import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_bloc.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_event.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_state.dart';
import 'package:oezbooking/features/orders/presentation/page/order_detail_page.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late OrderBloc orderBloc;
  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    orderBloc = BlocProvider.of<OrderBloc>(context);
    loginBloc = BlocProvider.of<LoginBloc>(context);
    orderBloc.add(FetchOrderList(loginBloc.organizer?.id ?? ""));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1F25),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xFF1A1F25),
        foregroundColor: Colors.white,
        title: const Text(
          'Orders',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildFilterSection(),
          Expanded(
            child: _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          orderBloc.add(SearchOrder(value.toLowerCase().trim()));
        },
        decoration: InputDecoration(
          hintText: 'Search orders...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF272D36),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildOrdersList() {
    return BlocBuilder(
      bloc: orderBloc,
      builder: (context, state) {
        if (state is OrderLoading) {
          return Center(
            child: Lottie.asset(
              "assets/animations/loading.json",
              height: 60,
            ),
          );
        }
        if (state is OrdersLoaded) {
          final orders = state.orders;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index].order;
              final event = orders[index].event;
              final userFullName = orders[index].fullName;
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF272D36),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  splashColor: Colors.transparent,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "#${order.id}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(order.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          order.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(
                        event.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: $userFullName',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Paid: ${DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt.toDate())}',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${order.ticketQuantity} tickets',
                            style: TextStyle(
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            '\$${order.ticketPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            OrderDetailPage(orderEntity: orders[index]),
                      ),
                    );
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

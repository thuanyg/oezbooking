import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:oezbooking/core/apps/app_colors.dart';
import 'package:oezbooking/features/login/presentation/bloc/login_bloc.dart';
import 'package:oezbooking/features/orders/data/model/order.dart';
import 'package:oezbooking/features/orders/domain/entity/order_entity.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_bloc.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_event.dart';
import 'package:oezbooking/features/orders/presentation/bloc/order_state.dart';

class RevenueAnalyticsPage extends StatefulWidget {
  const RevenueAnalyticsPage({super.key});

  @override
  _RevenueAnalyticsPageState createState() => _RevenueAnalyticsPageState();
}

class _RevenueAnalyticsPageState extends State<RevenueAnalyticsPage> {
  late DateTimeRange _selectedDateRange;
  String _selectedTimeframe = 'This Month';

  late OrderBloc orderBloc;
  late LoginBloc loginBloc;

  @override
  void initState() {
    super.initState();
    _selectedDateRange = DateTimeRange(
      start: DateTime.now().subtract(const Duration(days: 30)),
      end: DateTime.now(),
    );
    orderBloc = BlocProvider.of<OrderBloc>(context);
    loginBloc = BlocProvider.of<LoginBloc>(context);
    orderBloc.add(FetchOrderList(loginBloc.organizer?.id ?? ""));
  }

  // Calculate total revenue
  double _calculateTotalRevenue(List<Order> orders) {
    return orders
        .where((order) =>
            order.createdAt.toDate().isAfter(_selectedDateRange.start) &&
            order.createdAt.toDate().isBefore(_selectedDateRange.end))
        .map((order) => order.totalPrice * 0.9)
        .fold(0.0, (double a, double b) => a + b);
  }

  // Calculate revenue by event type
  Map<String, double> _calculateRevenueByEventType(
      List<OrderEntity> orderEntity) {
    final filteredOrders = orderEntity.where((order) => order.order.status == "success" &&
        order.order.createdAt.toDate().isAfter(_selectedDateRange.start) &&
        order.order.createdAt.toDate().isBefore(_selectedDateRange.end));

    Map<String, double> revenueByEventType = {};

    for (var order in filteredOrders) {
      final event =
          orderEntity.firstWhere((e) => e.event.id == order.order.eventID);
      revenueByEventType[event.event.eventType] =
          (revenueByEventType[event.event.eventType] ?? 0) +
              order.order.totalPrice * 0.9;
    }

    return revenueByEventType;
  }

  // Prepare line chart data
  List<FlSpot> _prepareLineChartData(List<OrderEntity> orderEntity) {
    Map<DateTime, double> dailyRevenue = {};

    for (var order in orderEntity) {
      final orderDate = order.order.createdAt.toDate();
      if (orderDate.isAfter(_selectedDateRange.start) && order.order.status == "success" &&
          orderDate.isBefore(_selectedDateRange.end)) {
        final dateKey =
            DateTime(orderDate.year, orderDate.month, orderDate.day);
        dailyRevenue[dateKey] =
            (dailyRevenue[dateKey] ?? 0) + order.order.totalPrice * .9;
      }
    }

    return dailyRevenue.entries
        .map((entry) =>
            FlSpot(entry.key.millisecondsSinceEpoch.toDouble(), entry.value))
        .toList();
  }

  // Calculate additional order statistics
  Map<String, dynamic> _calculateOrderStatistics(
      List<OrderEntity> orderEntity) {
    final filteredOrders = orderEntity
        .where((order) =>
            order.order.createdAt.toDate().isAfter(_selectedDateRange.start) && order.order.status == "success" &&
            order.order.createdAt.toDate().isBefore(_selectedDateRange.end))
        .toList();

    return {
      'totalOrders': filteredOrders.length,
      'averageOrderValue': filteredOrders.isNotEmpty
          ? filteredOrders
                  .map((o) => o.order.totalPrice * .9)
                  .fold<double>(0.0, (a, b) => a + b) /
              filteredOrders.length
          : 0.0,
      'mostFrequentEventType': _getMostFrequentEventType(filteredOrders),
      'ordersByDay': _groupOrdersByDay(filteredOrders),
    };
  }

  String _getMostFrequentEventType(List<OrderEntity> orders) {
    final eventTypeCounts = <String, int>{};
    for (var order in orders) {
      final event = orders.firstWhere((e) => e.event.id == order.order.eventID);
      eventTypeCounts[event.event.eventType] =
          (eventTypeCounts[event.event.eventType] ?? 0) + 1;
    }
    return eventTypeCounts.isEmpty
        ? 'N/A'
        : eventTypeCounts.entries
            .reduce((a, b) => a.value > b.value ? a : b)
            .key;
  }

  Map<String, int> _groupOrdersByDay(List<OrderEntity> orders) {
    final ordersByDay = <String, int>{};
    for (var order in orders) {
      final dateKey =
          DateFormat('yyyy-MM-dd').format(order.order.createdAt.toDate());
      ordersByDay[dateKey] = (ordersByDay[dateKey] ?? 0) + 1;
    }
    return ordersByDay;
  }

  void _showDateRangePickerDialog() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryColor,
              surface: AppColors.backgroundColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Revenue Analytics',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        backgroundColor: AppColors.drawerColor,
        actions: [
          TextButton(
            onPressed: _showDateRangePickerDialog,
            child: Text(
              _selectedTimeframe,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: BlocBuilder(
        bloc: orderBloc,
        builder: (context, state) {
          if (state is OrderLoading) {
            return Center(
              child: Lottie.asset(
                "assets/animations/loading.json",
                width: 80,
                fit: BoxFit.cover,
              ),
            );
          }

          if (state is OrdersLoaded) {
            final order = state.orders
                .map((o) => o.order)
                .where((e) => e.status == "success")
                .toList();

            final totalRevenue = _calculateTotalRevenue(order);

            final revenueByEventType =
                _calculateRevenueByEventType(state.orders);

            final lineChartData = _prepareLineChartData(state.orders);

            final orderStats = _calculateOrderStatistics(state.orders);
            print(lineChartData);

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Revenue Card
                    _buildTotalRevenueCard(totalRevenue),

                    const SizedBox(height: 20),

                    // Order Statistics Grid
                    _buildOrderStatisticsGrid(orderStats),

                    const SizedBox(height: 20),

                    // Revenue by Event Type
                    _buildRevenueByEventTypeChart(revenueByEventType),

                    const SizedBox(height: 20),

                    // Daily Revenue Line Chart
                    // _buildDailyRevenueLineChart(lineChartData),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildOrderStatisticsGrid(Map<String, dynamic> orderStats) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.drawerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Statistics',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _buildStatisticCard(
                title: 'Total Orders',
                value: orderStats['totalOrders'].toString(),
                icon: Icons.shopping_cart,
              ),
              _buildStatisticCard(
                title: 'Avg. Order Value',
                value:
                    '\$${orderStats['averageOrderValue'].toStringAsFixed(2)}',
                icon: Icons.attach_money,
              ),
              _buildStatisticCard(
                title: 'Popular Event Type',
                value: orderStats['mostFrequentEventType'],
                icon: Icons.event,
              ),
              _buildStatisticCard(
                title: 'Max Daily Orders',
                value: orderStats['ordersByDay'].values.isNotEmpty
                    ? orderStats['ordersByDay']
                        .values
                        .cast<int>()
                        .reduce((int a, int b) => a > b ? a : b)
                        .toString()
                    : '0',
                icon: Icons.bar_chart,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      color: AppColors.backgroundColor.withOpacity(0.5),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 30),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Existing methods (_buildTotalRevenueCard, _buildRevenueByEventTypeChart,
// _buildDailyRevenueLineChart) remain the same as in the previous implementation

  Widget _buildTotalRevenueCard(double totalRevenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.drawerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Revenue',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            '\$${NumberFormat('#,##0.00').format(totalRevenue)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueByEventTypeChart(Map<String, double> revenueByEventType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.drawerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Revenue by Event Type',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            height: 210,
            child: PieChart(
              PieChartData(
                sections: revenueByEventType.entries
                    .map((entry) => PieChartSectionData(
                          color: AppColors.primaryColor.withOpacity(0.7),
                          value: entry.value,
                          title:
                              '${entry.key}\n\$${NumberFormat('#,##0.00').format(entry.value)}',
                          radius: 74,
                          titleStyle: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ))
                    .toList(),
                centerSpaceRadius: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyRevenueLineChart(List<FlSpot> lineChartData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.drawerColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daily Revenue',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 250,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.white10,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final date =
                            DateTime.fromMillisecondsSinceEpoch(value.toInt());
                        return Text(
                          DateFormat('MM/dd').format(date),
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Text(
                        '\$${value.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: lineChartData,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor,
                        AppColors.primaryColor.withOpacity(0.5),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor.withOpacity(0.3),
                          AppColors.primaryColor.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

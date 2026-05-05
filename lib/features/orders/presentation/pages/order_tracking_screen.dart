import 'package:flutter/material.dart';
import '../widgets/tracking_map_widget.dart';
import '../widgets/driver_info_widget.dart';
import '../widgets/order_timeline_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            const TrackingMapWidget(),
            _buildBackButton(theme),
            _buildDraggableSheet(theme, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(ThemeData theme) {
    return Positioned(
      top: 50,
      right: 20,
      child: FloatingActionButton.small(
        backgroundColor: theme.colorScheme.surface,
        child: Icon(Icons.arrow_back_ios, color: theme.colorScheme.onSurface),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildDraggableSheet(ThemeData theme, bool isDark) {
    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.35,
      maxChildSize: 0.8,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(isDark ? 0.6 : 0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(25),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const DriverInfoWidget(name: "أحمد سعيد المقطري"),
              const Divider(height: 40),
              const OrderTimelineWidget(),
              const SizedBox(height: 30),
              _buildOrderSummary(theme),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(ThemeData theme) {
    return Text(
      "طلب رقم: #${widget.orderId}",
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }
}

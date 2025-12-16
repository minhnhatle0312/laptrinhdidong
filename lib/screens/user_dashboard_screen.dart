import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // THÊM IMPORT
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import '../providers/repair_tickets_provider.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({super.key});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    final authProvider = context.read<AuthProvider>();
    final dashboardProvider = context.read<DashboardProvider>();
    final repairTicketsProvider = context.read<RepairTicketsProvider>();

    if (authProvider.currentUser != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        dashboardProvider.loadUserStats(authProvider.currentUser!.uid);
        repairTicketsProvider.loadCustomerTickets(); 
      });
    }
  }

  // Helper: Lấy văn bản trạng thái (Sao chép cho tính nhất quán)
  String _getStatusText(String status) {
    switch (status) {
      case 'received':
        return 'Nhận xe';
      case 'waiting':
        return 'Chờ xử lý';
      case 'repairing':
        return 'Đang sửa';
      case 'completed':
        return 'Hoàn thành';
      case 'held':
        return 'Tạm giữ';
      case 'delivered':
        return 'Giao xe';
      default:
        return status;
    }
  }

  // Helper: Lấy Chip trạng thái (Sao chép cho tính nhất quán)
  Widget _getStatusChip(String status) {
    Color color;
    switch (status) {
      case 'received':
      case 'waiting':
        color = Colors.orange;
        break;
      case 'repairing':
        color = Colors.blue;
        break;
      case 'completed':
      case 'delivered':
        color = Colors.green;
        break;
      case 'held':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        _getStatusText(status),
        style: const TextStyle(color: Colors.white, fontSize: 12),
      ),
      backgroundColor: color,
    );
  }

  // Tối ưu hóa UI: Thẻ thống kê nổi bật hơn
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3), 
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 36), // Icon lớn hơn
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  // Tối ưu hóa UI: Thẻ hành động nhanh có màu sắc rõ ràng hơn
  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return Expanded(
      child: Card(
      color: color.withValues(alpha: 0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.4), width: 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final repairTicketsProvider = context.watch<RepairTicketsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển khách hàng'),
        elevation: 0,
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: () async => _loadDashboardData(),
            child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section (Cập nhật UI)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ]
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Xin chào,',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                          Text(
                            authProvider.currentUser?.email?.split('@')[0] ?? 'Khách hàng',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Quản lý xe và lịch sử bảo dưỡng của bạn',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Stats row (Sử dụng _buildStatCard mới)
                    Text(
                      'Thống kê',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: [
                        _buildStatCard(
                          context,
                          'Xe của tôi',
                          dashboardProvider.userStats['myVehicles']?.toString() ?? '0',
                          Icons.directions_car,
                          Colors.blue,
                        ),
                        _buildStatCard(
                          context,
                          'Bảo dưỡng đang chờ',
                          dashboardProvider.userStats['activeTickets']?.toString() ?? '0',
                          Icons.pending_actions,
                          Colors.orange,
                        ),
                        _buildStatCard(
                          context,
                          'Đã hoàn thành',
                          dashboardProvider.userStats['completedTickets']?.toString() ?? '0',
                          Icons.check_circle,
                          Colors.green,
                        ),
                        _buildStatCard(
                          context,
                          'Tổng chi tiêu',
                          '${(dashboardProvider.userStats['totalSpent'] ?? 0).toStringAsFixed(0)} đ',
                          Icons.payments,
                          Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Quick actions (Sử dụng _buildQuickActionButton mới)
                    Text(
                      'Thao tác nhanh',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildQuickActionButton(
                          context, 
                          'Xe của tôi', 
                          Icons.directions_car, 
                          () => context.go('/vehicles'), // Điều hướng thực tế
                          Colors.blue,
                        ),
                        _buildQuickActionButton(
                          context, 
                          'Bảo dưỡng', 
                          Icons.build, 
                          () => context.go('/repairs'), // Điều hướng thực tế
                          Colors.orange,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildQuickActionButton(
                          context, 
                          'Bãi xe', 
                          Icons.location_on, 
                          () => context.go('/map'), // Điều hướng thực tế
                          Colors.green,
                        ),
                        _buildQuickActionButton(
                          context, 
                          'Lịch sử TT', 
                          Icons.history, 
                          () => context.go('/payments-history'), // Điều hướng thực tế
                          Colors.purple,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Recent tickets (Giao diện đơn giản)
                    Text(
                      'Bảo dưỡng gần đây',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    repairTicketsProvider.customerTickets.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Chưa có bảo dưỡng nào'),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                repairTicketsProvider.customerTickets.length > 5
                                    ? 5
                                    : repairTicketsProvider.customerTickets.length,
                            itemBuilder: (context, index) {
                              final ticket =
                                  repairTicketsProvider.customerTickets[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                elevation: 1,
                                child: ListTile(
                                  leading: const Icon(Icons.receipt_long),
                                  title: Text('Bảo dưỡng #${ticket.id}'),
                                  subtitle: Text(
                                    'Trạng thái: ${_getStatusText(ticket.status)}',
                                  ),
                                  trailing: _getStatusChip(ticket.status),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
          ),
    );
  }
}
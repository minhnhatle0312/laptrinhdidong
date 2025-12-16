import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../providers/repair_tickets_provider.dart';
import '../providers/services_provider.dart';
import '../providers/staff_provider.dart';
import '../widgets/revenue_bar_chart.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // initial load
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Disable Firebase loads for now to prevent hanging
      // context.read<DashboardProvider>().loadAdminStats();
      // context.read<ServicesProvider>().loadServices();
      // context.read<StaffProvider>().loadStaff();
      // Ensure all tickets are loaded for Admin statistics
      context.read<RepairTicketsProvider>().loadAllTickets(); 
    });
    // Return a small delay so callers (RefreshIndicator) receive a Future
    await Future.delayed(const Duration(milliseconds: 300));
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

  // Tối ưu hóa UI: Thẻ thống kê nổi bật hơn (Áp dụng phong cách User Dashboard)
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
                    fontSize: 22, // Nhỏ hơn chút cho Grid 4 items
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
  
  // Tối ưu hóa UI: Card quản lý (Áp dụng BoxShadow)
  Widget _buildManagementCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 4,
      shadowColor: color.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: color, size: 32),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = context.watch<DashboardProvider>();
    final repairTicketsProvider = context.watch<RepairTicketsProvider>();
    final servicesProvider = context.watch<ServicesProvider>();
    final staffProvider = context.watch<StaffProvider>();

    // Lọc phiếu chờ xử lý
    final pendingTickets = repairTicketsProvider.allTickets.where((t) => ['received', 'waiting'].contains(t.status)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bảng điều khiển quản trị'),
        elevation: 0,
      ),
      body: dashboardProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
            onRefresh: () => _loadAdminData(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main stats
                  Text(
                    'Tổng quan Hệ thống',
                    style: Theme.of(context).textTheme.headlineSmall,
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
                        'Khách hàng',
                        dashboardProvider.adminStats['totalCustomers']?.toString() ?? '0',
                        Icons.people,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        context,
                        'Xe trong hệ thống',
                        dashboardProvider.adminStats['totalVehicles']?.toString() ?? '0',
                        Icons.directions_car,
                        Colors.green,
                      ),
                      _buildStatCard(
                        context,
                        'Phiếu bảo dưỡng',
                        dashboardProvider.adminStats['totalTickets']?.toString() ?? '0',
                        Icons.build,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        context,
                        'Đang chờ xử lý',
                        dashboardProvider.adminStats['pendingTickets']?.toString() ?? '0',
                        Icons.pending_actions,
                        Colors.red,
                      ),
                      // Hàng thứ 3
                      _buildStatCard(
                        context,
                        'Nhân viên',
                        dashboardProvider.adminStats['totalStaff']?.toString() ?? '0',
                        Icons.badge,
                        Colors.purple,
                      ),
                      _buildStatCard(
                        context,
                        'Tổng doanh thu',
                        '${(dashboardProvider.adminStats['totalRevenue'] ?? 0).toStringAsFixed(0)} đ',
                        Icons.trending_up,
                        Colors.teal,
                      ),
                      _buildManagementCard(
                        context,
                        'Báo cáo & Thống kê',
                        'Xem chi tiết báo cáo',
                        Icons.analytics,
                        Colors.red,
                        () {
                          GoRouter.of(context).go('/reports'); // THÊM ĐIỀU HƯỚNG MỚI
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Revenue Bar Chart (sample data for now)
                  Text(
                    'Biểu đồ doanh thu 6 tháng',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  RevenueBarChart(
                    monthlyRevenue: const [32000000, 25000000, 28000000, 30000000, 27000000, 35000000],
                    months: const ['1', '2', '3', '4', '5', '6'],
                  ),
                  const SizedBox(height: 24),

                  // Management sections
                  Text(
                    'Quản lý Chuyên sâu',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  _buildManagementCard(
                    context,
                    'Dịch vụ bảo dưỡng',
                    'Quản lý các dịch vụ (${servicesProvider.services.length})',
                    Icons.miscellaneous_services,
                    Colors.indigo,
                    () {
                      // TODO: Navigate to services management
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildManagementCard(
                    context,
                    'Nhân viên',
                    'Quản lý nhân viên (${staffProvider.staff.length})',
                    Icons.people,
                    Colors.blue,
                    () {
                      // TODO: Navigate to staff management
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildManagementCard(
                    context,
                    'Phiếu bảo dưỡng',
                    'Xem tất cả phiếu',
                    Icons.assignment,
                    Colors.orange,
                    () {
                      // TODO: Navigate to all repair tickets
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildManagementCard(
                    context,
                    'Khách hàng',
                    'Quản lý khách hàng',
                    Icons.contacts,
                    Colors.green,
                    () {
                      // TODO: Navigate to customers management
                    },
                  ),
                  const SizedBox(height: 8),
                  _buildManagementCard(
                    context,
                    'Báo cáo & Thống kê',
                    'Xem chi tiết báo cáo',
                    Icons.analytics,
                    Colors.red,
                    () {
                      // TODO: Navigate to reports
                    },
                  ),
                  const SizedBox(height: 24),

                  // Recent pending tickets
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Phiếu chờ xử lý (${pendingTickets.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to all pending
                        },
                        child: const Text('Xem tất cả'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  pendingTickets.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Không có phiếu chờ xử lý'),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: pendingTickets.length > 5
                                  ? 5
                                  : pendingTickets.length,
                          itemBuilder: (context, index) {
                            final ticket = pendingTickets[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 1,
                              child: ListTile(
                                leading: const Icon(Icons.build_circle),
                                title: Text('Phiếu #${ticket.id}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Xe: ${ticket.vehicleId}'),
                                    Text('Trạng thái: ${_getStatusText(ticket.status)}'),
                                  ],
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
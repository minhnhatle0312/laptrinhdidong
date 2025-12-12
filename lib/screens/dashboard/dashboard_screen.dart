import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/parking_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Khởi tạo Animation Controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    // Khởi tạo Scale Animation
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    // Tải dữ liệu và chạy animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).loadSpots();
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        color: color.withAlpha((0.1 * 255).round()),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: color.withAlpha((0.3 * 255).round())),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 36, color: color),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);
    final total = provider.spots.length;
    final available = provider.spots.where((s) => s.isAvailable).length;
    final occupied = total - available;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tổng quan Gara',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.go('/settings'), // Sử dụng GoRouter
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadSpots,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. Thống kê chung (Sử dụng GridView) ---
                    SizedBox(
                      height: 180,
                      child: GridView(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              childAspectRatio: 0.9,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        children: [
                          _buildStatCard(
                            icon: Icons.local_parking,
                            title: 'Tổng bãi',
                            subtitle: '$total',
                            color: Colors.indigo,
                          ),
                          _buildStatCard(
                            icon: Icons.check_circle_outline,
                            title: 'Còn trống',
                            subtitle: '$available',
                            color: Colors.green,
                          ),
                          _buildStatCard(
                            icon: Icons.block,
                            title: 'Đã đặt',
                            subtitle: '$occupied',
                            color: Colors.red,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 2. Quản lý Xe (Nút lớn) ---
                    InkWell(
                      onTap: () => context.go('/vehicles'),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: const ListTile(
                          contentPadding: EdgeInsets.all(16),
                          leading: Icon(
                            Icons.directions_car,
                            size: 40,
                            color: Colors.orange,
                          ),
                          title: Text(
                            'Quản lý Phương tiện',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Đăng ký, sửa đổi, lịch sử xe',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- 3. Hoạt động Gần đây ---
                    const Text(
                      'Hoạt động Gần đây',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: provider.spots.isEmpty
                          ? const Center(child: Text('Chưa có dữ liệu bãi xe'))
                          : ListView.builder(
                              itemCount: provider.spots.length > 5
                                  ? 5
                                  : provider
                                        .spots
                                        .length, // Chỉ hiển thị 5 hoạt động gần nhất
                              itemBuilder: (_, i) {
                                final s = provider.spots[i];
                                return ListTile(
                                  leading: Icon(
                                    s.isAvailable
                                        ? Icons.check_circle_outline
                                        : Icons.schedule,
                                    color: s.isAvailable
                                        ? Colors.green
                                        : Colors.blueGrey,
                                  ),
                                  title: Text(
                                    s.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${s.isAvailable ? 'Trống' : 'Đã đặt'} - Giá: ${s.pricePerHour}/giờ',
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    // Chuyển đến màn hình chi tiết bãi xe nếu cần
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

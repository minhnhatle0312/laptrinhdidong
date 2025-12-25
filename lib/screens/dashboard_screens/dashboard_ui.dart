import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/reception.dart';
import '../services/service_list_screen.dart';
import '../staff/staff_list_screen.dart';
import '../revenue/revenue_screen.dart';
import 'dashboard_controller.dart';
import '../../services/revenue_firestore.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardController _controller = DashboardController();
  final RevenueFirestore _revenueService = RevenueFirestore();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, child) {
        final List<Widget> pages = [
          _buildOverviewPage(),
          const ServiceListScreen(),
          const StaffListScreen(),
          RevenueScreen(firestore: _revenueService),
        ];

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám xanh rất nhạt sang trọng
          body: pages[_controller.currentIndex],
          
          // Custom Bottom Navigation Bar
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _controller.currentIndex,
              onDestinationSelected: _controller.setIndex,
              backgroundColor: Colors.white,
              elevation: 0,
              indicatorColor: Colors.blue.shade50,
              labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.grid_view_outlined),
                  selectedIcon: Icon(Icons.grid_view_rounded, color: Colors.blue),
                  label: 'Tổng quan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.build_circle_outlined),
                  selectedIcon: Icon(Icons.build_circle_rounded, color: Colors.blue),
                  label: 'Dịch vụ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  selectedIcon: Icon(Icons.people_rounded, color: Colors.blue),
                  label: 'Nhân viên',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pie_chart_outline),
                  selectedIcon: Icon(Icons.pie_chart_rounded, color: Colors.blue),
                  label: 'Doanh thu',
                ),
              ],
            ),
          ),
          
          floatingActionButton: (_controller.currentIndex == 1 || _controller.currentIndex == 2)
              ? FloatingActionButton.extended(
                  onPressed: () {
                    if (_controller.currentIndex == 1) {
                      context.push('/service_form');
                    } else if (_controller.currentIndex == 2) {
                      context.push('/staff_form');
                    }
                  },
                  backgroundColor: const Color(0xFF2E86DE),
                  icon: const Icon(Icons.add),
                  label: Text(_controller.currentIndex == 1 ? 'Thêm Dịch vụ' : 'Thêm Nhân viên'),
                  elevation: 4,
                )
              : null,
        );
      },
    );
  }

  Widget _buildOverviewPage() {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildWarningsSection(),
                const SizedBox(height: 12),
                _buildActiveReceptionsSection(),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 180.0,
      floating: false,
      pinned: true,
      backgroundColor: const Color(0xFF2E86DE),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2E86DE), Color(0xFF54A0FF)],
            ),
          ),
          child: Stack(
            children: [
              // Họa tiết trang trí nền
              Positioned(
                right: -30,
                top: -30,
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: -20,
                bottom: -40,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      _controller.formatDate(DateTime.now()),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _controller.getGreeting(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Garage Admin',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return StreamBuilder<List<Reception>>(
      stream: _controller.receptionsStream,
      builder: (context, snapshot) {
        final receptions = snapshot.data ?? [];
        final todayCount = _controller.countTodayReceptions(receptions);
        final carsInShop = _controller.countCarsInShop(receptions);
        final processing = _controller.countProcessing(receptions);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Khách hôm nay',
                    value: '$todayCount',
                    icon: Icons.person_add_alt_1_rounded,
                    color: const Color(0xFF1DD1A1), // Xanh mint
                    onTap: () => context.push('/receptions'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'Xe trong xưởng',
                    value: '$carsInShop',
                    icon: Icons.directions_car_filled_rounded,
                    color: const Color(0xFFFF9F43), // Cam
                    onTap: () => context.push('/receptions'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Đang xử lý',
                    value: '$processing',
                    icon: Icons.handyman_rounded,
                    color: const Color(0xFF5F27CD), // Tím
                    onTap: () => context.push('/receptions'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FutureBuilder<double>(
                    future: _controller.todayRevenueFuture,
                    builder: (context, snapshot) {
                      final revenue = snapshot.data ?? 0.0;
                      return _buildStatCard(
                        title: 'Doanh thu',
                        value: _controller.formatMoneyShort(revenue),
                        icon: Icons.attach_money_rounded,
                        color: const Color(0xFF2E86DE), // Xanh dương
                        onTap: () => _controller.setIndex(3),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWarningsSection() {
    return StreamBuilder<List<Reception>>(
      stream: _controller.receptionsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final warnings = _controller.getWarnings(snapshot.data!);
        if (warnings.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cần chú ý',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ...warnings.map((w) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: w['bg_color'],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: (w['color'] as Color).withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(w['icon'], color: w['color'], size: 20),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          w['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: w['color'],
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          w['message'],
                          style: TextStyle(
                            fontSize: 13,
                            color: (w['color'] as Color).withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
            const SizedBox(height: 12),
          ],
        );
      },
    );
  }

  Widget _buildActiveReceptionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tiến độ xưởng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            TextButton(
              onPressed: () => context.push('/receptions'),
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF2E86DE)),
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
        const SizedBox(height: 4),
        StreamBuilder<List<Reception>>(
          stream: _controller.receptionsStream,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final active = _controller.getActiveReceptions(snapshot.data!);

            if (active.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_rounded, size: 60, color: Colors.green.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Tất cả công việc đã hoàn thành!',
                        style: TextStyle(color: Colors.grey[500], fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: active.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _buildActiveReceptionItem(active[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActiveReceptionItem(Reception r) {
    final bool isProgress = r.status == 'in_progress';
    final Color color = isProgress ? const Color(0xFF2E86DE) : const Color(0xFFFF9F43);
    final Color bgColor = isProgress ? const Color(0xFFEBF5FB) : const Color(0xFFFFF2E2);
    final IconData icon = isProgress ? Icons.handyman : Icons.hourglass_top;
    final String statusText = isProgress ? 'Đang sửa chữa' : 'Đang chờ';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push('/task-assignments/${r.id}'),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${r.id.substring(0, 6).toUpperCase()}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${r.staffIds.length} nhân viên',
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.schedule, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            _controller.formatDate(r.createdAt),
                            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
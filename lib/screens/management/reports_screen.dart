import 'package:flutter_animate/flutter_animate.dart';
// screens/management/reports_screen.dart


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/repair_tickets_provider.dart';
import '../../widgets/animated_scaffold.dart';
import '../../widgets/revenue_bar_chart.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}



class _ReportsScreenState extends State<ReportsScreen> {
  DateTimeRange? _selectedRange;
  List<dynamic> _filteredTickets = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepairTicketsProvider>().loadAllTickets();
      _selectedRange = null;
    });
  }

  void _filterTickets(List<dynamic> tickets) {
    if (_selectedRange == null) {
      _filteredTickets = tickets;
    } else {
      _filteredTickets = tickets.where((t) {
        return t.createdAt.isAfter(_selectedRange!.start.subtract(const Duration(days: 1))) &&
               t.createdAt.isBefore(_selectedRange!.end.add(const Duration(days: 1)));
      }).toList();
    }
  }

  Future<void> _pickDateRange(BuildContext context, List<dynamic> tickets) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      initialDateRange: _selectedRange ?? DateTimeRange(start: now.subtract(const Duration(days: 30)), end: now),
    );
    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        _filterTickets(tickets);
      });
    }
  }

  Future<void> _exportToCSV(List<dynamic> tickets) async {
    final buffer = StringBuffer();
    buffer.writeln('ID,Ngày tạo,Khách hàng,Xe,Tổng tiền,Trạng thái');
    for (var t in tickets) {
      buffer.writeln('${t.id},${DateFormat('yyyy-MM-dd').format(t.createdAt)},${t.customerId},${t.vehicleId},${t.totalCost},${t.status}');
    }
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/bao_cao_gara.csv');
    await file.writeAsString(buffer.toString());
    await Share.shareXFiles([XFile(file.path)], text: 'Báo cáo phiếu bảo dưỡng');
  }
  
  // Widget hiển thị thẻ thống kê tài chính
  Widget _buildReportStatCard(
    BuildContext context,
    String label,
    double value,
    IconData icon,
    Color color,
    bool isPercent,
  ) {
    final displayValue = isPercent ? '${value.toStringAsFixed(1)}%' : '${value.toStringAsFixed(0)} đ';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.13),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: color.withOpacity(0.09),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 36),
            ),
            const SizedBox(width: 18),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayValue,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RepairTicketsProvider>();
    final report = provider.getReportOverview();
    final allTickets = provider.allTickets.where((t) => ['completed', 'delivered'].contains(t.status)).toList();
    _filterTickets(allTickets);

    return AnimatedScaffold(
      title: 'Báo cáo Tài chính',
      automaticallyImplyLeading: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: provider.loadAllTickets,
        ),
      ],
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadAllTickets,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phân tích Tổng quan (Phiếu đã Hoàn thành)',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return GridView.count(
                          crossAxisCount: isWide ? 2 : 1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildReportStatCard(
                              context,
                              'Tổng Doanh thu',
                              report['totalRevenue']!,
                              Icons.trending_up,
                              Colors.green.shade600,
                              false,
                            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                            _buildReportStatCard(
                              context,
                              'Tổng Chi phí (COGS)',
                              report['totalCogs']!,
                              Icons.shopping_cart,
                              Colors.red.shade600,
                              false,
                            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.13, end: 0, curve: Curves.easeOut),
                            _buildReportStatCard(
                              context,
                              'Lợi nhuận Ròng',
                              report['netProfit']!,
                              Icons.attach_money,
                              Colors.indigo,
                              false,
                            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.16, end: 0, curve: Curves.easeOut),
                            _buildReportStatCard(
                              context,
                              'Tỷ lệ Lợi nhuận',
                              report['profitMargin']!,
                              Icons.percent,
                              Colors.purple,
                              true,
                            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.19, end: 0, curve: Curves.easeOut),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    // Revenue Bar Chart (sample data for now)
                    Text(
                      'Biểu đồ doanh thu 6 tháng',
                      style: Theme.of(context).textTheme.titleLarge,
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 12),
                    RevenueBarChart(
                      monthlyRevenue: const [32000000, 25000000, 28000000, 30000000, 27000000, 35000000],
                      months: const ['1', '2', '3', '4', '5', '6'],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.13, end: 0, curve: Curves.easeOut),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chi tiết Phiếu Bảo dưỡng',
                          style: Theme.of(context).textTheme.titleLarge,
                        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.filter_alt),
                              tooltip: 'Lọc theo ngày',
                              onPressed: () => _pickDateRange(context, allTickets),
                            ),
                            IconButton(
                              icon: const Icon(Icons.download),
                              tooltip: 'Xuất CSV',
                              onPressed: () => _exportToCSV(_filteredTickets),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _filteredTickets.isEmpty
                        ? const Center(child: Text('Không có phiếu nào trong khoảng thời gian này.'))
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DataTable(
                              headingRowColor: MaterialStateProperty.all(Colors.blueGrey.shade50),
                              columnSpacing: 18,
                              columns: const [
                                DataColumn(label: Text('ID')),
                                DataColumn(label: Text('Ngày tạo')),
                                DataColumn(label: Text('Xe')),
                                DataColumn(label: Text('Tổng tiền')),
                                DataColumn(label: Text('Lợi nhuận')),
                                DataColumn(label: Text('Trạng thái')),
                              ],
                              rows: _filteredTickets.map<DataRow>((t) {
                                final profit = t.totalCost * 0.7;
                                return DataRow(cells: [
                                  DataCell(Text(t.id)),
                                  DataCell(Text(DateFormat('yyyy-MM-dd').format(t.createdAt))),
                                  DataCell(Text(t.vehicleId)),
                                  DataCell(Text('${t.totalCost.toStringAsFixed(0)} đ')),
                                  DataCell(Text('${profit.toStringAsFixed(0)} đ')),
                                  DataCell(Text(t.status)),
                                ]);
                              }).toList(),
                            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOut),
                          ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
    );
  }
}
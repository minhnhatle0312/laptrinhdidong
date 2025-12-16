import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // THÊM IMPORT
import '../providers/repair_tickets_provider.dart';
import '../providers/staff_provider.dart';
import '../models/RepairTicket.dart';
import '../models/Staff.dart';

class RepairsScreen extends StatefulWidget {
  const RepairsScreen({super.key});

  @override
  State<RepairsScreen> createState() => _RepairsScreenState();
}

class _RepairsScreenState extends State<RepairsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RepairTicketsProvider>().loadAllTickets();
      // Đảm bảo tải danh sách nhân viên để phân công
      context.read<StaffProvider>().loadStaff(); 
    });
  }
  
  // Helper: Lấy văn bản trạng thái
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

  // Helper: Lấy Chip trạng thái
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
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
    );
  }

  // Dialog phân công nhân viên
  void _showAssignStaffDialog(BuildContext context, RepairTicket ticket) {
    final staffProvider = context.read<StaffProvider>();
    final ticketProvider = context.read<RepairTicketsProvider>();
    
    final assignableStaff = staffProvider.staff
        .where((s) => s.isActive && ['mechanic', 'manager'].contains(s.position)) // Chỉ lấy nhân viên đang hoạt động
        .toList();

    String? selectedStaffId = ticket.assignedStaffId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setState) {
          return AlertDialog(
            title: Text('Phân công Phiếu #${ticket.id}'),
            content: DropdownButtonFormField<String>(
              value: selectedStaffId,
              decoration: const InputDecoration(labelText: 'Chọn Kỹ thuật viên'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Chưa phân công')),
                ...assignableStaff.map((s) => DropdownMenuItem(
                  value: s.id,
                  child: Text('${s.name} (${s.specialization})'),
                )).toList(),
              ],
              onChanged: (v) => setState(() => selectedStaffId = v),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final updatedTicket = ticket.copyWith(
                    assignedStaffId: selectedStaffId,
                    // Tự động chuyển trạng thái sang "Đang sửa" nếu được phân công lần đầu và đang ở trạng thái chờ
                    status: (selectedStaffId != null && (ticket.status == 'waiting' || ticket.status == 'received')) ? 'repairing' : ticket.status,
                  );

                  final success = await ticketProvider.updateTicket(updatedTicket);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã phân công thành công cho Phiếu #${ticket.id}'),
                      ),
                    );
                  }
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RepairTicketsProvider>(context);
    final staffProvider = Provider.of<StaffProvider>(context);
    
    final staffMap = { for (var s in staffProvider.staff) s.id: s.name };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tất cả Phiếu Bảo dưỡng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: provider.loadAllTickets,
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadAllTickets,
              child: provider.allTickets.isEmpty
                  ? const Center(child: Text('Chưa có phiếu bảo dưỡng nào'))
                  : ListView.builder(
                      itemCount: provider.allTickets.length,
                      padding: const EdgeInsets.all(8),
                      itemBuilder: (context, index) {
                        final t = provider.allTickets[index];
                        final date = t.createdAt;
                        final assignedStaffName = staffMap[t.assignedStaffId] ?? 'Chưa phân công';

                        return Card(
                          elevation: 1,
                          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                              foregroundColor: Theme.of(context).primaryColor,
                              child: const Icon(Icons.build),
                            ),
                            title: Text('Phiếu #${t.id} - ${date.day}/${date.month}/${date.year}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tổng chi phí: ${t.totalCost.toStringAsFixed(0)} đ'),
                                Text('Xe: ${t.vehicleId}'),
                                Text(
                                  'Phân công: $assignedStaffName',
                                  style: TextStyle(
                                    color: t.assignedStaffId != null ? Colors.indigo : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            trailing: _getStatusChip(t.status),
                            onTap: () {
                              // ĐIỀU HƯỚNG ĐẾN MÀN HÌNH CHI TIẾT
                              context.go('/repairs/${t.id}'); 
                            },
                            onLongPress: () => _showAssignStaffDialog(context, t), // Long press để phân công
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
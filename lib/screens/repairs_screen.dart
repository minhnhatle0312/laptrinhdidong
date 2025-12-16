
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/repair_tickets_provider.dart';
import '../providers/staff_provider.dart';
import '../models/RepairTicket.dart';

class RepairsScreen extends StatefulWidget {
  const RepairsScreen({super.key});

  @override
  State<RepairsScreen> createState() => _RepairsScreenState();
}

class _RepairsScreenState extends State<RepairsScreen> {
  String _getStatusText(String status) {
    switch (status) {
      case 'received':
        return 'Đã nhận';
      case 'waiting':
        return 'Chờ xử lý';
      case 'repairing':
        return 'Đang sửa';
      case 'completed':
        return 'Hoàn thành';
      case 'delivered':
        return 'Giao xe';
      case 'held':
        return 'Tạm giữ';
      default:
        return status;
    }
  }

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

  void _showAssignStaffDialog(BuildContext context, RepairTicket ticket) {
    final staffProvider = context.read<StaffProvider>();
    final ticketProvider = context.read<RepairTicketsProvider>();
    final assignableStaff = staffProvider.staff
        .where((s) => s.isActive && ['mechanic', 'manager'].contains(s.position))
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
                )),
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
                    status: (selectedStaffId != null && (ticket.status == 'waiting' || ticket.status == 'received')) ? 'repairing' : ticket.status,
                  );
                  final success = await ticketProvider.updateTicket(updatedTicket);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã phân công thành công cho Phiếu #${ticket.id}')),
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
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 600;
                        return GridView.builder(
                          itemCount: provider.allTickets.length,
                          padding: const EdgeInsets.all(12),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 2 : 1,
                            childAspectRatio: isWide ? 2.8 : 1.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) {
                            final t = provider.allTickets[index];
                            final date = t.createdAt;
                            final assignedStaffName = staffMap[t.assignedStaffId] ?? 'Chưa phân công';
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  context.go('/repairs/${t.id}');
                                },
                                onLongPress: () => _showAssignStaffDialog(context, t),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.07),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.08),
                                        child: const Icon(Icons.build, size: 32),
                                      ),
                                      const SizedBox(width: 18),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Phiếu #${t.id} - ${date.day}/${date.month}/${date.year}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 4),
                                            Text('Tổng chi phí: ${t.totalCost.toStringAsFixed(0)} đ', style: Theme.of(context).textTheme.bodyMedium),
                                            Text('Xe: ${t.vehicleId}', style: Theme.of(context).textTheme.bodyMedium),
                                            Text('Phân công: $assignedStaffName',
                                              style: TextStyle(
                                                color: t.assignedStaffId != null ? Colors.indigo : Colors.orange,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _getStatusChip(t.status),
                                          const SizedBox(height: 8),
                                          IconButton(
                                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                            tooltip: 'Xóa',
                                            onPressed: () async {
                                              final confirm = await showDialog<bool>(
                                                context: context,
                                                builder: (ctx) => AlertDialog(
                                                  title: const Text('Xác nhận Xóa'),
                                                  content: Text('Bạn có chắc chắn muốn xóa phiếu "#${t.id}" không?'),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Hủy')),
                                                    ElevatedButton(
                                                      onPressed: () => Navigator.of(ctx).pop(true),
                                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                                      child: const Text('Xóa', style: TextStyle(color: Colors.white)),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirm == true) {
                                                final index = provider.allTickets.indexWhere((ticket) => ticket.id == t.id);
                                                if (index != -1) {
                                                  provider.allTickets.removeAt(index);
                                                }
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(content: Text('Đã xóa phiếu: #${t.id}')),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
    );
  }
}
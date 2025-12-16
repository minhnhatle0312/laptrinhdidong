// screens/repair_ticket_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/RepairTicket.dart';

import '../../models/PartUsage.dart';
import '../../models/Staff.dart';
import '../../providers/repair_tickets_provider.dart';
import '../../providers/staff_provider.dart';
import '../../providers/parts_provider.dart';

class RepairTicketDetailScreen extends StatelessWidget {
  final String ticketId;

  const RepairTicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context) {
    final ticketProvider = context.watch<RepairTicketsProvider>();
    final staffProvider = context.watch<StaffProvider>();
    final partsProvider = context.watch<PartsProvider>();
    
    final ticket = ticketProvider.allTickets.firstWhere(
      (t) => t.id == ticketId,
      orElse: () => throw Exception('Phiếu bảo dưỡng không tồn tại'),
    );

    final assignedStaff = staffProvider.staff.firstWhere(
      (s) => s.id == ticket.assignedStaffId,
      orElse: () => Staff(id: '', name: 'Chưa phân công', position: '', email: '', phone: '', specialization: '', isActive: false, joinedAt: DateTime.now()),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết Phiếu #${ticket.id}'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            tooltip: 'Hoàn thành Phiếu',
            onPressed: () => _confirmCompleteTicket(context, ticket),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. Thông tin Tổng quan ---
            _buildSectionHeader(context, 'Tổng quan Phiếu'),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoRow('Xe', ticket.vehicleId, Icons.directions_car),
                    _buildInfoRow('Khách hàng', ticket.customerId, Icons.person),
                    _buildInfoRow('Ngày tạo', '${ticket.createdAt.day}/${ticket.createdAt.month}/${ticket.createdAt.year}', Icons.calendar_today),
                    const Divider(),
                    _buildStatusChip(ticket.status),
                    const SizedBox(height: 8),
                    _buildAssignmentRow(context, ticket, assignedStaff, ticketProvider, staffProvider),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 2. Tổng chi phí ---
            _buildSectionHeader(context, 'Chi phí & Dịch vụ'),
            Card(
              elevation: 2,
              child: ListTile(
                title: const Text('TỔNG CHI PHÍ DỰ KIẾN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                trailing: Text(
                  '${ticket.totalCost.toStringAsFixed(0)} đ',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- 3. Dịch vụ Yêu cầu ---
            _buildSectionHeader(context, 'Dịch vụ Yêu cầu'),
            ...ticket.serviceIds.map((id) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('- $id'), // TODO: Cần tra cứu tên dịch vụ từ ServicesProvider
            )),
            const SizedBox(height: 20),

            // --- 4. Quản lý Phụ tùng ---
            _buildSectionHeader(context, 'Phụ tùng đã sử dụng (${ticket.partsUsed.length})'),
            _buildPartsList(context, ticket, ticketProvider, partsProvider),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
  
  // Widget Header cho từng phần
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }

  // Widget hiển thị thông tin cơ bản
  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // Widget hiển thị Assignment và nút thay đổi
  Widget _buildAssignmentRow(BuildContext context, RepairTicket ticket, Staff assignedStaff, RepairTicketsProvider ticketProvider, StaffProvider staffProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.badge, size: 18, color: Colors.indigo),
            const SizedBox(width: 8),
            Text('Phân công: ${assignedStaff.name}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
          ],
        ),
        TextButton(
          onPressed: () => _showAssignStaffDialog(context, ticket, ticketProvider, staffProvider),
          child: const Text('Thay đổi'),
        ),
      ],
    );
  }

  // Widget hiển thị trạng thái
  Widget _buildStatusChip(String status) {
    Color color;
    String text;
    switch (status) {
      case 'received': color = Colors.grey; text = 'Đã nhận'; break;
      case 'waiting': color = Colors.orange; text = 'Chờ xử lý'; break;
      case 'repairing': color = Colors.blue; text = 'Đang sửa'; break;
      case 'completed': color = Colors.green; text = 'Hoàn thành'; break;
      case 'delivered': color = Colors.green.shade800; text = 'Đã giao xe'; break;
      default: color = Colors.grey; text = status;
    }
    return Chip(
      label: Text('Trạng thái: $text', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: color,
    );
  }

  // Dialog Phân công Nhân viên
  void _showAssignStaffDialog(BuildContext context, RepairTicket ticket, RepairTicketsProvider ticketProvider, StaffProvider staffProvider) {
    final assignableStaff = staffProvider.staff
        .where((s) => ['mechanic', 'manager'].contains(s.position))
        .toList();

    String? selectedStaffId = ticket.assignedStaffId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setState) {
          return AlertDialog(
            title: Text('Phân công Phiếu #${ticket.id}'),
            content: DropdownButtonFormField<String>(
              initialValue: selectedStaffId,
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
                    status: (selectedStaffId != null && ticket.status == 'waiting') ? 'repairing' : ticket.status,
                  );

                  await ticketProvider.updateTicket(updatedTicket);
                },
                child: const Text('Lưu'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Dialog Thêm Phụ tùng
  void _showAddPartUsageDialog(BuildContext context, RepairTicket ticket, RepairTicketsProvider ticketProvider, PartsProvider partsProvider) {
    final availableParts = partsProvider.parts.where((p) => p.stockQuantity > 0).toList();
    String? selectedPartId;
    int quantity = 1;
    
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (sCtx, setState) {
            final selectedPart = selectedPartId == null
              ? null
              : (availableParts.where((p) => p.id == selectedPartId).isNotEmpty
                ? availableParts.firstWhere((p) => p.id == selectedPartId)
                : null);
          
          return AlertDialog(
            title: const Text('Thêm Phụ tùng'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Phụ tùng'),
                  initialValue: selectedPartId,
                  items: availableParts.map((p) => DropdownMenuItem(
                    value: p.id,
                    child: Text('${p.name} (${p.sellingPrice.toStringAsFixed(0)}đ) - Tồn: ${p.stockQuantity}'),
                  )).toList(),
                  onChanged: (v) => setState(() => selectedPartId = v),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text('Số lượng:'),
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => setState(() => quantity = (quantity > 1 ? quantity - 1 : 1)),
                    ),
                    Text('$quantity'),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => setState(() => quantity = (selectedPart?.stockQuantity ?? 0) > quantity ? quantity + 1 : quantity),
                    ),
                  ],
                ),
                if (selectedPart != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text('Tổng tiền: ${(selectedPart.sellingPrice * quantity).toStringAsFixed(0)} đ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
              ElevatedButton(
                onPressed: selectedPartId == null || quantity == 0 || selectedPart == null
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        final newUsage = PartUsage(
                          partId: selectedPart.id,
                          partName: selectedPart.name,
                          unitPrice: selectedPart.sellingPrice,
                          quantityUsed: quantity,
                        );
                        final updatedParts = List<PartUsage>.from(ticket.partsUsed)..add(newUsage);
                        await ticketProvider.updateTicket(ticket.copyWith(partsUsed: updatedParts));
                      },
                child: const Text('Thêm'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget hiển thị danh sách Phụ tùng đã dùng
  Widget _buildPartsList(BuildContext context, RepairTicket ticket, RepairTicketsProvider ticketProvider, PartsProvider partsProvider) {
    return Column(
      children: [
        if (ticket.partsUsed.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('Chưa có phụ tùng nào được thêm.'),
          ),
        ...ticket.partsUsed.map((usage) => Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(usage.partName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('SL: ${usage.quantityUsed} x ${usage.unitPrice.toStringAsFixed(0)} đ'),
            trailing: Text(
              '${usage.totalCost.toStringAsFixed(0)} đ',
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
            ),
            onLongPress: () {
              // TODO: Cho phép xóa mục phụ tùng đã thêm
            },
          ),
        )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAddPartUsageDialog(context, ticket, ticketProvider, partsProvider),
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Thêm Phụ tùng'),
          ),
        ),
      ],
    );
  }

  // Xác nhận hoàn thành phiếu
  void _confirmCompleteTicket(BuildContext context, RepairTicket ticket) {
    final ticketProvider = context.read<RepairTicketsProvider>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận Hoàn thành'),
        content: Text('Phiếu #${ticket.id} sẽ được đánh dấu là HOÀN THÀNH. Tổng chi phí là ${ticket.totalCost.toStringAsFixed(0)} đ. Tiếp tục?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final updatedTicket = ticket.copyWith(
                status: 'completed',
                completedTime: DateTime.now(),
              );
              await ticketProvider.updateTicket(updatedTicket);
              context.pop(); // Quay lại danh sách phiếu
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // THÊM IMPORT
import '../models/parking_spot.dart';
import '../providers/parking_provider.dart';
import '../providers/vehicles_provider.dart';
import '../providers/transactions_provider.dart';
import '../models/transaction_record.dart';

class ReservationScreen extends StatefulWidget {
  final ParkingSpot spot;

  const ReservationScreen({super.key, required this.spot});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String? _selectedVehicleId;
  int _hours = 1;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    final vehicles = Provider.of<VehiclesProvider>(
      context,
      listen: false,
    ).vehicles;
    if (vehicles.isNotEmpty) _selectedVehicleId = vehicles.first.id;
  }

  Future<void> _confirm() async {
    if (_selectedVehicleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn xe')),
      );
      return;
    }
    setState(() => _processing = true);

    final parkingProvider = Provider.of<ParkingProvider>(
      context,
      listen: false,
    );
    final transactions = Provider.of<TransactionsProvider>(
      context,
      listen: false,
    );

    final amount = widget.spot.pricePerHour * _hours;

    // SỬA: Dùng GoRouter context.push để chuyển sang màn hình Payment
    final paymentResult = await context.push<Map<String, dynamic>>(
      '/payment',
      extra: {'amount': amount}, // Truyền số tiền qua 'extra'
    );

    if (!mounted) return;

    if (paymentResult?['success'] == true) {
      // Logic đặt chỗ thực tế
      final ok = await parkingProvider.reserve(
        widget.spot.id,
        _selectedVehicleId!,
      );

      if (!mounted) return;

      if (ok) {
        // Tạo bản ghi giao dịch
        final newTx = TransactionRecord(
          id: paymentResult!['transactionId'] as String,
          amount: amount,
          date: DateTime.now(),
          method: 'online', 
          status: 'Hoàn tất',
        );
        transactions.addTransaction(newTx);
        
        // SỬA: Dùng GoRouter context.pop để quay lại và trả về kết quả (true)
        context.pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lỗi: Đặt chỗ không thành công')),
        );
        setState(() => _processing = false);
      }
    } else {
      // Thanh toán không thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thanh toán đã bị hủy hoặc thất bại')),
      );
      setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = Provider.of<VehiclesProvider>(context).vehicles;
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt chỗ')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bãi đỗ: ${widget.spot.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text('Giá: ${widget.spot.pricePerHour} VND / giờ'),
            const SizedBox(height: 16),
            const Text('Chọn xe:'),
            DropdownButtonFormField<String>(
              initialValue: _selectedVehicleId,
              items: vehicles
                  .map(
                    (v) => DropdownMenuItem<String>(
                      value: v.id,
                      child: Text('${v.plate} — ${v.model}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedVehicleId = v),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Số giờ:'),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () =>
                      setState(() => _hours = (_hours > 1 ? _hours - 1 : 1)),
                  icon: const Icon(Icons.remove),
                ),
                Text('$_hours'),
                IconButton(
                  onPressed: () => setState(() => _hours++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Tổng: ${widget.spot.pricePerHour * _hours} VND',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processing ? null : _confirm,
                child: _processing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Thanh toán & Đặt'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
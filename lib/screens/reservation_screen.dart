import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
    if (_selectedVehicleId == null) return;
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
    try {
      // create payment (mock or real based on ApiService)
      final paymentOk = await parkingProvider.api.createPayment(amount, 'cash');
      final txId = DateTime.now().millisecondsSinceEpoch.toString();
      
      if (!paymentOk) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thanh toán thất bại!')),
        );
        return;
      }

      // reserve spot
      final ok = await parkingProvider.reserve(
        widget.spot.id,
        _selectedVehicleId!,
      );

      if (ok) {
        transactions.addTransaction(
          TransactionRecord(
            id: txId.toString(),
            amount: amount,
            date: DateTime.now(),
            method: 'cash',
            status: 'completed',
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đặt chỗ và thanh toán thành công')),
          );
          Navigator.of(context).pop(true);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Đặt chỗ thất bại')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final vehicles = Provider.of<VehiclesProvider>(context).vehicles;

    return Scaffold(
      appBar: AppBar(title: const Text('Đặt chỗ')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.spot.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Giá: ${widget.spot.pricePerHour}/giờ'),
            const SizedBox(height: 12),
            const Text('Chọn xe của bạn'),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedVehicleId,
              items: vehicles
                  .map(
                    (v) => DropdownMenuItem(
                      value: v.id,
                      child: Text('${v.plate} — ${v.model}'),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedVehicleId = v),
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

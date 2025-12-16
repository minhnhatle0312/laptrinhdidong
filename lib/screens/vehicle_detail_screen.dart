import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehicleDetailScreen extends StatelessWidget {
  final Vehicle vehicle;
  final String? imageUrl;

  const VehicleDetailScreen({Key? key, required this.vehicle, this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết xe: ${vehicle.plate}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 48,
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
                child: imageUrl == null ? const Icon(Icons.directions_car, size: 48) : null,
              ),
            ),
            const SizedBox(height: 24),
            Text('Biển số: ${vehicle.plate}', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Text('Model: ${vehicle.model}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text('Chủ sở hữu: ${vehicle.ownerName}', style: Theme.of(context).textTheme.bodyLarge),
            // Thêm các thông tin khác nếu cần
          ],
        ),
      ),
    );
  }
}

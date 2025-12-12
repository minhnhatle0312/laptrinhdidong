import 'package:flutter/material.dart';
import '../models/parking_spot.dart';

class ParkingCard extends StatelessWidget {
  final ParkingSpot spot;
  final VoidCallback? onReserve;

  const ParkingCard({super.key, required this.spot, this.onReserve});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.local_parking,
              size: 40,
              color: spot.isAvailable ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    spot.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('Giá: ${spot.pricePerHour}/giờ'),
                  const SizedBox(height: 6),
                  Text(
                    spot.isAvailable ? 'Trống' : 'Đã đặt',
                    style: TextStyle(
                      color: spot.isAvailable ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: spot.isAvailable ? onReserve : null,
              child: const Text('Đặt'),
            ),
          ],
        ),
      ),
    );
  }
}

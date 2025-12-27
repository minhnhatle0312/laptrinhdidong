// File: lib/screens/map/garage_map_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Thư viện OSM
import 'package:latlong2/latlong.dart'; // Xử lý tọa độ

class GarageMapScreen extends StatefulWidget {
  const GarageMapScreen({super.key});

  @override
  State<GarageMapScreen> createState() => _GarageMapScreenState();
}

class _GarageMapScreenState extends State<GarageMapScreen> {
  // Controller để điều khiển map (phóng to, di chuyển)
  final MapController _mapController = MapController();

  // Dữ liệu giả lập các kho/xưởng
  final List<Map<String, dynamic>> _garages = [
    {
      "name": "Kho Tổng (Hà Nội)",
      "point": const LatLng(21.028511, 105.854444),
      "address": "Hoàn Kiếm, Hà Nội"
    },
    {
      "name": "Chi nhánh Sài Gòn",
      "point": const LatLng(10.762622, 106.660172),
      "address": "Quận 1, TP.HCM"
    },
    {
      "name": "Kho Đà Nẵng",
      "point": const LatLng(16.054407, 108.202167),
      "address": "Hải Châu, Đà Nẵng"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ kho (OpenStreetMap)')),
      body: FlutterMap(
        mapController: _mapController,
        options: const MapOptions(
          initialCenter: LatLng(21.028511, 105.854444), // Mặc định ở HN
          initialZoom: 10.0,
        ),
        children: [
          // Lớp 1: Hiển thị nền bản đồ từ OpenStreetMap
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app', // Tên package của app bạn
          ),
          
          // Lớp 2: Các điểm đánh dấu (Markers)
          MarkerLayer(
            markers: _garages.map((g) {
              return Marker(
                point: g['point'],
                width: 80,
                height: 80,
                child: GestureDetector(
                  onTap: () => _showGarageInfo(context, g), // Bấm vào hiện info
                  child: const Icon(
                    Icons.location_on, 
                    color: Colors.red, 
                    size: 40,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      
      // Nút điều khiển nhanh
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            heroTag: 'btn_hn',
            onPressed: () => _moveTo(const LatLng(21.028511, 105.854444)),
            child: const Text("HN"),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: 'btn_sg',
            onPressed: () => _moveTo(const LatLng(10.762622, 106.660172)),
            child: const Text("SG"),
          ),
        ],
      ),
    );
  }

  // Hàm di chuyển camera
  void _moveTo(LatLng dest) {
    _mapController.move(dest, 14.0); // Zoom level 14
  }

  // Hàm hiện thông tin khi bấm vào marker
  void _showGarageInfo(BuildContext context, Map<String, dynamic> garage) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        height: 200,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garage['name'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.map, color: Colors.blue),
                const SizedBox(width: 8),
                Text(garage['address']),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.directions),
                label: const Text('Chỉ đường (Coming soon)'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
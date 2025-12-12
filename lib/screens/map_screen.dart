import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/parking_provider.dart';
import 'reservation_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).loadSpots();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);
    final spots = provider.spots;

    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ bãi xe')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(center: LatLng(10.776530, 106.700981), zoom: 13),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: spots.map((s) {
              return Marker(
                width: 80,
                height: 80,
                point: LatLng(s.lat, s.lng),
                builder: (ctx) => GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Trạng thái: ${s.isAvailable ? 'Trống' : 'Đã đặt'}',
                            ),
                            const SizedBox(height: 8),
                            Text('Giá: ${s.pricePerHour}/giờ'),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ReservationScreen(spot: s),
                                  ),
                                );
                              },
                              child: const Text('Đặt chỗ'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Icon(
                    Icons.location_on,
                    color: s.isAvailable ? Colors.green : Colors.red,
                    size: 36,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

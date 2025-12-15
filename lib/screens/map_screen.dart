import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/parking_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).loadSpots();
    });
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  void _onMarkerTapped(dynamic spot) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${spot.name} - ${spot.isAvailable ? 'Trống' : 'Đã đặt'}'),
        action: SnackBarAction(
          label: 'Đặt chỗ',
          onPressed: () => context.go('/reserve', extra: spot),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ParkingProvider>(context);
    final spots = provider.spots;

    return Scaffold(
      appBar: AppBar(title: const Text('Bản đồ bãi xe')),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          center: LatLng(10.776530, 106.700981),
          zoom: 13.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          if (spots.isNotEmpty)
            MarkerLayer(
              markers: _buildMarkers(spots),
            ),
        ],
      ),
    );
  }

  List<Marker> _buildMarkers(List<dynamic> spots) {
    return spots.map<Marker>((spot) {
      return Marker(
        point: LatLng(spot.lat as double, spot.lng as double),
        width: 40,
        height: 40,
        builder: (ctx) => GestureDetector(
          onTap: () => _onMarkerTapped(spot),
          child: Icon(
            Icons.location_on,
            color: spot.isAvailable == true ? Colors.green : Colors.red,
            size: 36,
          ),
        ),
      );
    }).toList();
  }
}
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmaps;
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/parking_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  gmaps.GoogleMapController? _gMapController;

  @override
  void initState() {
    super.initState();
    // No flutter_map controller when using Google Maps only
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ParkingProvider>(context, listen: false).loadSpots();
    });
  }

  @override
  void dispose() {
    _gMapController?.dispose();
    _gMapController?.dispose();
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
      body: gmaps.GoogleMap(
        initialCameraPosition: const gmaps.CameraPosition(
          target: gmaps.LatLng(10.77653, 106.700981),
          zoom: 13.0,
        ),
        onMapCreated: (ctrl) => _gMapController = ctrl,
        markers: _buildGMarkers(spots),
      ),
    );
  }

  Set<gmaps.Marker> _buildGMarkers(List<dynamic> spots) {
    return spots.map<gmaps.Marker>((spot) {
      final id = gmaps.MarkerId(spot.id?.toString() ?? '${spot.lat}-${spot.lng}');
      return gmaps.Marker(
        markerId: id,
        position: gmaps.LatLng(spot.lat as double, spot.lng as double),
        infoWindow: gmaps.InfoWindow(
          title: spot.name?.toString() ?? '',
          snippet: spot.isAvailable == true ? 'Trống' : 'Đã đặt',
        ),
        onTap: () => _onMarkerTapped(spot),
      );
    }).toSet();
  }
}
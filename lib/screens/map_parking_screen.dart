import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MapParkingScreen extends StatefulWidget {
  const MapParkingScreen({Key? key}) : super(key: key);

  @override
  State<MapParkingScreen> createState() => _MapParkingScreenState();
}

class _MapParkingScreenState extends State<MapParkingScreen> {
  late GoogleMapController _mapController;
  final LatLng _center = const LatLng(10.7769, 106.7009); // Trung tâm TP.HCM
  final List<Map<String, dynamic>> _parkings = [
    {
      'id': '1',
      'name': 'Bãi giữ xe A',
      'position': const LatLng(10.7775, 106.6983),
      'capacity': 50,
      'available': 12,
    },
    {
      'id': '2',
      'name': 'Bãi giữ xe B',
      'position': const LatLng(10.7752, 106.7031),
      'capacity': 80,
      'available': 30,
    },
    {
      'id': '3',
      'name': 'Bãi giữ xe C',
      'position': const LatLng(10.7791, 106.6995),
      'capacity': 100,
      'available': 5,
    },
  ];
  String? _selectedParkingId;

  Set<Marker> get _markers => _parkings.map((p) {
    return Marker(
      markerId: MarkerId(p['id']),
      position: p['position'],
      infoWindow: InfoWindow(title: p['name']),
      onTap: () {
        setState(() => _selectedParkingId = p['id']);
      },
      icon: BitmapDescriptor.defaultMarkerWithHue(
        _selectedParkingId == p['id'] ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
      ),
    );
  }).toSet();

  @override
  Widget build(BuildContext context) {
    final selected = _parkings.firstWhere(
      (p) => p['id'] == _selectedParkingId,
      orElse: () => {},
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bản đồ bãi giữ xe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
            onPressed: () => setState(() => _selectedParkingId = null),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: _center, zoom: 15),
            markers: _markers,
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          if (selected != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.local_parking, color: Colors.blue[700], size: 32),
                            const SizedBox(width: 12),
                            Text(selected['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => setState(() => _selectedParkingId = null),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.people, size: 20, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text('Sức chứa: ${selected['capacity']}'),
                            const SizedBox(width: 16),
                            const Icon(Icons.event_available, size: 20, color: Colors.green),
                            const SizedBox(width: 4),
                            Text('Còn trống: ${selected['available']}'),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.directions),
                              label: const Text('Chỉ đường'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {}, // TODO: mở Google Maps chỉ đường
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              icon: const Icon(Icons.info_outline),
                              label: const Text('Chi tiết'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOut),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

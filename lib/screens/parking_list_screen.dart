import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart'; // THÊM IMPORT
import '../providers/parking_provider.dart';
import '../widgets/parking_card.dart';
// import 'reservation_screen.dart'; // Không cần nữa

class ParkingListScreen extends StatefulWidget {
  const ParkingListScreen({super.key});

  @override
  State<ParkingListScreen> createState() => _ParkingListScreenState();
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  String _query = '';

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
    final spots = _query.isEmpty
        ? provider.spots
        : provider.spots
              .where(
                (s) => ('${s.name} ${s.id}').toLowerCase().contains(
                  _query.toLowerCase(),
                ),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Danh sách bãi xe')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: provider.loadSpots,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: TextField(
                      decoration: const InputDecoration(
                        labelText: 'Tìm kiếm bãi xe...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: spots.length,
                      itemBuilder: (context, index) {
                        final spot = spots[index];
                        return ParkingCard(
                          spot: spot,
                          onReserve: () async {
                            final messenger = ScaffoldMessenger.of(context);
                            
                            // SỬA: Dùng GoRouter context.push để điều hướng và chờ kết quả
                            final res = await context.push<bool>(
                              '/reserve',
                              extra: spot, // Truyền ParkingSpot qua extra
                            );
                            
                            if (!mounted) return;
                            if (res == true) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Đặt chỗ hoàn tất'),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
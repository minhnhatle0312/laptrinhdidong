import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Initialize sample data in Firestore for development/testing
class FirebaseInitSampleData {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sample parking spots
  static final List<Map<String, dynamic>> sampleParkingSpots = [
    {
      'id': 'spot_001',
      'name': 'Spot A1',
      'lat': 10.776530,
      'lng': 106.700981,
      'isAvailable': true,
      'pricePerHour': 50000,
      'floor': 'A',
      'type': 'standard',
      'createdAt': DateTime.now(),
    },
    {
      'id': 'spot_002',
      'name': 'Spot A2',
      'lat': 10.776545,
      'lng': 106.700995,
      'isAvailable': true,
      'pricePerHour': 50000,
      'floor': 'A',
      'type': 'standard',
      'createdAt': DateTime.now(),
    },
    {
      'id': 'spot_003',
      'name': 'Spot A3',
      'lat': 10.776560,
      'lng': 106.701010,
      'isAvailable': false,
      'pricePerHour': 50000,
      'floor': 'A',
      'type': 'standard',
      'createdAt': DateTime.now(),
    },
    {
      'id': 'spot_004',
      'name': 'Spot B1',
      'lat': 10.776700,
      'lng': 106.701100,
      'isAvailable': true,
      'pricePerHour': 60000,
      'floor': 'B',
      'type': 'vip',
      'createdAt': DateTime.now(),
    },
    {
      'id': 'spot_005',
      'name': 'Spot B2',
      'lat': 10.776720,
      'lng': 106.701120,
      'isAvailable': true,
      'pricePerHour': 60000,
      'floor': 'B',
      'type': 'vip',
      'createdAt': DateTime.now(),
    },
  ];

  /// Initialize all sample data
  static Future<void> initializeAll() async {
    try {
      await _initializeParkingSpots();
      debugPrint('✓ Sample data initialized successfully');
    } catch (e) {
      debugPrint('✗ Error initializing sample data: $e');
      rethrow;
    }
  }

  /// Initialize parking spots
  static Future<void> _initializeParkingSpots() async {
    final collection = _firestore.collection('parking_spots');

    // Clear existing spots (optional - comment out to preserve)
    // final snapshot = await collection.get();
    // for (var doc in snapshot.docs) {
    //   await doc.reference.delete();
    // }

    // Add sample spots
    for (var spot in sampleParkingSpots) {
      final docRef = collection.doc(spot['id']);
      final exists = (await docRef.get()).exists;

      if (!exists) {
        await docRef.set(spot);
        debugPrint('✓ Created parking spot: ${spot['name']}');
      } else {
        debugPrint('⊝ Parking spot already exists: ${spot['name']}');
      }
    }
  }

  /// Clear all sample data (use with caution)
  static Future<void> clearAllData() async {
    try {
      // Clear parking spots
      final spots = await _firestore.collection('parking_spots').get();
      for (var doc in spots.docs) {
        await doc.reference.delete();
      }
      debugPrint('✓ All sample data cleared');
    } catch (e) {
      debugPrint('✗ Error clearing sample data: $e');
      rethrow;
    }
  }

  /// Get parking spots count
  static Future<int> getParkingSpotsCount() async {
    final snapshot = await _firestore.collection('parking_spots').get();
    return snapshot.docs.length;
  }
}

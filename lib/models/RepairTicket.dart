// models/RepairTicket.dart (Sửa đổi)

// ignore_for_file: file_names
import 'PartUsage.dart';

class RepairTicket {
  final String id;
  final String vehicleId;
  final String customerId;
  final DateTime createdAt;
  final List<String> serviceIds; // Service IDs
  final List<String>? notes;
  final String status; // received, waiting, repairing, completed, held, delivered
  final DateTime? startTime;
  final DateTime? completedTime;
  final double totalCost;
  final String? assignedStaffId; // THÊM MỚI: ID nhân viên được phân công
  final List<PartUsage> partsUsed; // THÊM MỚI

  RepairTicket({
    required this.id,
    required this.vehicleId,
    required this.customerId,
    required this.createdAt,
    required this.serviceIds,
    this.notes,
    this.status = 'received',
    this.startTime,
    this.completedTime,
    this.totalCost = 0.0,
    this.assignedStaffId, 
    this.partsUsed = const [],
  });

  factory RepairTicket.fromJson(Map<String, dynamic> json) {
    return RepairTicket(
      id: json['id'] as String,
      vehicleId: json['vehicleId'] as String,
      customerId: json['customerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      serviceIds: List<String>.from(json['serviceIds'] as List),
      notes: json['notes'] != null ? List<String>.from(json['notes'] as List) : null,
      status: json['status'] as String? ?? 'received',
      startTime: json['startTime'] != null ? DateTime.parse(json['startTime'] as String) : null,
      completedTime: json['completedTime'] != null ? DateTime.parse(json['completedTime'] as String) : null,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0.0,
      assignedStaffId: json['assignedStaffId'] as String?,
      partsUsed: (json['partsUsed'] as List<dynamic>?)
          ?.map((e) => PartUsage.fromJson(e as Map<String, dynamic>))
          .toList() ?? const [], // PHÂN TÍCH PARTS USED
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'customerId': customerId,
      'createdAt': createdAt.toIso8601String(),
      'serviceIds': serviceIds,
      'notes': notes,
      'status': status,
      'startTime': startTime?.toIso8601String(),
      'completedTime': completedTime?.toIso8601String(),
      'totalCost': totalCost,
      'assignedStaffId': assignedStaffId,
      'partsUsed': partsUsed.map((e) => e.toJson()).toList(), // CHUYỂN PARTS USED SANG JSON
    };
  }

  // THÊM: Phương thức copyWith để tạo bản sao khi cập nhật
  RepairTicket copyWith({
    String? id,
    String? vehicleId,
    String? customerId,
    DateTime? createdAt,
    List<String>? serviceIds,
    List<String>? notes,
    String? status,
    DateTime? startTime,
    DateTime? completedTime,
    double? totalCost,
    String? assignedStaffId,
    List<PartUsage>? partsUsed, // THÊM TRƯỜNG COPY
  }) {
    return RepairTicket(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      customerId: customerId ?? this.customerId,
      createdAt: createdAt ?? this.createdAt,
      serviceIds: serviceIds ?? this.serviceIds,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      completedTime: completedTime ?? this.completedTime,
      totalCost: totalCost ?? this.totalCost,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      partsUsed: partsUsed ?? this.partsUsed,
    );
  }
}
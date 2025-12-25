// File: lib/screens/staff/staff_form_controller.dart
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/staff.dart';
import '../../models/position.dart';
import '../../services/staff_firestore.dart';
import '../../services/position_firestore.dart';

class StaffFormController extends ChangeNotifier {
  // UI Controllers
  final nameController = TextEditingController();
  final salaryController = TextEditingController();

  // Services
  final _staffFirestore = StaffFirestore();
  final _positionFirestore = PositionFirestore();
  final _uuid = const Uuid();

  // State
  List<Position> positions = [];
  Position? selectedPosition;
  bool isLoading = true;
  Staff? currentStaff; // Để biết đang edit hay add new

  // Khởi tạo
  StaffFormController(Staff? staff) {
    currentStaff = staff;
    if (staff != null) {
      nameController.text = staff.name;
      salaryController.text = staff.salary.toStringAsFixed(0);
    }
    _loadPositions();
  }

  @override
  void dispose() {
    nameController.dispose();
    salaryController.dispose();
    super.dispose();
  }

  // Load danh sách vị trí
  Future<void> _loadPositions() async {
    try {
      final result = await _positionFirestore.getAllPositions();
      positions = result;
      
      if (currentStaff != null) {
        // Nếu đang edit, tìm lại position cũ
        selectedPosition = positions.firstWhere(
          (p) => p.id == currentStaff!.positionId,
          orElse: () => positions.first,
        );
      }
      
      isLoading = false;
      notifyListeners(); // Báo cho UI cập nhật
    } catch (e) {
      isLoading = false;
      notifyListeners();
      debugPrint('Lỗi load positions: $e');
    }
  }

  // Xử lý khi chọn vị trí
  void onPositionChanged(Position? newPosition) {
    selectedPosition = newPosition;
    // Auto-fill lương nếu có
    if (newPosition?.baseSalary != null) {
      salaryController.text = newPosition!.baseSalary!.toStringAsFixed(0);
    }
    notifyListeners();
  }

  // Logic Lưu
  Future<bool> save({required BuildContext context, bool continueAdding = false}) async {
    // 1. Validate
    if (nameController.text.trim().isEmpty) {
      _showSnack(context, 'Vui lòng nhập tên nhân viên', isError: true);
      return false;
    }

    if (selectedPosition == null) {
      _showSnack(context, 'Vui lòng chọn vị trí công việc', isError: true);
      return false;
    }

    final salary = double.tryParse(salaryController.text.replaceAll(',', ''));
    if (salary == null || salary <= 0) {
      _showSnack(context, 'Lương không hợp lệ', isError: true);
      return false;
    }

    // 2. Tạo Object
    final id = (currentStaff != null && !continueAdding) ? currentStaff!.id : _uuid.v4();
    final staff = Staff(
      id: id,
      name: nameController.text.trim(),
      positionId: selectedPosition!.id,
      positionName: selectedPosition!.name,
      salary: salary,
    );

    // 3. Gọi Firestore
    try {
      if (currentStaff == null || continueAdding) {
        await _staffFirestore.addEmployee(staff);
        _showSnack(context, 'Đã thêm nhân viên thành công', isError: false);
      } else {
        await _staffFirestore.updateEmployee(staff);
        _showSnack(context, 'Đã cập nhật thông tin', isError: false);
      }

      // 4. Xử lý sau khi lưu
      if (continueAdding) {
        nameController.clear();
        salaryController.clear();
        selectedPosition = null;
        notifyListeners();
        return false; // False nghĩa là không đóng màn hình
      }
      
      return true; // True nghĩa là đóng màn hình
    } catch (e) {
      _showSnack(context, 'Lỗi: $e', isError: true);
      return false;
    }
  }

  void _showSnack(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
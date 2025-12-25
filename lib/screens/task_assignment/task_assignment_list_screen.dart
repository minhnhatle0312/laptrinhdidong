// File: lib/screens/task_assignment/task_assignment_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/models/task_assignment.dart';
import 'package:flutter_application/services/task_assignment_firestore.dart';

class TaskAssignmentListScreen extends StatefulWidget {
  final String? receptionId;
  final String? staffId;

  const TaskAssignmentListScreen({super.key, this.receptionId, this.staffId});

  @override
  State<TaskAssignmentListScreen> createState() =>
      _TaskAssignmentListScreenState();
}

class _TaskAssignmentListScreenState extends State<TaskAssignmentListScreen> {
  final TaskAssignmentFirestore _firestore = TaskAssignmentFirestore();
  bool _isLoading = false;

  // Helper: Lấy màu theo trạng thái
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange.shade700;
      case 'in_progress':
        return Colors.blue.shade600;
      case 'done':
        return Colors.green.shade600;
      default:
        return Colors.grey;
    }
  }

  // Helper: Lấy icon theo trạng thái
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty_rounded;
      case 'in_progress':
        return Icons.handyman_outlined;
      case 'done':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<List<TaskAssignment>> stream;
    String title;

    if (widget.receptionId != null) {
      stream = _firestore.getTasksByReception(widget.receptionId!);
      title = 'Phân công công việc';
    } else if (widget.staffId != null) {
      stream = _firestore.getTasksByStaff(widget.staffId!);
      title = 'Công việc của tôi';
    } else {
      return _buildAllTasksScreen();
    }

    return Scaffold(
      backgroundColor: Colors.grey[50], // Nền sáng nhẹ
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
        ],
      ),
      body: StreamBuilder<List<TaskAssignment>>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(widget.receptionId != null
                ? 'Chưa có phân công nào'
                : 'Bạn chưa có công việc nào');
          }

          final tasks = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return _buildTaskCard(task);
              },
            ),
          );
        },
      ),
    );
  }

  // Widget hiển thị lỗi
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            ),
            const SizedBox(height: 16),
            Text(
              'Đã xảy ra lỗi',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(elevation: 0),
            ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị trống
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_add,
              size: 64,
              color: Colors.blue.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Thẻ Task được thiết kế lại
  Widget _buildTaskCard(TaskAssignment task) {
    final statusColor = _getStatusColor(task.status);
    final statusIcon = _getStatusIcon(task.status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Thanh màu trạng thái bên trái
              Container(
                width: 6,
                color: statusColor,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Tên dịch vụ + Menu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  task.serviceName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon, size: 12, color: statusColor),
                                      const SizedBox(width: 4),
                                      Text(
                                        task.statusText,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildPopupMenu(task),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 0.5),
                      const SizedBox(height: 12),

                      // Thông tin nhân viên
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(Icons.person, size: 14, color: Colors.grey),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              task.staffName,
                              style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      // Thông tin thời gian
                      if (task.startTime != null || task.endTime != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey[200],
                              child: const Icon(Icons.access_time, size: 14, color: Colors.grey),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.duration,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu(TaskAssignment task) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey[400]),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (context) => [
        if (task.status != 'in_progress')
          const PopupMenuItem(
            value: 'in_progress',
            child: Row(
              children: [
                Icon(Icons.play_arrow_rounded, color: Colors.blue),
                SizedBox(width: 12),
                Text('Bắt đầu làm'),
              ],
            ),
          ),
        if (task.status != 'done')
          const PopupMenuItem(
            value: 'done',
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 12),
                Text('Hoàn thành'),
              ],
            ),
          ),
        if (task.status != 'pending')
          const PopupMenuItem(
            value: 'pending',
            child: Row(
              children: [
                Icon(Icons.refresh, color: Colors.orange),
                SizedBox(width: 12),
                Text('Đặt lại (Chờ)'),
              ],
            ),
          ),
      ],
      onSelected: (value) => _updateTaskStatus(task, value),
    );
  }

  Future<void> _updateTaskStatus(TaskAssignment task, String newStatus) async {
    setState(() => _isLoading = true);
    try {
      await _firestore.updateTaskStatus(task.id, newStatus);
      if (!mounted) return;

      Color msgColor = newStatus == 'done' ? Colors.green : (newStatus == 'in_progress' ? Colors.blue : Colors.orange);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text('Đã cập nhật: ${_getStatusText(newStatus)}'),
              ),
            ],
          ),
          backgroundColor: msgColor,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending': return 'Đang chờ';
      case 'in_progress': return 'Đang làm';
      case 'done': return 'Hoàn thành';
      default: return status;
    }
  }

  Widget _buildAllTasksScreen() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tất cả công việc', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () => setState(() {}),
          ),
        ],
      ),
      body: FutureBuilder<List<TaskAssignment>>(
        future: _firestore.getAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState('Chưa có công việc nào');
          }

          final tasks = snapshot.data!;
          final pendingCount = tasks.where((t) => t.status == 'pending').length;
          final inProgressCount = tasks.where((t) => t.status == 'in_progress').length;
          final doneCount = tasks.where((t) => t.status == 'done').length;

          return Column(
            children: [
              // Stats cards section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildStatCard('Chờ xử lý', pendingCount, Colors.orange, Icons.hourglass_top)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Đang làm', inProgressCount, Colors.blue, Icons.engineering)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard('Hoàn thành', doneCount, Colors.green, Icons.task_alt)),
                  ],
                ),
              ),
              
              // Task list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() {});
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTaskCard(tasks[index]);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
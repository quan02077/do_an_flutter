import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import '../../../core/services/supabase_service.dart';

class TaskService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Lắng nghe dữ liệu Real-time (WebSocket) từ bảng tasks
  Stream<List<TaskModel>> getTasksStream() {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((dataList) => dataList.map((json) => TaskModel.fromJson(json)).toList());
  }

  /// Thêm công việc mới vào Supabase
  Future<void> createTask(TaskModel task) async {
    try {
      await _supabase.from('tasks').insert(task.toJson());
    } catch (e) {
      debugPrint('Lỗi Backend khi thêm task: $e');
      rethrow;
    }
  }

  /// Cập nhật thông tin chi tiết của Task
  Future<void> updateTask(TaskModel task) async {
    try {
      await _supabase.from('tasks').update(task.toJson()).eq('id', task.id);
    } catch (e) {
      debugPrint('Lỗi Backend khi sửa task: $e');
      rethrow;
    }
  }

  /// Cập nhật nhanh trạng thái (kéo thả Kanban hoặc tick hoàn thành)
  Future<void> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      await _supabase.from('tasks').update({'status': status.name}).eq('id', taskId);
    } catch (e) {
      debugPrint('Lỗi Backend khi đổi trạng thái: $e');
      rethrow;
    }
  }

  /// Xoá công việc theo ID
  Future<void> deleteTask(String taskId) async {
    try {
      await _supabase.from('tasks').delete().eq('id', taskId);
    } catch (e) {
      debugPrint('Lỗi Backend khi xoá task: $e');
      rethrow;
    }
  }

  /// Lọc danh sách công việc theo Dự án (dùng cho module Projects)
  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    try {
      final response = await _supabase
          .from('tasks')
          .select()
          .eq('project_id', projectId)
          .order('created_at', ascending: false);

      return (response as List).map((json) => TaskModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Lỗi Backend khi lọc task theo dự án: $e');
      return [];
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_model.dart';
import '../../../core/services/supabase_service.dart';

class ProjectService {
  final SupabaseClient _supabase = SupabaseService.client;

  Stream<List<ProjectModel>> getProjectsStream() {
    return _supabase.from('projects').stream(primaryKey: ['id']).order('created_at', ascending: false)
        .map((dataList) => dataList.map((json) => ProjectModel.fromJson(json)).toList());
  }

  Future<void> createdProject(ProjectModel project) async {
    try {
      await _supabase.from('projects').insert(project.toJson());
    } catch (e) {
      debugPrint('Lỗi khi thêm project: $e');
      rethrow;
    }
  }

  Future<void> updateProject(ProjectModel project) async {
    try {
      await _supabase.from('projects').update(project.toJson()).eq('id', project.id);
    } catch (e) {
      debugPrint('Lỗi khi sửa project: $e');
      rethrow;
    }
  }

  Future<void> deleteProject(String projectId) async {
    try {
      await _supabase.from('projects').delete().eq('id', projectId);
    } catch (e) {
      debugPrint('Lỗi khi xóa project: $e');
      rethrow;
    }
  }
}
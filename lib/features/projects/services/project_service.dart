import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/project_member_model.dart';
import '../models/project_model.dart';
import '../../../core/services/supabase_service.dart';

class ProjectService {
  final SupabaseClient _supabase = SupabaseService.client;

  /// Lắng nghe toàn bộ bảng projects qua Realtime WebSocket
  Stream<List<ProjectModel>> getProjectsStream() {
    return _supabase
        .from('projects')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((dataList) => dataList.map((json) => ProjectModel.fromJson(json)).toList());
  }

  /// Lắng nghe bảng trung gian project_members qua Realtime WebSocket
  Stream<List<ProjectMemberModel>> getProjectMembersStream() {
    return _supabase
        .from('project_members')
        .stream(primaryKey: ['id'])
        .map((dataList) => dataList.map((json) => ProjectMemberModel.fromJson(json)).toList());
  }

  /// Tạo dự án mới + Tự động thêm người tạo làm Trưởng nhóm vào project_members
  Future<ProjectModel> createdProject(ProjectModel project) async {
    try {
      final response = await _supabase
          .from('projects')
          .insert(project.toJson())
          .select()
          .single();

      final created = ProjectModel.fromJson(response);

      if (created.ownerId != null && created.ownerId!.isNotEmpty) {
        await _supabase.from('project_members').upsert(
          {
            'project_id': created.id,
            'user_id': created.ownerId,
            'role': 'leader',
          },
          onConflict: 'project_id,user_id',
        );
      }

      return created;
    } catch (e) {
      debugPrint('Lỗi khi thêm project: $e');
      rethrow;
    }
  }

  /// Thêm một thành viên vào dự án (lưu vào bảng project_members)
  Future<void> addMember({
    required String projectId,
    required String userId,
    String role = 'member',
  }) async {
    try {
      await _supabase.from('project_members').upsert(
        {
          'project_id': projectId,
          'user_id': userId,
          'role': role,
        },
        onConflict: 'project_id,user_id',
      );
    } catch (e) {
      debugPrint('Lỗi khi thêm thành viên vào dự án: $e');
      rethrow;
    }
  }

  /// Xoá thành viên khỏi dự án
  Future<void> removeMember({
    required String projectId,
    required String userId,
  }) async {
    try {
      await _supabase
          .from('project_members')
          .delete()
          .eq('project_id', projectId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('Lỗi khi xoá thành viên khỏi dự án: $e');
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

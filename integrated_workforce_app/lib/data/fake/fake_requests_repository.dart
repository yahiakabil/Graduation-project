import '../models/request_model.dart';
import '../repositories/requests_repository.dart';
import 'fake_attendance_repository.dart';

class FakeRequestsRepository implements IRequestsRepository {
  final List<RequestModel> _requests = [
    RequestModel(
      id: 'req-1',
      employeeId: 'emp-1',
      employeeName: 'Ahmed Kamal',
      employeeRole: 'Senior Flutter Developer',
      type: RequestType.permission,
      status: RequestStatus.pending,
      submissionDate: DateTime.now().subtract(const Duration(hours: 3)),
      targetDate: 'Oct 18, 2026',
      minutes: 30,
      actualCheckInTime: '09:28 AM (28m late)',
      reason: 'Emergency tire breakdown on Ring Road.',
      reviewerRole: 'Direct Manager (Eng. Tarek)',
    ),
    RequestModel(
      id: 'req-2',
      employeeId: 'emp-1',
      employeeName: 'Ahmed Kamal',
      employeeRole: 'Senior Flutter Developer',
      type: RequestType.leave,
      status: RequestStatus.approved,
      submissionDate: DateTime.now().subtract(const Duration(days: 8)),
      targetDate: 'Oct 10 – Oct 12, 2026 (3 days)',
      reason: 'Annual family vacation trip to Alexandria.',
      managerComment: 'Approved. Handed off development sprint tasks to Omar.',
      reviewerRole: 'Direct Manager',
    ),
    RequestModel(
      id: 'req-3',
      employeeId: 'emp-2',
      employeeName: 'Sara Sami',
      employeeRole: 'Lead UI/UX Designer',
      type: RequestType.overtime,
      status: RequestStatus.pending,
      submissionDate: DateTime.now().subtract(const Duration(hours: 5)),
      targetDate: 'Oct 17, 2026',
      minutes: 120,
      reason: 'Finalized mobile app wireframes and interactive prototype.',
      reviewerRole: 'Direct Manager (Eng. Tarek)',
    ),
  ];

  @override
  Future<List<RequestModel>> getMyRequests() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_requests);
  }

  @override
  Future<List<RequestModel>> getPendingApprovals() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _requests.where((r) => r.status == RequestStatus.pending).toList();
  }

  @override
  Future<RequestModel> submitRequest(RequestModel request) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _requests.insert(0, request);
    return request;
  }

  @override
  Future<void> cancelRequest(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _requests.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> approveRequest(String id, {String? comment}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      final updated = _requests[index].copyWith(
        status: RequestStatus.approved,
        managerComment: comment ?? 'Approved by Manager.',
      );
      _requests[index] = updated;
      FakeAttendanceRepository.instance?.applyApprovedRequest(updated);
    }
  }

  @override
  Future<void> rejectRequest(String id, {String? comment}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _requests.indexWhere((r) => r.id == id);
    if (index != -1) {
      _requests[index] = _requests[index].copyWith(
        status: RequestStatus.rejected,
        managerComment: comment ?? 'Request rejected by Manager.',
      );
    }
  }
}

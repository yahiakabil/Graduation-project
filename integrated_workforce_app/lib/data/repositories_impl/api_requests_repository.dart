import '../api/api_client.dart';
import '../models/request_model.dart';
import '../repositories/requests_repository.dart';

class ApiRequestsRepository implements IRequestsRepository {
  List<RequestModel> _cachedRequests = [];

  @override
  Future<List<RequestModel>> getMyRequests() async {
    try {
      final res = await ApiClient.get('/requests/mine');
      if (res is List) {
        final list = res
            .map((item) => RequestModel.fromApiJson(item as Map<String, dynamic>))
            .toList();
        _cachedRequests = list;
        return list;
      }
      return _cachedRequests;
    } catch (e) {
      if (_cachedRequests.isNotEmpty) return _cachedRequests;
      return [];
    }
  }

  @override
  Future<List<RequestModel>> getPendingApprovals() async {
    try {
      final res = await ApiClient.get('/requests/pending');
      if (res is List) {
        return res
            .map((item) => RequestModel.fromApiJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      // Non-managers or 403 will gracefully return empty list
      return [];
    }
  }

  @override
  Future<RequestModel> submitRequest(RequestModel request) async {
    final payload = request.toApiPayload();
    final res = await ApiClient.post('/requests', body: payload);
    if (res is Map<String, dynamic>) {
      final created = RequestModel.fromApiJson(res);
      _cachedRequests.insert(0, created);
      return created;
    }
    _cachedRequests.insert(0, request);
    return request;
  }

  @override
  Future<void> cancelRequest(String id) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      try {
        await ApiClient.delete('/requests/$intId');
      } catch (_) {}
    }
    _cachedRequests.removeWhere((r) => r.id == id);
  }

  @override
  Future<void> approveRequest(String id, {String? comment}) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      await ApiClient.put('/requests/$intId/decide', body: {
        'decision': 'Approved',
        'comment': comment ?? 'Approved by Approver',
      });
    }
  }

  @override
  Future<void> rejectRequest(String id, {String? comment}) async {
    final intId = int.tryParse(id);
    if (intId != null) {
      await ApiClient.put('/requests/$intId/decide', body: {
        'decision': 'Rejected',
        'comment': comment ?? 'Rejected by Approver',
      });
    }
  }
}

import '../models/request_model.dart';

abstract class IRequestsRepository {
  Future<List<RequestModel>> getMyRequests();
  Future<List<RequestModel>> getPendingApprovals();
  Future<RequestModel> submitRequest(RequestModel request);
  Future<void> cancelRequest(String id);
  Future<void> approveRequest(String id, {String? comment});
  Future<void> rejectRequest(String id, {String? comment});
}

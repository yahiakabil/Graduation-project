import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/request_model.dart';
import '../../data/repositories/requests_repository.dart';
import 'requests_state.dart';

class RequestsCubit extends Cubit<RequestsState> {
  final IRequestsRepository requestsRepository;

  RequestsCubit({required this.requestsRepository}) : super(RequestsInitial());

  Future<void> loadRequests() async {
    emit(RequestsLoading());
    try {
      final mine = await requestsRepository.getMyRequests();
      final pending = await requestsRepository.getPendingApprovals();
      emit(RequestsLoaded(myRequests: mine, pendingApprovals: pending));
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  Future<void> submitRequest(RequestModel request) async {
    try {
      await requestsRepository.submitRequest(request);
      final mine = await requestsRepository.getMyRequests();
      final pending = await requestsRepository.getPendingApprovals();
      emit(RequestsLoaded(
        myRequests: mine,
        pendingApprovals: pending,
        message: 'Request submitted successfully!',
      ));
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  Future<void> cancelRequest(String id) async {
    try {
      await requestsRepository.cancelRequest(id);
      final mine = await requestsRepository.getMyRequests();
      final pending = await requestsRepository.getPendingApprovals();
      emit(RequestsLoaded(
        myRequests: mine,
        pendingApprovals: pending,
        message: 'Request cancelled.',
      ));
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  Future<void> approveRequest(String id, {String? comment}) async {
    try {
      await requestsRepository.approveRequest(id, comment: comment);
      final mine = await requestsRepository.getMyRequests();
      final pending = await requestsRepository.getPendingApprovals();
      emit(RequestsLoaded(
        myRequests: mine,
        pendingApprovals: pending,
        message: 'Request approved!',
      ));
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }

  Future<void> rejectRequest(String id, {String? comment}) async {
    try {
      await requestsRepository.rejectRequest(id, comment: comment);
      final mine = await requestsRepository.getMyRequests();
      final pending = await requestsRepository.getPendingApprovals();
      emit(RequestsLoaded(
        myRequests: mine,
        pendingApprovals: pending,
        message: 'Request rejected.',
      ));
    } catch (e) {
      emit(RequestsError(e.toString()));
    }
  }
}

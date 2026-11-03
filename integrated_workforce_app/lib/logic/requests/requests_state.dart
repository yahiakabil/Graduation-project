import 'package:equatable/equatable.dart';
import '../../data/models/request_model.dart';

abstract class RequestsState extends Equatable {
  const RequestsState();
  @override
  List<Object?> get props => [];
}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<RequestModel> myRequests;
  final List<RequestModel> pendingApprovals;
  final String? message;

  const RequestsLoaded({
    required this.myRequests,
    required this.pendingApprovals,
    this.message,
  });

  RequestsLoaded copyWith({
    List<RequestModel>? myRequests,
    List<RequestModel>? pendingApprovals,
    String? message,
  }) {
    return RequestsLoaded(
      myRequests: myRequests ?? this.myRequests,
      pendingApprovals: pendingApprovals ?? this.pendingApprovals,
      message: message,
    );
  }

  @override
  List<Object?> get props => [myRequests, pendingApprovals, message];
}

class RequestsError extends RequestsState {
  final String message;
  const RequestsError(this.message);
  @override
  List<Object?> get props => [message];
}

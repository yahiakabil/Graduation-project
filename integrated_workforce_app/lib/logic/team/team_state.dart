import 'package:equatable/equatable.dart';
import '../../data/models/team_member_model.dart';

abstract class TeamState extends Equatable {
  const TeamState();
  @override
  List<Object?> get props => [];
}

class TeamInitial extends TeamState {}

class TeamLoading extends TeamState {}

class TeamLoaded extends TeamState {
  final List<TeamMemberModel> members;
  final String? message;

  const TeamLoaded({required this.members, this.message});

  int get presentCount => members.where((m) => m.status.name == 'onTime' || m.status.name == 'late').length;
  int get lateCount => members.where((m) => m.status.name == 'late').length;
  int get absentCount => members.where((m) => m.status.name == 'absent').length;
  int get onLeaveCount => members.where((m) => m.status.name == 'onLeave').length;

  @override
  List<Object?> get props => [members, message];
}

class TeamError extends TeamState {
  final String message;
  const TeamError(this.message);
  @override
  List<Object?> get props => [message];
}

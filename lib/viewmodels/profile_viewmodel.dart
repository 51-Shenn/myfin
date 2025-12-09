import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/datamodels/member.dart';
import 'package:myfin/repository/profile_repo.dart';

// --- States ---
abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final Member member;
  ProfileLoaded(this.member);
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}

// --- Cubit ---
class ProfileViewModel extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileViewModel(this._repo) : super(ProfileInitial());

  Future<void> loadProfile(String memberId) async {
    emit(ProfileLoading());
    try {
      final member = await _repo.fetchMemberProfile(memberId);
      emit(ProfileLoaded(member));
    } catch (e) {
      emit(ProfileError("Failed to load profile: $e"));
    }
  }

  Future<void> logout() async {
    // Handle logout logic here (clear tokens, etc)
    // For now, just reset state
    emit(ProfileInitial());
  }
}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

class ProfileViewModel extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileViewModel(this._repo) : super(ProfileState.initial());

  Future<void> loadProfile(String memberId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await Future.wait([
        _repo.fetchMemberProfile(memberId),
        _repo.fetchBusinessProfile(memberId),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          member: results[0] as dynamic, 
          businessProfile: results[1] as dynamic, 
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: "Failed to load profile: $e"),
      );
    }
  }

  Future<void> logout() async {
    // Reset to initial state
    emit(ProfileState.initial());
  }

  Future<void> updateBusinessProfile(BusinessProfile profile) async {
    emit(state.copyWith(isLoading: true));

    try {
      // 1. Save to Firebase
      await _repo.saveBusinessProfile(profile);

      // 2. Update local state so UI reflects changes immediately
      emit(state.copyWith(
        isLoading: false,
        businessProfile: profile, // Update the displayed profile
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: "Failed to save profile: $e",
      ));
    }
  }
}

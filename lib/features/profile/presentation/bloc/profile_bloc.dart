import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/profile/domain/repositories/profile_repository.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart';

class ProfileViewModel extends Cubit<ProfileState> {
  final ProfileRepository _repo;

  ProfileViewModel(this._repo) : super(ProfileState.initial());

  Future<void> loadProfile(String memberId) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await Future.wait([
        _repo.getMemberProfile(memberId),
        _repo.getBusinessProfile(memberId),
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
    emit(ProfileState.initial());
  }

  Future<void> updateBusinessProfile(BusinessProfile profile) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _repo.saveBusinessProfile(profile);

      emit(state.copyWith(
        isLoading: false,
        businessProfile: profile,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: "Failed to save profile: $e",
      ));
    }
  }
}
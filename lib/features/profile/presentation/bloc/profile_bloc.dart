import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/profile/domain/repositories/profile_repository.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _repo;

  ProfileBloc(this._repo) : super(ProfileState.initial()) {
    // Register Event Handlers
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateBusinessProfileEvent>(_onUpdateBusinessProfile);
    on<LogoutEvent>(_onLogout);
    // Register the handler for ChangePasswordEvent
    on<ChangePasswordEvent>(_onChangePassword);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // 1. Emit loading state
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // 2. Fetch data in parallel
      final results = await Future.wait([
        _repo.getMemberProfile(event.memberId),
        _repo.getBusinessProfile(event.memberId),
      ]);

      // 3. Emit success state
      emit(
        state.copyWith(
          isLoading: false,
          member: results[0] as dynamic,
          businessProfile: results[1] as dynamic,
        ),
      );
    } catch (e) {
      // 4. Emit error state
      emit(
        state.copyWith(isLoading: false, error: "Failed to load profile: $e"),
      );
    }
  }

  Future<void> _onUpdateBusinessProfile(
    UpdateBusinessProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _repo.saveBusinessProfile(event.profile);

      // Update the local state with the new profile data
      emit(state.copyWith(isLoading: false, businessProfile: event.profile));
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: "Failed to save profile: $e"),
      );
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(ProfileState.initial());
  }

  Future<void> _onChangePassword(
    ChangePasswordEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(passwordStatus: FormStatus.submissionInProgress, error: null));

    try {
      await _repo.changePassword(event.currentPassword, event.newPassword);

      emit(state.copyWith(passwordStatus: FormStatus.submissionSuccess));
      
      // Reset password status to initial after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        if (this.isClosed) return;
        emit(state.copyWith(passwordStatus: FormStatus.initial));
      });

    } catch (e) {
      emit(state.copyWith(
        passwordStatus: FormStatus.submissionFailure,
        error: e.toString(),
      ));
    }
  }
}
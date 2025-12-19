import 'dart:typed_data'; 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart';
import 'package:myfin/features/profile/domain/entities/business_profile.dart'; 
import 'package:myfin/features/profile/domain/repositories/profile_repository.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepo;
  final MemberRepository _memberRepo; 
  ProfileBloc({
    required ProfileRepository profileRepo,
    required MemberRepository memberRepo,
  }) : _profileRepo = profileRepo,
       _memberRepo = memberRepo,
       super(ProfileState.initial()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateBusinessProfileEvent>(_onUpdateBusinessProfile);
    on<UpdateMemberProfileEvent>(_onUpdateMemberProfile);
    on<LogoutEvent>(_onLogout);
    on<ChangePasswordEvent>(_onChangePassword);
    on<ChangeEmailEvent>(_onChangeEmail);
     on<DeleteAccountEvent>(_onDeleteAccount);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      await currentUser?.reload();

      var member = await _memberRepo.getMember(event.memberId);

      if (currentUser != null &&
          currentUser.email != null &&
          currentUser.email != member.email) {
        final updatedMember = Member(
          member_id: member.member_id,
          username: member.username,
          first_name: member.first_name,
          last_name: member.last_name,
          email: currentUser.email!, 
          phone_number: member.phone_number,
          address: member.address,
          created_at: member.created_at,
          status: member.status,
        );

        await _memberRepo.updateMember(updatedMember);
        member =
            updatedMember; 
      }

      final results = await Future.wait([
        _profileRepo.getBusinessProfile(event.memberId),
        _profileRepo.getProfileImage(event.memberId),
        _profileRepo.getBusinessLogo(event.memberId),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          member: member,
          businessProfile: results[0] as BusinessProfile,
          profileImageBytes: results[1] as Uint8List?,
          businessImageBytes: results[2] as Uint8List?,
        ),
      );
    } catch (e) {
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
      await _profileRepo.saveBusinessProfile(event.profile);

      Uint8List? newLogoBytes;

      if (event.logoFile != null) {
        final idToUse = event.profile.profileId.isNotEmpty
            ? event.profile.profileId
            : event.profile.memberId;

        await _profileRepo.uploadBusinessLogo(idToUse, event.logoFile!);

        newLogoBytes = await event.logoFile!.readAsBytes();
      } else {
        newLogoBytes = state.businessImageBytes;
      }

      emit(
        state.copyWith(
          isLoading: false,
          businessProfile: event.profile,
          businessImageBytes: newLogoBytes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: "Failed to save profile: $e"),
      );
    }
  }

  Future<void> _onUpdateMemberProfile(
    UpdateMemberProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.email != event.member.email) {
        try {
          throw Exception(
            "To update your email, please use the 'Change Email' feature in settings.",
          );
        } catch (e) {
          throw e;
        }
      }
      await _memberRepo.updateMember(event.member);

      Uint8List? newImageBytes;

      if (event.newImageFile != null) {
        await _profileRepo.uploadProfileImage(
          event.member.member_id,
          event.newImageFile!,
        );
        newImageBytes = await event.newImageFile!.readAsBytes();
      } else {
        newImageBytes = state.profileImageBytes;
      }

      emit(
        state.copyWith(
          isLoading: false,
          member: event.member,
          profileImageBytes: newImageBytes,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoading: false, error: "Failed to update member: $e"),
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
    emit(
      state.copyWith(
        passwordStatus: FormStatus.submissionInProgress,
        error: null,
      ),
    );

    try {
      await _profileRepo.changePassword(
        event.currentPassword,
        event.newPassword,
      );

      emit(state.copyWith(passwordStatus: FormStatus.submissionSuccess));

      Future.delayed(const Duration(seconds: 2), () {
        if (this.isClosed) return;
        emit(state.copyWith(passwordStatus: FormStatus.initial));
      });
    } catch (e) {
      emit(
        state.copyWith(
          passwordStatus: FormStatus.submissionFailure,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> _onChangeEmail(
    ChangeEmailEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(emailStatus: FormStatus.submissionInProgress, error: null),
    );

    try {
      await _profileRepo.changeEmail(event.newEmail, event.currentPassword);

      emit(
        state.copyWith(
          emailStatus: FormStatus.submissionSuccess,
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) emit(state.copyWith(emailStatus: FormStatus.initial));
      });
    } catch (e) {
      emit(
        state.copyWith(
          emailStatus: FormStatus.submissionFailure,
          error: e.toString().replaceAll("Exception: ", ""),
        ),
      );
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(deleteStatus: FormStatus.submissionInProgress, error: null));

    try {
      await _profileRepo.deleteAccount(event.password);
      emit(state.copyWith(deleteStatus: FormStatus.submissionSuccess));
    } catch (e) {
      emit(
        state.copyWith(
          deleteStatus: FormStatus.submissionFailure,
          error: e.toString().replaceAll("Exception: ", ""),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) emit(state.copyWith(deleteStatus: FormStatus.initial));
      });
    }
  }
}

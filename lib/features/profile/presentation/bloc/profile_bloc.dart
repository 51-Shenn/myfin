import 'dart:typed_data'; // Required for Uint8List
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myfin/features/authentication/domain/entities/member.dart'; // Required for Member
import 'package:myfin/features/profile/domain/entities/business_profile.dart'; // Required for BusinessProfile
import 'package:myfin/features/profile/domain/repositories/profile_repository.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_event.dart';
import 'package:myfin/features/profile/presentation/bloc/profile_state.dart';
import 'package:myfin/features/authentication/domain/repositories/member_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepo;
  final MemberRepository _memberRepo; // Add this

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

      // 1. Force reload to ensure we have the absolute latest email from Firebase Auth
      // This might throw the 'user-token-expired' error if session is dead,
      // which is good because the UI listener we added above will catch it.
      await currentUser?.reload();

      // 2. Fetch Firestore Data
      // Note: We fetch MemberRepo using event.memberId, assuming ID hasn't changed.
      var member = await _memberRepo.getMember(event.memberId);

      // 3. SYNC LOGIC: If Auth email differs from Firestore email, update Firestore
      if (currentUser != null &&
          currentUser.email != null &&
          currentUser.email != member.email) {
        final updatedMember = Member(
          member_id: member.member_id,
          username: member.username,
          first_name: member.first_name,
          last_name: member.last_name,
          email: currentUser.email!, // <--- SYNC HERE
          phone_number: member.phone_number,
          address: member.address,
          created_at: member.created_at,
          status: member.status,
        );

        await _memberRepo.updateMember(updatedMember);
        member =
            updatedMember; // Update local variable so UI shows new email immediately
      }

      // 4. Fetch remaining data
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
      // The UI Listener will catch "user-token-expired" from this string
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
      // 1. Save Text Data
      await _profileRepo.saveBusinessProfile(event.profile);

      Uint8List? newLogoBytes;

      // 2. Upload Logo if provided
      if (event.logoFile != null) {
        // Use the profileId (which is usually memberId based on your logic)
        final idToUse = event.profile.profileId.isNotEmpty
            ? event.profile.profileId
            : event.profile.memberId;

        await _profileRepo.uploadBusinessLogo(idToUse, event.logoFile!);

        // Update local state immediately
        newLogoBytes = await event.logoFile!.readAsBytes();
      } else {
        // Keep existing if no new one
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
        // ERROR: We cannot update email securely without the user's password.
        // In a real app, you should pop up a dialog asking for the password
        // if the email field is modified.

        // For now, let's assume you pass password in the event or handle it separately.
        // If you strictly want to prevent the crash you asked about:

        try {
          // You would call repo.updateEmail(...) here if you had the password
          // But since standard updateEmail throws 'email-already-in-use', we catch it.

          // For this example, let's just validate against current user to prevent
          // accidental DB drift if we can't update Auth.
          throw Exception(
            "To update your email, please use the 'Change Email' feature in settings.",
          );
        } catch (e) {
          throw e; // Rethrow to be caught below
        }
      }
      // 1. Update text data
      await _memberRepo.updateMember(event.member);

      Uint8List? newImageBytes;

      // 2. If image exists, upload it AND read bytes for UI
      if (event.newImageFile != null) {
        // Upload to server
        await _profileRepo.uploadProfileImage(
          event.member.member_id,
          event.newImageFile!,
        );

        // Read bytes for local UI update
        newImageBytes = await event.newImageFile!.readAsBytes();
      } else {
        // Keep existing image if no new one picked
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

      // Reset password status to initial after a short delay
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
          // Optional: clear error
        ),
      );

      // Reset status after delay
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
      // Reset status so user can try again
      Future.delayed(const Duration(seconds: 2), () {
        if (!isClosed) emit(state.copyWith(deleteStatus: FormStatus.initial));
      });
    }
  }
}

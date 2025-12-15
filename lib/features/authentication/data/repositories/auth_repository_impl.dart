
import 'package:myfin/features/authentication/domain/repositories/auth_repository.dart';
import 'package:myfin/features/authentication/data/datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<String> signInWithEmail(String email, String password) async {
    return await remote.signInWithEmail(email, password);
  }

  @override
  Future<String> signUpWithEmail(String email, String password) async {
    return await remote.signUpWithEmail(email, password);
  }

  @override
  Future<void> signOut() async {
    return await remote.signOut();
  }

  @override
  Future<String?> getCurrentUserId() async {
    return await remote.getCurrentUserId();
  }

  @override
  Future<void> resetPassword(String email) async {
    return await remote.resetPassword(email);
  }
}

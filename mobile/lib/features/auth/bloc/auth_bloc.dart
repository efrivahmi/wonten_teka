import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/api/api_exceptions.dart';
import '../../../core/models/user_model.dart';
import '../../../core/repositories/auth_repository.dart';

// ── Events ─────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckSession extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  const AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthCompleteProfileRequested extends AuthEvent {
  final Map<String, dynamic> profileData;
  const AuthCompleteProfileRequested(this.profileData);
  @override
  List<Object?> get props => [profileData];
}

class AuthLogoutRequested extends AuthEvent {}

// ── States ─────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  final Map<String, dynamic>? fieldErrors;
  const AuthError(this.message, {this.fieldErrors});
  @override
  List<Object?> get props => [message];
}

// ── Bloc ────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthInitial()) {
    on<AuthCheckSession>(_onCheckSession);
    on<AuthLoginRequested>(_onLogin);
    on<AuthCompleteProfileRequested>(_onCompleteProfile);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckSession(AuthCheckSession event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final hasToken = await _authRepository.hasToken();
      if (!hasToken) {
        emit(AuthUnauthenticated());
        return;
      }

      // Try to get fresh user data from backend
      try {
        final user = await _authRepository.getMe();
        emit(AuthAuthenticated(user));
      } on UnauthorizedException {
        // Token expired
        await _authRepository.logout();
        emit(AuthUnauthenticated());
      } catch (_) {
        // Network error — try cached user
        final cached = await _authRepository.getCachedUser();
        if (cached != null) {
          emit(AuthAuthenticated(cached));
        } else {
          emit(AuthUnauthenticated());
        }
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.login(
        email: event.email,
        password: event.password,
        deviceName: 'wonten_teka_mobile',
      );
      emit(AuthAuthenticated(user));
    } on ValidationException catch (e) {
      emit(AuthError(e.allErrors.join('\n'), fieldErrors: e.errors));
    } on NetworkException {
      emit(const AuthError('Tidak ada koneksi internet. Silakan cek jaringan Anda.'));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Terjadi kesalahan. Silakan coba lagi.'));
    }
  }

  Future<void> _onCompleteProfile(AuthCompleteProfileRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await _authRepository.completeProfile(event.profileData);
      emit(AuthAuthenticated(user));
    } on ValidationException catch (e) {
      emit(AuthError(e.allErrors.join('\n'), fieldErrors: e.errors));
    } on NetworkException {
      emit(const AuthError('Tidak ada koneksi internet. Silakan cek jaringan Anda.'));
    } on ApiException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(const AuthError('Terjadi kesalahan saat melengkapi profil. Silakan coba lagi.'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await _authRepository.logout();
    emit(AuthUnauthenticated());
  }
}

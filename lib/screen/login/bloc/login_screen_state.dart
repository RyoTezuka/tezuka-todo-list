import 'package:equatable/equatable.dart';

abstract class LoginScreenState extends Equatable {
  const LoginScreenState();
}

class InitialState extends LoginScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期';
}

class InitializeInProgressState extends LoginScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化中';
}

class InitializeSuccessState extends LoginScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化成功後';
}

class InitializeFailureState extends LoginScreenState {
  final dynamic error;
  final dynamic stackTrace;

  const InitializeFailureState({
    required this.error,
    required this.stackTrace,
  });

  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化失敗後';
}

class IdleState extends LoginScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '待機中';
}

class AuthenticateInProgressState extends LoginScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '認証中';
}

class AuthenticateSuccessState extends LoginScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '認証成功後';
}

class AuthenticateFailureState extends LoginScreenState {
  final dynamic error;
  final dynamic stackTrace;

  const AuthenticateFailureState({
    required this.error,
    required this.stackTrace,
  });

  @override
  List<Object> get props => [];

  @override
  String toString() => '認証失敗後';
}

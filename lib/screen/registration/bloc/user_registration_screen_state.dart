import 'package:equatable/equatable.dart';

abstract class RegistrationScreenState extends Equatable {
  const RegistrationScreenState();
}

class InitialState extends RegistrationScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期';
}

class InitializeInProgressState extends RegistrationScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化中';
}

class InitializeSuccessState extends RegistrationScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化成功後';
}

class InitializeFailureState extends RegistrationScreenState {
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

class IdleState extends RegistrationScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '待機中';
}

class CreateUserInProgressState extends RegistrationScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => 'ユーザー登録中';
}

class CreateUserSuccessState extends RegistrationScreenState {
  final String result;

  const CreateUserSuccessState({
    required this.result,
  });

  @override
  List<Object> get props => [
        result,
      ];

  @override
  String toString() => 'ユーザー登録成功後';
}

class CreateUserFailureState extends RegistrationScreenState {
  final dynamic error;
  final dynamic stackTrace;

  const CreateUserFailureState({
    required this.error,
    required this.stackTrace,
  });

  @override
  List<Object> get props => [
        error,
        stackTrace,
      ];

  @override
  String toString() => 'ユーザー登録失敗後';
}

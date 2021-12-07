import 'package:equatable/equatable.dart';

abstract class RegistrationScreenEvent extends Equatable {
  const RegistrationScreenEvent();
}

class OnRequestedInitializeEvent extends RegistrationScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化要求';
}

class OnCompletedRenderEvent extends RegistrationScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '描画完了';
}

class OnCreateUserEvent extends RegistrationScreenEvent {
  final String name;
  final String password;

  const OnCreateUserEvent({
    required this.name,
    required this.password,
  });

  @override
  List<Object> get props => [
        name,
        password,
      ];

  @override
  String toString() => '登録要求';
}

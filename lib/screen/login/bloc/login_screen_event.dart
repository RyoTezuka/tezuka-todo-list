import 'package:equatable/equatable.dart';

abstract class LoginScreenEvent extends Equatable {
  const LoginScreenEvent();
}

class OnRequestedInitializeEvent extends LoginScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化要求';
}

class OnCompletedRenderEvent extends LoginScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '描画完了';
}

class OnRequestedAuthenticateEvent extends LoginScreenEvent {
  final String name;
  final String password;

  const OnRequestedAuthenticateEvent({
    required this.name,
    required this.password,
  });

  @override
  List<Object> get props => [
        name,
        password,
      ];

  @override
  String toString() => '認証要求';
}

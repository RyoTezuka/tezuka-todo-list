import 'package:equatable/equatable.dart';

abstract class TodoListScreenEvent extends Equatable {
  const TodoListScreenEvent();
}

class OnRequestedInitializeEvent extends TodoListScreenEvent {
  final String name;
  const OnRequestedInitializeEvent({
    required this.name,
  });

  @override
  List<Object> get props => [
        name,
      ];

  @override
  String toString() => '初期化要求';
}

class OnCompletedRenderEvent extends TodoListScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '描画完了';
}

class OnRequestedAuthenticateEvent extends TodoListScreenEvent {
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

import 'package:equatable/equatable.dart';

abstract class TodoDetailScreenEvent extends Equatable {
  const TodoDetailScreenEvent();
}

class OnRequestedInitializeEvent extends TodoDetailScreenEvent {
  final String name;
  final String todoId;
  const OnRequestedInitializeEvent({
    required this.name,
    required this.todoId,
  });

  @override
  List<Object> get props => [
        name,
        todoId,
      ];

  @override
  String toString() => '初期化要求';
}

class OnCompletedRenderEvent extends TodoDetailScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '描画完了';
}

class OnRequestedUpdateEvent extends TodoDetailScreenEvent {
  final String todoId;
  const OnRequestedUpdateEvent({
    required this.todoId,
  });
  @override
  List<Object> get props => [
        todoId,
      ];

  @override
  String toString() => '編集要求';
}

class OnRequestedDeleteEvent extends TodoDetailScreenEvent {
  final String todoId;
  const OnRequestedDeleteEvent({
    required this.todoId,
  });

  @override
  List<Object> get props => [
        todoId,
      ];

  @override
  String toString() => '削除要求';
}

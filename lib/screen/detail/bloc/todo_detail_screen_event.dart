import 'package:equatable/equatable.dart';

abstract class TodoDetailScreenEvent extends Equatable {
  const TodoDetailScreenEvent();
}

class OnRequestedInitializeEvent extends TodoDetailScreenEvent {
  final String name;
  final String id;
  const OnRequestedInitializeEvent({
    required this.name,
    required this.id,
  });

  @override
  List<Object> get props => [
        name,
        id,
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
  final String id;
  const OnRequestedUpdateEvent({
    required this.id,
  });
  @override
  List<Object> get props => [
        id,
      ];

  @override
  String toString() => '編集要求';
}

class OnRequestedDeleteEvent extends TodoDetailScreenEvent {
  final String id;
  const OnRequestedDeleteEvent({
    required this.id,
  });

  @override
  List<Object> get props => [
        id,
      ];

  @override
  String toString() => '削除要求';
}

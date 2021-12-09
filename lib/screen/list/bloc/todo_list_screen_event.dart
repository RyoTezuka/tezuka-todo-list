import 'package:equatable/equatable.dart';

abstract class TodoListScreenEvent extends Equatable {
  const TodoListScreenEvent();
}

class OnRequestedInitializeEvent extends TodoListScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化要求';
}

class OnCompletedRenderEvent extends TodoListScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '描画完了';
}

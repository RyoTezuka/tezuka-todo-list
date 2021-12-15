import 'package:equatable/equatable.dart';
import 'package:todo_management/model/TodoModel.dart';

abstract class TodoListScreenState extends Equatable {
  const TodoListScreenState();
}

class InitialState extends TodoListScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期';
}

class InitializeInProgressState extends TodoListScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化中';
}

class InitializeSuccessState extends TodoListScreenState {
  final TodoModel todoDetailData;
  const InitializeSuccessState({
    required this.todoDetailData,
  });

  @override
  List<Object> get props => [
        todoDetailData,
      ];

  @override
  String toString() => '初期化成功後';
}

class InitializeFailureState extends TodoListScreenState {
  final dynamic error;
  final dynamic stackTrace;

  const InitializeFailureState({
    required this.error,
    required this.stackTrace,
  });

  @override
  List<Object> get props => [
        error,
        stackTrace,
      ];

  @override
  String toString() => '初期化失敗後';
}

class IdleState extends TodoListScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '待機中';
}

class UpdateInProgressState extends TodoListScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '編集中';
}

class DeleteInProgressState extends TodoListScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '削除中';
}

class DeleteSuccessState extends TodoListScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '削除成功後';
}

class DeleteFailureState extends TodoListScreenState {
  final dynamic error;
  final dynamic stackTrace;

  const DeleteFailureState({
    required this.error,
    required this.stackTrace,
  });
  @override
  List<Object> get props => [
        error,
        stackTrace,
      ];

  @override
  String toString() => '削除失敗後';
}

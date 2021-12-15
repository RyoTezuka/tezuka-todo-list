import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:todo_management/model/TodoModel.dart';

abstract class TodoCreateModifyScreenState extends Equatable {
  const TodoCreateModifyScreenState();
}

class InitialState extends TodoCreateModifyScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期';
}

class InitializeInProgressState extends TodoCreateModifyScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '初期化中';
}

class InitializeSuccessState extends TodoCreateModifyScreenState {
  final bool isCreate;
  final TodoModel todoDetailData;
  const InitializeSuccessState({
    required this.isCreate,
    required this.todoDetailData,
  });

  @override
  List<Object> get props => [
        isCreate,
        todoDetailData,
      ];

  @override
  String toString() => '初期化成功後';
}

class InitializeFailureState extends TodoCreateModifyScreenState {
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

class IdleState extends TodoCreateModifyScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '待機中';
}

class ChangeDateTimeState extends TodoCreateModifyScreenState {
  final DateTime dateTime;
  const ChangeDateTimeState({
    required this.dateTime,
  });
  @override
  List<Object> get props => [
        dateTime,
      ];

  @override
  String toString() => '内容記載中';
}

class ChangeTimeOfDayState extends TodoCreateModifyScreenState {
  final TimeOfDay timeOfDay;
  const ChangeTimeOfDayState({
    required this.timeOfDay,
  });
  @override
  List<Object> get props => [
        timeOfDay,
      ];

  @override
  String toString() => '内容記載中';
}

class CreateUpdateInProgressState extends TodoCreateModifyScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '更新中';
}

class CreateUpdateSuccessState extends TodoCreateModifyScreenState {
  @override
  List<Object> get props => [];

  @override
  String toString() => '更新成功後';
}

class CreateUpdateFailureState extends TodoCreateModifyScreenState {
  final dynamic error;
  final dynamic stackTrace;

  const CreateUpdateFailureState({
    required this.error,
    required this.stackTrace,
  });

  @override
  List<Object> get props => [
        error,
        stackTrace,
      ];

  @override
  String toString() => '更新失敗後';
}

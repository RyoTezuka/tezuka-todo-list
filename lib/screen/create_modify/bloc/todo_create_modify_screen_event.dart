import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

abstract class TodoCreateModifyScreenEvent extends Equatable {
  const TodoCreateModifyScreenEvent();
}

class OnRequestedInitializeEvent extends TodoCreateModifyScreenEvent {
  final String todoId;

  const OnRequestedInitializeEvent({
    required this.todoId,
  });

  @override
  List<Object> get props => [
        todoId,
      ];

  @override
  String toString() => '初期化要求';
}

class OnCompletedRenderEvent extends TodoCreateModifyScreenEvent {
  @override
  List<Object> get props => [];

  @override
  String toString() => '描画完了';
}

class OnCreateModifyEvent extends TodoCreateModifyScreenEvent {
  final String todoId;
  final String title;
  final String deadline;
  final String priority;
  final String detail;

  const OnCreateModifyEvent({
    required this.todoId,
    required this.title,
    required this.deadline,
    required this.detail,
    required this.priority,
  });

  @override
  List<Object> get props => [
        todoId,
        title,
        deadline,
        detail,
        priority,
      ];

  @override
  String toString() => '詳細登録要求';
}

class OnChangeDateTimeEvent extends TodoCreateModifyScreenEvent {
  final DateTime dateTime;

  const OnChangeDateTimeEvent({
    required this.dateTime,
  });

  @override
  List<Object> get props => [
        dateTime,
      ];

  @override
  String toString() => '日付変更発生';
}

class OnChangeTimeOfDayEvent extends TodoCreateModifyScreenEvent {
  final TimeOfDay timeOfDay;

  const OnChangeTimeOfDayEvent({
    required this.timeOfDay,
  });

  @override
  List<Object> get props => [
        timeOfDay,
      ];

  @override
  String toString() => '時間変更発生';
}

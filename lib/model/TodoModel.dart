import 'package:equatable/equatable.dart';

class TodoModel extends Equatable {
  final String todoId;
  final String title;
  final String priority;
  final String deadline;
  final String detail;

  const TodoModel({
    required this.todoId,
    required this.title,
    required this.deadline,
    required this.priority,
    required this.detail,
  });

  @override
  List<Object?> get props => [
        todoId,
        title,
        deadline,
        priority,
        detail,
      ];
}

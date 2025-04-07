class Task {
  final String id;
  final String name;
  final bool isCompleted;

  Task({required this.id, required this.name, required this.isCompleted});

  factory Task.fromMap(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      name: data['name'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() 
  {
    return {
      'name': name,
      'isCompleted': isCompleted,
    };
  }
}

class TimeBlockTask {
  final String id;
  final String day;
  final String timeRange;
  final List<String> tasks;

  TimeBlockTask({
    required this.id,
    required this.day,
    required this.timeRange,
    required this.tasks,
  });

  factory TimeBlockTask.fromMap(Map<String, dynamic> data, String id) {
    return TimeBlockTask(
      id: id,
      day: data['day'] ?? '',
      timeRange: data['timeRange'] ?? '',
      tasks: List<String>.from(data['tasks'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'timeRange': timeRange,
      'tasks': tasks,
    };
  }
}

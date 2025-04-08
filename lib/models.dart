class Task {
  String id;
  String name;
  bool isCompleted;
  List<Task> subTasks; 

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.subTasks = const [],
  });


  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'subTasks': subTasks.map((e) => e.toMap()).toList(), 
    };
  }

  
  factory Task.fromMap(Map<String, dynamic> map, String id) {
    return Task(
      id: id,
      name: map['name'],
      isCompleted: map['isCompleted'],
      subTasks: (map['subTasks'] as List?)
              ?.map((subtask) => Task.fromMap(subtask, ''))
              .toList() ??
          [],
    );
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


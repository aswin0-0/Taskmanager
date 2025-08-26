class Task {
  final int id;
  final String title;
  final String description;
  final String category;
  final DateTime due_date;
  final bool completed;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.due_date,
    required this.completed,
  });

  // Convert JSON → Task
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      due_date: DateTime.parse(json['due_date']),
      completed: json['isDone'],
    );
  }
  

  // Convert Task → JSON
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "category": category,
      "due_date": "{dueDate.toLocal()}".split(' ')[0],
      "isDone": completed ,
    };
  }
}

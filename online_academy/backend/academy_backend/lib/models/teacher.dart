class Teacher {
  final int id;
  final String name;
  final double salary;

  Teacher({
    required this.id,
    required this.name,
    required this.salary,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        id: json['id'],
        name: json['name'],
        salary: (json['salary'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'salary': salary,
      };

  @override
  String toString() => 'Teacher $name - \$${salary.toStringAsFixed(2)}';
}

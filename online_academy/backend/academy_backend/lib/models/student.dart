class Student {
  final int id;
  final String name;
  int age;

  Student({
    required this.id,
    required this.name,
    required this.age,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        name: json['name'],
        age: json['age'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'age': age,
      };

  @override
  String toString() => 'Student $name (Age: $age)';
}

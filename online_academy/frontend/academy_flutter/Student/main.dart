class Student {
  final int id;
  final String name;
  final int age;

  Student({required this.id, required this.name, required this.age});

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        id: json['id'],
        name: json['name'],
        age: json['age'],
      );
}

class Course {
  final int id;
  final String name;
  final String teacher;
  final double price;
  int slots;

  Course({
    required this.id,
    required this.name,
    required this.teacher,
    required this.price,
    required this.slots,
  });

  factory Course.fromJson(Map<String, dynamic> json) => Course(
        id: json['id'],
        name: json['name'],
        teacher: json['teacher'],
        price: (json['price'] as num).toDouble(),
        slots: json['slots'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'teacher': teacher,
        'price': price,
        'slots': slots,
      };

  @override
  String toString() => '$name by $teacher - \$${price.toStringAsFixed(2)}';
}

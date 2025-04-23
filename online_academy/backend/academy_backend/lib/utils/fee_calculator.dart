import '../models/course.dart';

// ✅ Đổi tên hàm này để tránh xung đột với method trong AcademySystem
double calculateCourseFee(List<int> courseIds, List<Course> courses) {
  double total = 0.0;
  for (var id in courseIds) {
    final course = courses.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Không tìm thấy khóa học có ID $id'),
    );
    total += course.price;
  }
  return total;
}

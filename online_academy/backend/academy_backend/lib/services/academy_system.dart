import '../models/student.dart';
import '../models/course.dart';
import '../utils/fee_calculator.dart';

class AcademySystem {
  final List<Student> students;
  final List<Course> courses;

  AcademySystem({
    required this.students,
    required this.courses,
  });

  // In danh sách học viên
  void printStudents() {
    print('\nDanh sách học viên:');
    for (var student in students) {
      print(student);
    }
  }

  // In danh sách khóa học
  void printCourses() {
    print('\nDanh sách khóa học:');
    for (var course in courses) {
      print(course);
    }
  }

  // Đăng ký học viên vào khóa học (theo id)
  void registerStudentToCourse(int studentId, int courseId) {
    var student = students.firstWhere((s) => s.id == studentId, orElse: () => throw Exception('Không tìm thấy học viên'));
    var course = courses.firstWhere((c) => c.id == courseId, orElse: () => throw Exception('Không tìm thấy khóa học'));

    if (course.slots > 0) {
      course.slots -= 1;
      print('${student.name} đã đăng ký thành công khóa "${course.name}"');
    } else {
      print('❌ Khóa học "${course.name}" đã hết chỗ!');
    }
  }

  // Tính tổng học phí cho học viên khi học nhiều khóa
  double calculateTotalFee(List<int> courseIds) {
    double total = 0.0;
    for (var id in courseIds) {
      var course = courses.firstWhere((c) => c.id == id, orElse: () => throw Exception('Không tìm thấy khóa học'));
      total += course.price;
    }
    return calculateCourseFee(courseIds, courses);
}
}

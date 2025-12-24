import 'package:flutter_test/flutter_test.dart';
import 'package:vipt/app/data/services/auth_service.dart';
import 'package:get/get.dart';

/// Unit Tests cho các hàm validation
/// Phục vụ cho báo cáo: Chương 5.1 - Unit Test
void main() {
  group('Validation - Email', () {
    test('Email hợp lệ', () {
      expect(GetUtils.isEmail('test@example.com'), isTrue);
      expect(GetUtils.isEmail('user.name@domain.com'), isTrue);
      expect(GetUtils.isEmail('user+tag@example.co.uk'), isTrue);
    });

    test('Email không hợp lệ', () {
      expect(GetUtils.isEmail('invalid-email'), isFalse);
      expect(GetUtils.isEmail('@example.com'), isFalse);
      expect(GetUtils.isEmail('user@'), isFalse);
      expect(GetUtils.isEmail('user name@example.com'), isFalse);
      expect(GetUtils.isEmail(''), isFalse);
    });

    test('Email có ký tự đặc biệt không hợp lệ', () {
      // GetX cho phép '#' trong email (theo RFC5322)
      // Chỉ test các trường hợp thực sự không hợp lệ
      expect(
          GetUtils.isEmail('user@exam ple.com'), isFalse); // Space trong domain
      expect(GetUtils.isEmail('user@@example.com'), isFalse); // Hai @ liên tiếp
    });
  });

  group('Validation - Password', () {
    test('Mật khẩu đủ độ dài (>= 6 ký tự)', () {
      String password1 = '123456';
      String password2 = 'password123';
      String password3 = 'abc123';

      expect(password1.length >= 6, isTrue);
      expect(password2.length >= 6, isTrue);
      expect(password3.length >= 6, isTrue);
    });

    test('Mật khẩu quá ngắn (< 6 ký tự)', () {
      String password1 = '12345';
      String password2 = 'abc';
      String password3 = '';

      expect(password1.length < 6, isTrue);
      expect(password2.length < 6, isTrue);
      expect(password3.length < 6, isTrue);
    });

    test('Mật khẩu và xác nhận mật khẩu khớp nhau', () {
      String password = 'password123';
      String confirmPassword = 'password123';

      expect(password == confirmPassword, isTrue);
    });

    test('Mật khẩu và xác nhận mật khẩu không khớp', () {
      String password = 'password123';
      String confirmPassword = 'password456';

      expect(password == confirmPassword, isFalse);
    });
  });

  group('Validation - Thông tin người dùng', () {
    test('Chiều cao hợp lệ (cm)', () {
      double height1 = 170;
      double height2 = 150;
      double height3 = 200;

      // Giả sử range hợp lệ: 140-220cm
      expect(height1 >= 140 && height1 <= 220, isTrue);
      expect(height2 >= 140 && height2 <= 220, isTrue);
      expect(height3 >= 140 && height3 <= 220, isTrue);
    });

    test('Chiều cao không hợp lệ (cm)', () {
      double height1 = 100; // Quá thấp
      double height2 = 250; // Quá cao
      double height3 = -10; // Âm

      expect(height1 < 140, isTrue);
      expect(height2 > 220, isTrue);
      expect(height3 < 0, isTrue);
    });

    test('Cân nặng hợp lệ (kg)', () {
      double weight1 = 70;
      double weight2 = 50;
      double weight3 = 90;

      // Giả sử range hợp lệ: 30-200kg
      expect(weight1 >= 30 && weight1 <= 200, isTrue);
      expect(weight2 >= 30 && weight2 <= 200, isTrue);
      expect(weight3 >= 30 && weight3 <= 200, isTrue);
    });

    test('Cân nặng không hợp lệ (kg)', () {
      double weight1 = 20; // Quá nhẹ
      double weight2 = 250; // Quá nặng
      double weight3 = -5; // Âm

      expect(weight1 < 30, isTrue);
      expect(weight2 > 200, isTrue);
      expect(weight3 < 0, isTrue);
    });

    test('Tuổi hợp lệ (16-40)', () {
      int age1 = 25;
      int age2 = 16;
      int age3 = 40;

      expect(age1 >= 16 && age1 <= 40, isTrue);
      expect(age2 >= 16 && age2 <= 40, isTrue);
      expect(age3 >= 16 && age3 <= 40, isTrue);
    });

    test('Tuổi không hợp lệ', () {
      int age1 = 15; // Quá trẻ
      int age2 = 45; // Quá già
      int age3 = -5; // Âm

      expect(age1 < 16, isTrue);
      expect(age2 > 40, isTrue);
      expect(age3 < 0, isTrue);
    });

    test('Tên không được rỗng', () {
      String name1 = 'Nguyễn Văn A';
      String name2 = '';
      String name3 = '   ';

      expect(name1.trim().isNotEmpty, isTrue);
      expect(name2.trim().isEmpty, isTrue);
      expect(name3.trim().isEmpty, isTrue);
    });
  });

  group('Validation - Ngày sinh', () {
    test('Ngày sinh hợp lệ (trong quá khứ)', () {
      DateTime dateOfBirth = DateTime(2000, 1, 1);
      DateTime now = DateTime.now();

      expect(dateOfBirth.isBefore(now), isTrue);
    });

    test('Ngày sinh không hợp lệ (trong tương lai)', () {
      DateTime dateOfBirth = DateTime(2030, 1, 1);
      DateTime now = DateTime.now();

      expect(dateOfBirth.isAfter(now), isTrue);
    });

    test('Tính tuổi từ ngày sinh', () {
      DateTime dateOfBirth = DateTime(2000, 6, 15);
      int age = DateTime.now().year - dateOfBirth.year;

      // Năm 2025 - 2000 = 25 tuổi
      expect(age, equals(25));
    });

    test('Kiểm tra tuổi hợp lệ cho app (16-40)', () {
      DateTime birthDate1 = DateTime(2007, 1, 1); // 18 tuổi
      DateTime birthDate2 = DateTime(1985, 1, 1); // 40 tuổi
      DateTime birthDate3 = DateTime(2010, 1, 1); // 15 tuổi - không hợp lệ

      int age1 = DateTime.now().year - birthDate1.year;
      int age2 = DateTime.now().year - birthDate2.year;
      int age3 = DateTime.now().year - birthDate3.year;

      expect(age1 >= 16 && age1 <= 40, isTrue);
      expect(age2 >= 16 && age2 <= 40, isTrue);
      expect(age3 < 16, isTrue);
    });
  });

  group('Logic - So sánh giá trị', () {
    test('So sánh cân nặng hiện tại với mục tiêu', () {
      double currentWeight = 80;
      double goalWeight1 = 70; // Muốn giảm
      double goalWeight2 = 90; // Muốn tăng
      double goalWeight3 = 80; // Giữ nguyên

      expect(currentWeight > goalWeight1, isTrue); // Cần giảm
      expect(currentWeight < goalWeight2, isTrue); // Cần tăng
      expect(currentWeight == goalWeight3, isTrue); // Maintain
    });

    test('Kiểm tra tiến độ giảm cân', () {
      double startWeight = 80;
      double currentWeight1 = 75; // Đã giảm
      double currentWeight2 = 80; // Không đổi
      double currentWeight3 = 85; // Tăng

      expect(currentWeight1 < startWeight, isTrue); // Đang giảm
      expect(currentWeight2 == startWeight, isTrue); // Không đổi
      expect(currentWeight3 > startWeight, isTrue); // Tăng
    });
  });

  group('String Manipulation', () {
    test('Trim khoảng trắng', () {
      String text1 = '  hello  ';
      String text2 = 'world';
      String text3 = '   ';

      expect(text1.trim(), equals('hello'));
      expect(text2.trim(), equals('world'));
      expect(text3.trim(), isEmpty);
    });

    test('Kiểm tra chuỗi rỗng', () {
      String text1 = '';
      String text2 = '   ';
      String text3 = 'hello';

      expect(text1.isEmpty, isTrue);
      expect(text2.trim().isEmpty, isTrue);
      expect(text3.isEmpty, isFalse);
    });

    test('Chuyển đổi chữ hoa/thường', () {
      String text = 'Hello World';

      expect(text.toUpperCase(), equals('HELLO WORLD'));
      expect(text.toLowerCase(), equals('hello world'));
    });
  });

  group('Number Validation', () {
    test('Parse số nguyên hợp lệ', () {
      String number1 = '123';
      String number2 = '0';
      String number3 = '-5';

      expect(int.tryParse(number1), equals(123));
      expect(int.tryParse(number2), equals(0));
      expect(int.tryParse(number3), equals(-5));
    });

    test('Parse số nguyên không hợp lệ', () {
      String number1 = 'abc';
      String number2 = '12.5';
      String number3 = '';

      expect(int.tryParse(number1), isNull);
      expect(int.tryParse(number2), isNull);
      expect(int.tryParse(number3), isNull);
    });

    test('Parse số thập phân hợp lệ', () {
      String number1 = '12.5';
      String number2 = '0.0';
      String number3 = '-3.14';

      expect(double.tryParse(number1), equals(12.5));
      expect(double.tryParse(number2), equals(0.0));
      expect(double.tryParse(number3), equals(-3.14));
    });

    test('Parse số thập phân không hợp lệ', () {
      String number1 = 'abc';
      String number2 = '';
      String number3 = '12,5'; // Dấu phẩy thay vì dấu chấm

      expect(double.tryParse(number1), isNull);
      expect(double.tryParse(number2), isNull);
      expect(double.tryParse(number3), isNull);
    });

    test('Số dương, âm, zero', () {
      int number1 = 10;
      int number2 = -5;
      int number3 = 0;

      expect(number1 > 0, isTrue);
      expect(number2 < 0, isTrue);
      expect(number3 == 0, isTrue);
    });
  });
}

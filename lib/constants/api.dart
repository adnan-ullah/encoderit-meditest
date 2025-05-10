//date
import 'app_info.dart';

final monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

final currentYear = DateTime.now().year.toString();
final monthName = monthNames[DateTime.now().month - 1];

String getMonthName(int month) {
  const monthNames = [
    '', 'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return monthNames[month];
}
List<String> getLastThreeMonthTestRequestPaths() {
  DateTime now = DateTime.now();
  List<String> paths = [];

  for (int i = 0; i < 3; i++) {
    DateTime date = DateTime(now.year, now.month - i, 1);
    String year = date.year.toString();
    String month = getMonthName(date.month);
    paths.add("$database_name/testRequest/$year/$month");
  }

  return paths;
}

List<String> getLastSixMonthTestDataPaths() {
  DateTime now = DateTime.now();
  List<String> paths = [];

  for (int i = 0; i < 6; i++) {
    DateTime date = DateTime(now.year, now.month - i, 1);
    String year = date.year.toString();
    String month = getMonthName(date.month);
    paths.add("$database_name/testModel/$year/$month");
  }
  return paths;
}

//api list
final testRequestApi = "$database_name/testRequest/$currentYear/$monthName";
final testModelApi =  "$database_name/testModel/$currentYear/$monthName";
final adminUserApi =  "$database_name/admin_user";
final categoryApi = "$database_name/category/$currentYear/$monthName";
final costApi = "$database_name/cost/$currentYear/$monthName";
final samratApi = "$database_name/samrat";
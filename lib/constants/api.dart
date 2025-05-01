//date
import 'app_info.dart';

final monthNames = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];

final currentYear = DateTime.now().year.toString();
final monthName = monthNames[DateTime.now().month - 1];

//api list
final testRequestApi = "$database_name/testRequest/$currentYear/$monthName";
final testModelApi =  "$database_name/testModel/$currentYear/$monthName";
final adminUserApi =  "$database_name/admin_user";
final categoryApi = "$database_name/category/$currentYear/$monthName";
final costApi = "$database_name/cost/$currentYear/$monthName";
final samratApi = "$database_name/samrat";
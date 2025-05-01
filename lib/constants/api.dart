//date
import 'app_info.dart';

final currentYear = DateTime.now().year.toString();
final currentMonth = DateTime.now().month.toString().padLeft(2, '0');
final apiDate = "$currentYear-$currentMonth";

//api list
final testRequestApi = "$database_name/testRequest/$apiDate";
final testModelApi =  "$database_name/testModel/$apiDate";
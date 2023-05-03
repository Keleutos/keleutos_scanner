import 'package:intl/intl.dart';

var  date_formats = [
 DateFormat.yMd("de"),
  DateFormat.yMMMd("de"),
  DateFormat.yMMMd("it"),
  DateFormat.yMMMd("fr"),
  DateFormat.yMd("it"),
  DateFormat.yMd("fr"),
];

DateTime? tryParseDate(String dateString){
  for(var format in date_formats){
    try {

      return format.parseLoose(dateString, true);
    } catch (e){

    }
  }
}
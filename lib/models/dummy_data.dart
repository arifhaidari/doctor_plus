// ignore_for_file: constant_identifier_names

import '/models/appt_model.dart';

class GlobalDummyData {
  static const List<String> BLOOD_GROUP_LIST = [
    'Blood Group',
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];
  static const List<String> GENDER_LIST = ['Male', 'Female', 'Other'];
//
  // ignore: non_constant_identifier_names
  static List<WeekDayModel> WEEK_DAY_MODEL_DATE = [
    WeekDayModel(weekDay: 'Saturday', rtlWeekDay: ''),
    WeekDayModel(weekDay: 'Sunday', rtlWeekDay: ''),
    WeekDayModel(weekDay: 'Monday', rtlWeekDay: ''),
    WeekDayModel(weekDay: 'Tuesday', rtlWeekDay: ''),
    WeekDayModel(weekDay: 'Wednesday', rtlWeekDay: ''),
    WeekDayModel(weekDay: 'Thursday', rtlWeekDay: ''),
    WeekDayModel(weekDay: 'Friday', rtlWeekDay: ''),
  ];
  //
  static const Map<String, String> CAPITUALIZE = {
    "PENDING": "Pending",
    'BOOKED': "Booked",
    "EXPIRED": "Expired",
    "COMPLETED": "Completed",
    "PATIENT_CANCELED": "Patient_Canceled",
    "DOCTOR_CANCELED": "Doctor_Canceled",
  };

  //
//   static const Map<String, String> DAYS_OF_WEEK = {
//   'Monday': 'Mon',
//   'Tuesday': 'Tue',
//   'Wednesday': 'Wed',
//   'Thursday': 'Thu',
//   'Friday': 'Fri',
//   'Saturday': 'Sat',
//   'Sunday': 'Sun',
// };
//
  static const List<String> startEndDayTime = [
    '05:00',
    '05:30',
    '06:00',
    '06:30',
    '07:00',
    '07:30',
    '08:00',
    '08:30',
    '09:00',
    '09:30',
    '10:00',
    '10:30',
    '11:00',
    '11:30',
    '12:00',
    '12:30',
    '13:00',
    '13:30',
    '14:00',
    '14:30',
    '15:00',
    '15:30',
    '16:00',
    '16:30',
    '17:00',
    '17:30',
    '18:00',
    '18:30',
    '19:00',
    '19:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '20:00',
    '20:30',
    '21:00',
    '21:30',
    '22:00',
  ];

  static const List<String> timeInMins = [
    '15',
    '20',
    '25',
    '30',
    '45',
  ];
}

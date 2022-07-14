class ClinicBriefModel {
  int? id;
  String? clinicName;
  String? rtlClinicName;
  String? timeSlotDuration;
  String? startDayTime;
  String? endDayTime;
  int? totalBookedApptNo;

  ClinicBriefModel({
    this.id,
    this.clinicName,
    this.rtlClinicName,
    this.timeSlotDuration,
    this.startDayTime,
    this.endDayTime,
    this.totalBookedApptNo,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clinic_name': clinicName,
      'rtl_clinic_name': rtlClinicName,
      'time_slot_duration': timeSlotDuration,
      'start_day_time': startDayTime,
      'end_day_time': endDayTime,
      'total_booked_appt_no': totalBookedApptNo.toString(),
    };
  }

  factory ClinicBriefModel.fromJson(Map<String, dynamic> json) {
    return ClinicBriefModel(
      id: json['id'],
      clinicName: json['clinic_name'],
      rtlClinicName: json['rtl_clinic_name'],
      timeSlotDuration: json['time_slot_duration'],
      startDayTime: json['start_day_time'],
      endDayTime: json['end_day_time'],
      totalBookedApptNo:
          json['total_booked_appt_no'] != null ? int.tryParse(json['total_booked_appt_no']) : 0,
    );
  }
}

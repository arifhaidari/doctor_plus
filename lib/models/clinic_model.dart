import 'models.dart';

class ClinicModel {
  int? id;
  String? clinicName;
  String? rtlClinicName;
  String? address;
  String? rtlAddress;
  CityModel? city;
  DistrictModel? district;
  double? latitude;
  double? longtitude;
  int? createdBy;
  bool? active;

  ClinicModel({
    this.id,
    this.clinicName,
    this.rtlClinicName,
    this.address,
    this.rtlAddress,
    this.city,
    this.district,
    this.latitude,
    this.longtitude,
    this.createdBy,
    this.active,
  });

  Map<String, dynamic> toJson() {
    return {
      'clinic_name': clinicName,
      'rtl_clinic_name': rtlClinicName,
      'address': address,
      'rtl_address': rtlAddress,
      'city': city,
      'district': district,
      'latitude': latitude,
      'longtitude': longtitude,
      'created_by': createdBy,
      'active': active,
    };
  }

  factory ClinicModel.fromJson(Map<String, dynamic> json) {
    return ClinicModel(
      id: json['id'],
      clinicName: json['clinic_name'],
      rtlClinicName: json['rtl_clinic_name'],
      address: json['address'],
      rtlAddress: json['rtl_address'],
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      district: json['district'] != null ? DistrictModel.fromJson(json['district']) : null,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude']) : null,
      longtitude: json['longtitude'] != null ? double.tryParse(json['longtitude']) : null,
      createdBy: json['created_by'],
      active: json['active'],
    );
  }
}

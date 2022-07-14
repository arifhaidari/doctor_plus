import 'package:intl/intl.dart';

import 'models.dart';

class UserModel {
  int? id;
  String? name;
  String? rtlName;
  String? phone;
  String? age;
  String? dob;
  String? avatar;
  String? gender;
  bool? active;
  AddressModel? address;

  UserModel({
    this.id,
    this.name,
    this.rtlName,
    this.phone,
    this.age,
    this.dob,
    this.avatar,
    this.gender,
    this.active,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'full_name': name,
      'rtl_full_name': rtlName,
      'phone': phone,
      'user_age': age,
      'date_of_birth': dob,
      'avatar': avatar,
      'gender': gender,
      'active': active,
      'address': address != null ? address!.toJson() : null,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['full_name'],
      rtlName: json['rtl_full_name'],
      phone: json['phone'],
      age: json['user_age'],
      dob: json['date_of_birth'] != null
          ? DateFormat("yyyy-MM-dd").format(DateTime.parse(json['date_of_birth'])).toString()
          : '',
      avatar: json['avatar'],
      gender: json['gender'],
      active: json['active'],
      address: json['address'] != null ? AddressModel.fromJson(json['address']) : null,
    );
  }
}

//

import 'dart:convert';

class AddressModel {
  int? id;
  String? address;
  String? rtlAddress;
  CityModel? city;
  DistrictModel? district;

  AddressModel({this.id, this.address, this.rtlAddress, this.city, this.district});

  Map<String, dynamic> toJson() {
    return {
      'address': address,
      'rtl_address': rtlAddress,
      'city': city != null ? CityModel.toJson(city) : null,
      'district': district != null ? DistrictModel.toJson(district) : null,
    };
  }

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: json['id'],
      address: json['address'],
      rtlAddress: json['rtl_address'],
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
      district: json['district'] != null ? DistrictModel.fromJson(json['district']) : null,
    );
  }
}

// City Model
class CityModel {
  int? id;
  String? name;
  String? rtlName;

  CityModel({this.id, this.name, this.rtlName});

  static Map<String, dynamic> toJson(CityModel? city) {
    print('value of city in model');
    print(city!.name);
    return {
      'id': city.id,
      'name': city.name,
      'rtl_name': city.rtlName,
    };
  }

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(id: json['id'], name: json['name'], rtlName: json['rtl_name']);
  }

// these two last function is for storing and fetching from sharedprefernces
  static String encode(List<CityModel> cities) => json.encode(
        cities.map<Map<String, dynamic>>((city) => CityModel.toJson(city)).toList(),
      );

  static List<CityModel> decode(String cities) => (json.decode(cities) as List<dynamic>)
      .map<CityModel>((item) => CityModel.fromJson(item))
      .toList();
}

// District Model
class DistrictModel {
  int? id;
  String? name;
  String? rtlName;
  CityModel? city;

  DistrictModel({this.id, this.name, this.rtlName, this.city});

  static Map<String, dynamic> toJson(DistrictModel? districtModel) {
    return {
      'id': districtModel!.id,
      'name': districtModel.name,
      'rtl_name': districtModel.rtlName,
      'city': districtModel.city != null ? CityModel.toJson(districtModel.city) : null,
    };
  }

  factory DistrictModel.fromJson(Map<String, dynamic> json) {
    return DistrictModel(
      id: json['id'],
      name: json['name'],
      rtlName: json['rtl_name'],
      city: json['city'] != null ? CityModel.fromJson(json['city']) : null,
    );
  }

  // these two last function is for storing and fetching from sharedprefernces
  static String encode(List<DistrictModel> districts) => json.encode(
        districts.map<Map<String, dynamic>>((district) => DistrictModel.toJson(district)).toList(),
      );

  static List<DistrictModel> decode(String districts) => (json.decode(districts) as List<dynamic>)
      .map<DistrictModel>((item) => DistrictModel.fromJson(item))
      .toList();
}

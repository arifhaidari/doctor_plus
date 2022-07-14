// import 'package:flutter/material.dart';
import 'dart:async';

import '../../models/models.dart';
import '../../providers/provider_list.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: non_constant_identifier_names
List<CityModel> CITIES = <CityModel>[];
// List<DistrictModel> DISTRICTS = <DistrictModel>[]; // this is too much data to be in the cache

class SetAddressCache {
  // Future<void> clearAddressCache() async {
  //   final SharedPreferences pref = await SharedPreferences.getInstance();
  //   pref.remove('cities');
  //   // pref.remove('districts');
  // }

  Future<void> getCities() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      if (!pref.containsKey('cities')) {
        return;
      }
      final String? decodedCities = pref.getString('cities');
      CITIES = CityModel.decode(decodedCities!);
    } catch (error) {
      return;
    }
  }

  Future<void> setCities() async {
    try {
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey('cities')) {
        pref.remove('cities');
      }
      List<CityModel> cityList = <CityModel>[];

      final _findDoctorPageData = await HttpService().getRequest(endPoint: CITY_URL);

      if (!_findDoctorPageData.error) {
        try {
          if (_findDoctorPageData.data is List) {
            if (_findDoctorPageData.data.length > 0) {
              _findDoctorPageData.data.forEach((response) {
                final theObject = CityModel.fromJson(response);
                cityList.add(theObject);
              });
            }
          }
        } catch (e) {
          return;
        }
      } else {
        return;
      }
      if (cityList.isNotEmpty) {
        final String encodedCities = CityModel.encode(cityList);
        pref.setString('cities', encodedCities);
      }
      // ignore: empty_catches
    } catch (error) {}
  }
}

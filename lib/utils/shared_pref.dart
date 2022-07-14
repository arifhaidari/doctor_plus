// import 'package:flutter/material.dart';
import 'dart:async';
import '../providers/provider_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// ignore: non_constant_identifier_names
Map<String, dynamic> DRAWER_DATA = {
  // 'avatar': null,
};

class SharedPref {
  Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    // pref.remove('user_credential');
    // pref.clear(); // clear all the cache which is not good practice
    pref.remove('token');
    pref.remove('dashboard_brief');
    DRAWER_DATA = {};
  }

  Future<Map<String, dynamic>> dashboardBrief() async {
    try {
      final pref = await SharedPreferences.getInstance();
      if (!pref.containsKey('dashboard_brief')) {
        return {};
      }
      final extractedDashBrief =
          json.decode(pref.getString('dashboard_brief')!) as Map<String, dynamic>;
      // print(extractedDashBrief['full_name']);
      return extractedDashBrief;
    } catch (error) {
      return {};
    }
  }

  Future<void> dashboardBriefSetter(Map<String, dynamic> theMap) async {
    try {
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey('dashboard_brief')) {
        pref.remove('dashboard_brief');
      }
      final organizedMap = json.encode({
        "id": theMap['id'].toString(),
        "full_name": theMap['full_name'],
        "share_record_to_all": theMap['share_record_to_all'],
        "phone": theMap['phone'],
        "gender": theMap['gender'],
        "rtl_full_name": theMap['rtl_full_name'],
        "avatar": theMap['avatar'],
        "city": theMap['city'],
        "district": theMap['district'],
        "patient_completed_appt_no": theMap['patient_completed_appt_no'].toString(),
        "relative_completed_appt_no": theMap['relative_completed_appt_no'].toString(),
      });
      pref.setString('dashboard_brief', organizedMap);
      // set value of city

      initialize(); //initialize value of user
      SetAddressCache().getCities(); // initialize cities

    } catch (error) {
      return;
    }
  }

  void initialize() async {
    await dashboardBrief().then((value) {
      DRAWER_DATA['id'] = value['id'];
      DRAWER_DATA['full_name'] = value['full_name'];
      DRAWER_DATA['rtl_full_name'] = value['rtl_full_name'];
      DRAWER_DATA['share_record_to_all'] = value['share_record_to_all'];
      DRAWER_DATA['phone'] = value['phone'];
      DRAWER_DATA['avatar'] = value['avatar'];
      DRAWER_DATA['city'] = value['city'];
      DRAWER_DATA['district'] = value['district'];
      DRAWER_DATA['gender'] = value['gender'];
      DRAWER_DATA['patient_completed_appt_no'] = value['patient_completed_appt_no'];
      DRAWER_DATA['relative_completed_appt_no'] = value['relative_completed_appt_no'];
    });
  }

  Future<String?> getToken() async {
    // return '';
    try {
      final pref = await SharedPreferences.getInstance();
      if (!pref.containsKey('token')) {
        return '';
      }
      final extractedToken = pref.getString('token');
      return extractedToken;
    } catch (error) {
      //
      return '';
    }
  }

  Future<void> setToken(String token) async {
    try {
      final pref = await SharedPreferences.getInstance();
      if (pref.containsKey('token')) {
        pref.remove('token');
      }
      pref.setString('token', token);
    } catch (error) {
      return;
    }
  }
}

import 'dart:io';

import 'package:dio/dio.dart';
import '../../utils/shared_pref.dart';
import '../providers/provider_list.dart';
// import '../utils/utils.dart';
// import 'package:flutter/material.dart';

class HttpService {
  Function(double)? uploadProgressCallBack;

  // HttpService({this.context, this.uploadProgressCallBack}) {
  //   initializeInterceptors();
  // }

  final Dio _dio = Dio(
    BaseOptions(
        // connectTimeout: 5000,
        // headers: ,
        // baseUrl: BASE_URL,
        ),
  );

  _isConnected() async {
    // return false;
    try {
      await InternetAddress.lookup(CONNECTIVITY_ENDPOINT);
      return true;
    } on SocketException catch (e) {
      return false;
    }
  }

  Future<APIResponse> getRequest(
      {required String endPoint, Map<String, dynamic>? queryMap, bool isAuth = true}) async {
    Response response;
    final theToken = await SharedPref().getToken();
    try {
      response = await _dio.get(endPoint,
          queryParameters: queryMap,
          options: Options(
            headers: {
              "Content-Type": "application/json",
              if (isAuth) "Authorization": "Bearer " + theToken.toString(),
            },
            validateStatus: (status) {
              return status! < 500;
            },
          ));
      return _serverResponse(response);
    } on DioError catch (e) {
      bool checkConnection = await _isConnected();
      if (!checkConnection) {
        return APIResponse(error: true, errorMessage: NO_INTERNET_CONNECTION);
      }
      return APIResponse(error: true, errorMessage: e.error.toString());
      // throw Exception(e.message);
    }
  }

  Future<APIResponse> postRequest(
      {required String endPoint,
      required dynamic data,
      Map<String, dynamic>? queryMap,
      bool isSendProgress = false,
      bool isAuth = true}) async {
    Response response;
    final theToken = await SharedPref().getToken();

    try {
      response = await _dio.post(
        endPoint,
        queryParameters: queryMap,
        data: data,
        onSendProgress: isSendProgress
            ? (count, total) {
                // count is the sent bytes
                // total is the total bytes
                // uploadProgressPercentage(int sentBytes, int totalBytes)
                uploadProgressPercentage(count, total);
              }
            : null,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            if (isAuth) "Authorization": "Bearer " + theToken.toString(),
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return _serverResponse(response);
    } on DioError catch (e) {
      bool checkConnection = await _isConnected();
      if (!checkConnection) {
        return APIResponse(error: true, errorMessage: NO_INTERNET_CONNECTION);
      }
      return APIResponse(error: true, errorMessage: e.error.toString());
    }
  }

  Future<APIResponse> patchRequest(
      {required String endPoint, required dynamic data, bool isAuth = true}) async {
    Response response;
    final theToken = await SharedPref().getToken();
    //
    try {
      response = await _dio.patch(
        endPoint,
        data: data,
        onSendProgress: (count, total) {
          uploadProgressPercentage(count, total);
        },
        options: Options(
          headers: {
            "Content-Type": "application/json",
            if (isAuth) "Authorization": "Bearer " + theToken.toString(),
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return _serverResponse(response);
    } on DioError catch (e) {
      bool checkConnection = await _isConnected();
      if (!checkConnection) {
        return APIResponse(error: true, errorMessage: NO_INTERNET_CONNECTION);
      }
      return APIResponse(error: true, errorMessage: e.error.toString());
    }
  }

  Future<APIResponse> deleteRequest(
      {required String endPoint, dynamic data, bool isAuth = true}) async {
    Response response;
    final theToken = await SharedPref().getToken();
    //
    try {
      response = await _dio.delete(
        endPoint,
        data: data,
        options: Options(
          headers: {
            "Content-Type": "application/json",
            if (isAuth) "Authorization": "Bearer " + theToken.toString(),
          },
          validateStatus: (status) {
            return status! < 500;
          },
        ),
      );
      return APIResponse(data: response.data);
    } on DioError catch (e) {
      bool checkConnection = await _isConnected();
      if (!checkConnection) {
        return APIResponse(error: true, errorMessage: NO_INTERNET_CONNECTION);
      }
      return APIResponse(error: true, errorMessage: e.error.toString());
    }
    // return response;
  }

  // initializeInterceptors() {
  //   print('insdie the initializeInterceptors');
  //   _dio.interceptors.add(InterceptorsWrapper(
  //     onError: (e, handler) {
  //       print('on errro-----');
  //       print(e);
  //       print(handler);
  //     },
  //     onRequest: (options, handler) {
  //       print('on request-----');
  //       print(options);
  //       print(handler);
  //     },
  //     onResponse: (e, handler) {
  //       print('on response');
  //       print(e.data);
  //       print('////////');
  //       print(e.extra);
  //       print('////////');
  //       print(handler);
  //     },
  //   ));
  // }

  APIResponse _serverResponse(Response response) {
    // 405 not allowed
    // 404 not found
    if (response.statusCode! >= 200 && response.statusCode! <= 204) {
      return APIResponse(data: response.data);
    } else if (response.statusCode! >= 400 &&
        response.statusCode! < 500 &&
        response.statusCode! != 404 &&
        response.statusCode! != 405) {
      return _checkMapError(response.data);
    } else if (response.statusCode == 404) {
      return APIResponse(error: true, errorMessage: 'Contact for support');
    } else if (response.statusCode == 405) {
      return APIResponse(error: true, errorMessage: 'You are not permitted to request this');
    } else if (response.statusCode! > 405 && response.statusCode! < 500) {
      return APIResponse(error: true, errorMessage: 'There is issue with your connection');
    } else if (response.statusCode == 500) {
      return APIResponse(
          error: true, errorMessage: 'Server is not responding. Contact for support');
    }
    return APIResponse(error: true, errorMessage: 'Unknown error occured. Contact for support');
  }

  APIResponse _checkMapError(var data) {
    if (data is Map) {
      if (data['errors'] != null) {
        return APIResponse(data: null, error: true, errorMessage: data['errors']);
      } else {
        String error = "";
        String tokenExpired = "no_code";
        data.forEach((key, value) {
          if (key == 'code' && value == 'token_not_valid' || value == 'bad_authorization_header') {
            tokenExpired = value.toString();
          }

          error = error + (value is List ? value[0].toString() : value.toString()) + "\n";
        });
        if (tokenExpired != 'no_code') {
          return APIResponse(error: true, errorMessage: tokenExpired);
        }
        return APIResponse(error: true, errorMessage: error);
      }
    } else if (data is String) {
      return APIResponse(error: true, errorMessage: data);
    } else if (data is List) {
      if (data.isNotEmpty) {
        String errorText = '';
        for (var element in data) {
          errorText = errorText + element.toString() + "\n";
        }
        return APIResponse(error: true, errorMessage: errorText);
      }
    }
    try {
      return APIResponse(error: true, errorMessage: data.toString());
    } catch (error) {
      return APIResponse(error: true, errorMessage: 'Unknown error occurred. Please try again');
    }
  }
}

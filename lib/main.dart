import 'pages/screens.dart';
import 'utils/utils.dart';

import './utils/shared_pref.dart';
import 'package:flutter/material.dart';
import 'providers/provider_list.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print('the genderal gesture is tapped');
        FocusScope.of(context).requestFocus(FocusNode());

        // FocusScopeNode currentFocus = FocusScope.of(context);
        // if (!currentFocus.hasPrimaryFocus) {
        //   currentFocus.unfocus();
        // }
      },
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Doctor Plus',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder(
          future: SharedPref().getToken(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const StartSplashScreen();
            }
            if (snapshot.hasError) {
              return const ErrorPlaceHolderPage(
                  isStartPage: true,
                  errorDetail: 'Check your internet connection and try again',
                  errorTitle: 'Uknown Error');
            }
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                if (snapshot.data == '') {
                  return const SignupLogin();
                }
              }
            }
            return FutureBuilder(
              future: HttpService().getRequest(endPoint: USER_BASIC_INFO, isAuth: true),
              builder: (context, AsyncSnapshot<APIResponse> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const StartSplashScreen();
                }
                if (snapshot.hasError) {
                  return const ErrorPlaceHolderPage(
                      isStartPage: true,
                      errorDetail: 'Check your internet connection and try again',
                      errorTitle: 'Uknown Error');
                }
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.error) {
                      if (snapshot.data!.errorMessage == NO_INTERNET_CONNECTION) {
                        return const ErrorPlaceHolderPage(
                            isStartPage: true,
                            errorDetail:
                                'You have no internet connect. Turn on your data or connect to a wifi',
                            errorTitle: 'Internet Connection Error');
                      }
                      if (snapshot.data!.errorMessage == 'bad_authorization_header' ||
                          snapshot.data!.errorMessage == 'token_not_valid') {
                        return const SignupLogin();
                      } else {
                        return ErrorPlaceHolderPage(
                          isStartPage: true,
                          errorDetail: snapshot.data!.errorMessage.toString(),
                          errorTitle: 'System Error',
                        );
                      }
                    }
                  }
                }
                SharedPref().dashboardBriefSetter(snapshot.data!.data);
                return const NavScreen();
              },
            );
          },
        ),
      ),
    );
  }
}

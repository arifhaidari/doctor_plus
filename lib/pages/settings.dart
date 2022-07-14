// import '../models/models.dart';
// import '../providers/provider_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../utils/utils.dart';
import '../pages/screens.dart';

class Settings extends StatelessWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: myAppBar('Settings'),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _settingCard(
              context,
              'Change Password',
              'Make sure you remember your current password',
              CupertinoIcons.lock,
              'change_password',
            ),
          ],
        ),
      ),
    );
  }

  Card _settingCard(
      BuildContext context, String title, String sub, IconData icon, String operation) {
    return Card(
      color: Palette.imageBackground,
      margin: const EdgeInsets.only(top: 10, right: 15, left: 15),
      elevation: 5,
      child: ListTile(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ChangePassword(
                        operation: 'change_password',
                      )));
        },
        leading: Icon(
          icon,
          size: 35,
          color: Palette.blueAppBar,
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          sub,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}

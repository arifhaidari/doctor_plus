import 'package:dio/dio.dart';
import '../../providers/provider_list.dart';
import '../../utils/utils.dart';
import 'package:flutter/material.dart';
import '../../widgets/widgets.dart';
import '../screens.dart';

class ChangePassword extends StatefulWidget {
  final String operation;
  final String phone;

  const ChangePassword({Key? key, required this.operation, this.phone = ''}) : super(key: key);
  @override
  _ChangePasswordState createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();
  final _oldPassController = TextEditingController();
  final _newPassController = TextEditingController();
  final _newPassConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phoneNumberController.text = widget.phone;
  }

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar(
          widget.operation != 'forget_password' ? 'Change Password' : 'Create New Password'),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                margin: const EdgeInsets.only(top: 10),
                elevation: 5.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: mQuery.width * 0.90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: mQuery.width * 0.75,
                          height: 50.0,
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: textFieldDesign(context, 'Phone Number'),
                          ),
                        ),
                        if (widget.operation != 'forget_password')
                          Container(
                            margin: const EdgeInsets.only(top: 15),
                            width: mQuery.width * 0.75,
                            height: 50.0,
                            child: TextFormField(
                              controller: _oldPassController,
                              decoration: textFieldDesign(context, 'Old Password'),
                            ),
                          ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: mQuery.width * 0.75,
                          height: 50.0,
                          child: TextFormField(
                            controller: _newPassController,
                            decoration: textFieldDesign(context, 'New Password'),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: mQuery.width * 0.75,
                          height: 50.0,
                          child: TextFormField(
                            controller: _newPassConfirmController,
                            decoration: textFieldDesign(context, 'Confirm New Password'),
                          ),
                        ),
                        if (_errorMessage != '')
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: mQuery.width * 0.90,
                            padding: const EdgeInsets.symmetric(horizontal: 25),
                            child: Text(
                              _errorMessage,
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w500, color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(
                          height: 15,
                        ),
                        customElevatedButton(
                            context, () => _updateNewPass(context), 'Save Changes'),
                        const SizedBox(
                          height: 8.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateNewPass(BuildContext ctx) async {
    bool _isDialogRunning = false;
    final isFormValid = _formValidation();

    if (!isFormValid) {
      return;
    }
    showDialog(
        context: ctx,
        barrierDismissible: false,
        builder: (_) {
          _isDialogRunning = true;
          return const ProgressPopupDialog();
        });
    try {
      FormData body = FormData.fromMap({
        'phone_number': _phoneNumberController.text,
        'new_pass': _newPassController.text,
        'old_pass':
            widget.operation != 'forget_password' ? _oldPassController.text : widget.operation,
      });

      var passResponse = await HttpService().postRequest(
          data: body,
          endPoint: CHANGE_PASS,
          isAuth: widget.operation == 'forget_password' ? false : true);

      Navigator.of(ctx).pop();
      _isDialogRunning = false;

      if (!passResponse.error) {
        if (passResponse.data['message'] == 'success') {
          if (widget.operation == 'forget_password') {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SignupLogin()));
          }

          toastSnackBar('Password has been changed successfully');
        } else {
          if (passResponse.data['message'] == 'no_match') {
            infoNoOkDialogue(context, 'Old password does not match, please try again',
                'Password Does Not Match');
          } else {
            infoNoOkDialogue(
                context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
          }
        }
      } else {
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } catch (e) {
      _isDialogRunning ? Navigator.of(ctx).pop() : null;
      infoNoOkDialogue(
          context, GlobalVariable.CATCH_PROCESS_NOT_SUCCESS, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
    //
  }

  bool _formValidation() {
    print('valueo ffo in form validation ');
    _theSetState('');
    if (_phoneNumberController.text.trim() == '') {
      _theSetState('Please enter phone number');
      return false;
    }

    if (!isNumeric(_phoneNumberController.text)) {
      _theSetState('Phone number should be digits not letters or special characters');
      return false;
    }

    // if (int.tryParse(_phoneNumberController.text) == null) {
    //   _theSetState('Please enter valid phone number');
    //   return false;
    // }

    if (_oldPassController.text.trim() == '' && widget.operation != 'forget_password') {
      _theSetState('Please enter old password');
      return false;
    }
    if (_newPassController.text.trim() == '') {
      _theSetState('Please enter new password');
      return false;
    }

    if (_newPassConfirmController.text.trim() == '') {
      _theSetState('Please enter new password confirmation');
      return false;
    }
    if (_newPassController.text != _newPassConfirmController.text) {
      _theSetState('New passwords do not match');
      return false;
    }

    if (_phoneNumberController.text.length < 10 || _phoneNumberController.text.length > 10) {
      _theSetState('Phone number is not valid, should be 10 digits');
      return false;
    }

    if ((_oldPassController.text.length < 6 || _oldPassController.text.length > 20) &&
        widget.operation != 'forget_password') {
      _theSetState(
          'Old password should not be less than 6 or greater than 20 characters or digits');
      return false;
    }

    if (_newPassController.text.length < 6 || _newPassController.text.length > 20) {
      _theSetState(
          'New password should not be less than 6 or greater than 20 characters or digits');
      return false;
    }
    return true;
  }

  void _theSetState(String theMessage) {
    setState(() {
      _errorMessage = theMessage;
    });
  }
}

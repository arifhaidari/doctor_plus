import 'package:flutter/material.dart';
import '../utils/utils.dart';

class ForgetPassword extends StatefulWidget {
  const ForgetPassword({Key? key}) : super(key: key);

  @override
  _ForgetPasswordState createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  String _errorMessage = '';
  final _formKey = GlobalKey<FormState>();
  final _phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final mQuery = MediaQuery.of(context).size;
    return Scaffold(
      appBar: myAppBar('Forget Password'),
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
                          child: const Text(
                            'Enter your phone number to recover your account. We will send you an OTP to your phone number that you have registered with',
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 15),
                          width: mQuery.width * 0.75,
                          height: 50.0,
                          child: TextFormField(
                            controller: _phoneNumberController,
                            keyboardType: TextInputType.phone,
                            decoration: textFieldDesign(context, 'Phone (07XXXXXXX)'),
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
                        customElevatedButton(context, () {
                          final isFormValid = _formValidation();
                          if (isFormValid) {
                            createOTP(context, _phoneNumberController.text, 'forget_password');
                          }
                        }, 'Submit'),
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

  // Future<void> _forgetPass(BuildContext context) async {
  //   final isFormValid = _formValidation();

  //   if (!isFormValid) {
  //     return;
  //   }

  //   FormData body = FormData.fromMap({
  //     'phone_otp': _phoneNumberController.text,
  //     'the_round': 'create_round',
  //     'operation': 'forget_password',
  //   });
  //   var otpResponse = await HttpService().postRequest(data: body, endPoint: OPT_VERIFICATION);

  //   try {
  //     if (!otpResponse.error) {
  //       if (otpResponse.data['message'] == 'success') {
  //         Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (_) => VerifyOtp(
  //                       phone: _phoneNumberController.text,
  //                       operation: 'forget_password',
  //                     )));
  //       } else {
  //         if (otpResponse.data['message'] == 'field_error') {
  //           infoNoOkDialogue(context, 'Enter your data properly and try again', 'Data Entry Error');
  //         } else if (otpResponse.data['message'] == 'no_account') {
  //           infoNoOkDialogue(
  //               context,
  //               'There is no account registered by this phone number. Please Enter your registered number',
  //               'Account Unavailable');
  //         } else {
  //           infoNoOkDialogue(
  //               context, 'Unexpected error occured. Please try again', 'Error Occured !!!');
  //         }
  //       }
  //     } else {
  //       infoNoOkDialogue(context, otpResponse.errorMessage.toString(), 'Unknown Error');
  //     }
  //   } catch (e) {
  //     infoNoOkDialogue(
  //         context, 'The process was NOT successful. Please try again', 'Unknown Error');
  //   }
  //   //
  // }

  bool _formValidation() {
    _theSetState('');
    if (_phoneNumberController.text.trim() == '') {
      _theSetState('Please enter phone number');
      return false;
    }

    if (!isNumeric(_phoneNumberController.text)) {
      _theSetState('Phone number should be digits not letters or special characters');
      return false;
    }

    if (_phoneNumberController.text.length < 10 || _phoneNumberController.text.length > 10) {
      _theSetState('Phone number is not valid, should be 10 digits');
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

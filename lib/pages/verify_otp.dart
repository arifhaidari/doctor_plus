import 'dart:async';
import 'dart:io';
// import 'package:flutter/gestures.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../pages/screens.dart';
import '../../providers/provider_list.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../utils/utils.dart';
// import './constants/constants.dart';

class VerifyOtp extends StatefulWidget {
  final String phone;
  final String operation;

  const VerifyOtp({Key? key, required this.phone, this.operation = 'verify'}) : super(key: key);

  @override
  _VerifyOtpState createState() => _VerifyOtpState();
}

class _VerifyOtpState extends State<VerifyOtp> {
  TextEditingController textEditingController = TextEditingController();
  // ..text = "123456";

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  bool _isProcessing = false;
  String currentText = "";
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalVariable.PRIMARY_COLOR,
      appBar: AppBar(
        backgroundColor: GlobalVariable.PRIMARY_COLOR,
        leading: IconButton(
          icon: Icon(
            Platform.isAndroid ? Icons.arrow_back : Icons.arrow_back_ios,
            color: Colors.blue[900],
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () {},
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset(GlobalVariable.OTP_GIF_IMAGE),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'Phone Number Verification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: TextSpan(
                      text: "Enter the code sent to ",
                      children: [
                        TextSpan(
                            text: widget.phone,
                            style: const TextStyle(
                                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
                      ],
                      style: const TextStyle(color: Colors.black54, fontSize: 15)),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30),
                    child: PinCodeTextField(
                      appContext: context,
                      pastedTextStyle: const TextStyle(
                        color: Palette.imageBackground,
                        fontWeight: FontWeight.bold,
                      ),
                      length: 6,
                      obscureText: true,
                      obscuringCharacter: '*',
                      // obscuringWidget: FlutterLogo(
                      //   size: 24,
                      // ),
                      blinkWhenObscuring: true,
                      animationType: AnimationType.fade,
                      // validator: (v) {
                      //   if (v!.length < 6) {
                      //     return "I'm from validator";
                      //   } else {
                      //     return null;
                      //   }
                      // },
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: hasError ? Colors.blue.shade100 : Colors.white,
                      ),
                      cursorColor: Colors.black,
                      animationDuration: const Duration(milliseconds: 300),
                      enableActiveFill: true,
                      errorAnimationController: errorController,
                      controller: textEditingController,
                      keyboardType: TextInputType.number,
                      boxShadows: const [
                        BoxShadow(
                          offset: Offset(0, 1),
                          color: Colors.black12,
                          blurRadius: 10,
                        )
                      ],
                      onCompleted: (v) {},
                      // onTap: () {
                      //   print("Pressed");
                      // },
                      onChanged: (value) {
                        setState(() {
                          currentText = value;
                        });
                      },
                      beforeTextPaste: (text) {
                        // print("Allowing to paste $text");
                        //if you return true then it will show the paste confirmation dialog. Otherwise if false, then nothing will happen.
                        //but you can show anything you want here, like your pop up saying wrong paste format or etc
                        return true;
                      },
                    )),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasError ? "*Please fill up all the cells properly" : "",
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w400),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  TextButton(
                      onPressed: () => toastSnackBar('OTP resend'),
                      child: const Text(
                        "RESEND",
                        style: TextStyle(
                            color: Palette.blueAppBar, fontWeight: FontWeight.bold, fontSize: 16),
                      ))
                ],
              ),
              const SizedBox(
                height: 7,
              ),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30),
                child: ButtonTheme(
                  height: 50,
                  child: TextButton(
                    onPressed: () => _verifyThePhone(),
                    child: Center(
                      child: _isProcessing
                          ? const CircularProgressIndicator()
                          : Text(
                              widget.operation == 'verify'
                                  ? "VERIFY".toUpperCase()
                                  : 'Recover Password',
                              // "VERIFY".toUpperCase(),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Palette.blueAppBar,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.green.shade200, offset: const Offset(1, -2), blurRadius: 5),
                      BoxShadow(
                          color: Colors.green.shade200, offset: const Offset(-1, 2), blurRadius: 5)
                    ]),
              ),
              TextButton(
                child: const Text(
                  "Clear",
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w500, color: Palette.blueAppBar),
                ),
                onPressed: () {
                  textEditingController.clear();
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  void _verifyThePhone() async {
    setState(() {
      _isProcessing = true;
    });
    formKey.currentState!.validate();

    FormData body = FormData.fromMap({
      'phone_otp': currentText,
      'the_round': 'receive_round',
      'operation': widget.operation,
    });
    var otpResponse =
        await HttpService().postRequest(data: body, endPoint: OPT_VERIFICATION, isAuth: false);

    if (!otpResponse.error) {
      try {
        if (otpResponse.data['message'] == 'success') {
          setState(() {
            _isProcessing = false;
          });
          // navigate to login page
          if (widget.operation == 'verify') {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => const SignupLogin()));
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => ChangePassword(
                          operation: 'forget_password',
                          phone: widget.phone,
                        )));
          }
          toastSnackBar('OTP matched Successfully');
        } else {
          errorController!.add(ErrorAnimationType.shake); // Triggering error shake animation

          if (otpResponse.data['message'] == 'expired' ||
              otpResponse.data['message'] == 'not_exist') {
            infoNoOkDialogue(
                context, 'OTP is expired, please request for a new one', 'OTP Expired');
          } else {
            infoNoOkDialogue(
                context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
          }
        }
      } catch (e) {
        setState(() {
          _isProcessing = false;
        });
        infoNoOkDialogue(
            context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
      }
    } else {
      setState(() {
        _isProcessing = false;
      });
      infoNoOkDialogue(
          context, GlobalVariable.UNEXPECTED_ERROR, GlobalVariable.ERROR_MESSAGE_TITLE);
    }
  }
}

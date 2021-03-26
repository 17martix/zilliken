import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zilliken/Components/ZRaisedButton.dart';
import 'package:zilliken/Components/ZTextField.dart';
import 'package:zilliken/Helpers/Utils.dart';
import 'package:zilliken/Models/Fields.dart';
import 'package:zilliken/Models/UserProfile.dart';
import 'package:zilliken/Pages/DashboardPage.dart';
import 'package:zilliken/i18n.dart';
import 'package:zilliken/Services/Authentication.dart';
import 'package:zilliken/Services/Database.dart';
import 'package:zilliken/Services/Messaging.dart';
import 'package:zilliken/Helpers/Styling.dart';
import 'package:zilliken/Helpers/SizeConfig.dart';

import 'package:pinput/pin_put/pin_put.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  final Authentication auth;
  final Database db;
  final Messaging messaging;
  final User user;

  LoginPage({
    @required this.auth,
    @required this.db,
    @required this.messaging,
    this.user,
  });

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  int _pageState = 0;

  String _selectedAreaCode = '+257';

  double _xOffset1 = 0;
  double _xOffset2 = 0;
  double _xOffset3 = 0;

  final _pinPutController = TextEditingController();
  final _pinPutFocusNode = FocusNode();

  GlobalKey<FormState> _pinKey = GlobalKey<FormState>();
  GlobalKey<FormState> _phoneKey = GlobalKey<FormState>();
  GlobalKey<FormState> _nameKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _verificationcode;

  String _phoneNumber;
  User _firebaseUser;

  String _name;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final node = FocusScope.of(context);
    switch (_pageState) {
      case 0:
        setState(() {
          _xOffset1 = SizeConfig.safeBlockHorizontal * 0;
          _xOffset2 = SizeConfig.safeBlockHorizontal * 100;
          _xOffset3 = SizeConfig.safeBlockHorizontal * 100;
        });
        break;
      case 1:
        setState(() {
          _xOffset1 = SizeConfig.safeBlockHorizontal * -100;
          _xOffset2 = SizeConfig.safeBlockHorizontal * 0;
          _xOffset3 = SizeConfig.safeBlockHorizontal * 100;
        });
        break;
      case 2:
        setState(() {
          _xOffset1 = SizeConfig.safeBlockHorizontal * -100;
          _xOffset2 = SizeConfig.safeBlockHorizontal * -100;
          _xOffset3 = SizeConfig.safeBlockHorizontal * 0;
        });
    }

    /*return Scaffold(
      key: _scaffoldKey,
      body: Center(
        child: SingleChildScrollView(
          child: Stack(
            children: [Text('hello')],
          ),
        ),
      ),
    );*/

    return Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/Zilliken.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.white.withOpacity(0.3),
          child: Center(
            child: SingleChildScrollView(
              child: Stack(
                children: <Widget>[
                  InkWell(
                    onTap: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                    },
                    child: AnimatedContainer(
                      curve: Curves.easeInBack,
                      duration: Duration(milliseconds: 1000),
                      transform: Matrix4.translationValues(_xOffset1, 0, 1),
                      child: Center(
                        child: Card(
                          color: Color(Styling.primaryBackgroundColor)
                              .withOpacity(0.9),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.diagonal * 7)),
                          child: Padding(
                            padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: SizeConfig.diagonal * 10,
                                  height: SizeConfig.diagonal * 10,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                    image: AssetImage('assets/logo.png'),
                                    fit: BoxFit.cover,
                                  )),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      bottom: SizeConfig.diagonal * 6),
                                  child: Text(
                                    I18n.of(context)
                                        .createaccount
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Color(Styling.accentColor),
                                      fontSize: SizeConfig.diagonal * 2,
                                      fontStyle: FontStyle.normal,
                                    ),
                                  ),
                                ),
                                Form(
                                  key: _phoneKey,
                                  child: ZTextField(
                                    prefix: Text(_selectedAreaCode),
                                    hint: I18n.of(context).yourphonenumber,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onFieldSubmitted: (String value) =>
                                        sendCode(),
                                    onSaved: (newValue) =>
                                        _phoneNumber = newValue,
                                    validator: (value) => value.isEmpty
                                        ? I18n.of(context).requiredInput
                                        : null,
                                  ),
                                ),
                                ZRaisedButton(
                                  onpressed: sendCode,
                                  textIcon: Text(
                                    I18n.of(context).signin,
                                    style: TextStyle(
                                      color:
                                          Color(Styling.primaryBackgroundColor),
                                      fontSize: SizeConfig.diagonal * 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    curve: Curves.easeInBack,
                    duration: Duration(milliseconds: 1000),
                    transform: Matrix4.translationValues(_xOffset2, 0, 1),
                    child: Card(
                      color: Color(Styling.primaryBackgroundColor)
                          .withOpacity(0.9),
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(SizeConfig.diagonal * 7)),
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Container(
                              width: SizeConfig.diagonal * 10,
                              height: SizeConfig.diagonal * 10,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                image: AssetImage('assets/logo.png'),
                                fit: BoxFit.cover,
                              )),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  bottom: SizeConfig.diagonal * 5),
                              child: Text(
                                I18n.of(context).smscode.toUpperCase(),
                                style: TextStyle(
                                  color: Color(Styling.accentColor),
                                  fontSize: SizeConfig.diagonal * 3,
                                  fontStyle: FontStyle.normal,
                                ),
                              ),
                            ),
                            Form(
                              key: _pinKey,
                              child: PinPut(
                                eachFieldWidth: SizeConfig.diagonal * 1,
                                eachFieldHeight: SizeConfig.diagonal * 1,
                                textInputAction: TextInputAction.go,
                                /*onSubmit: (String value) =>
                                      confirmSMSCode(value),*/
                                withCursor: false,
                                fieldsCount: 6,
                                focusNode: _pinPutFocusNode,
                                controller: _pinPutController,
                                submittedFieldDecoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Color(Styling.iconColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                selectedFieldDecoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Color(Styling.primaryBackgroundColor),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                followingFieldDecoration: BoxDecoration(
                                  border: Border.all(),
                                  color: Color(Styling.primaryBackgroundColor),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                pinAnimationType: PinAnimationType.scale,
                                textStyle: TextStyle(
                                    color: Color(Styling.primaryDarkColor),
                                    fontSize: SizeConfig.diagonal * 3),
                              ),
                            ),
                            SizedBox(
                              height: SizeConfig.diagonal * 1,
                            ),
                            ZRaisedButton(
                              color: Color(Styling.accentColor),
                              textIcon: Text(
                                I18n.of(context).confirm,
                                style: TextStyle(
                                    color:
                                        Color(Styling.primaryBackgroundColor)),
                              ),
                              onpressed: () =>
                                  confirmSMSCode(_pinPutController.text),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    curve: Curves.easeInBack,
                    duration: Duration(milliseconds: 1000),
                    transform: Matrix4.translationValues(_xOffset3, 0, 1),
                    child: Center(
                      child: Card(
                        color: Color(Styling.primaryBackgroundColor)
                            .withOpacity(0.9),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(SizeConfig.diagonal * 7)),
                        child: Padding(
                          padding: EdgeInsets.all(SizeConfig.diagonal * 1),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: SizeConfig.diagonal * 10,
                                height: SizeConfig.diagonal * 10,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                  image: AssetImage('assets/logo.png'),
                                  fit: BoxFit.cover,
                                )),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    bottom: SizeConfig.diagonal * 5),
                                child: Text(
                                  I18n.of(context).createprofile.toUpperCase(),
                                  style: TextStyle(
                                    color: Color(Styling.accentColor),
                                    fontSize: SizeConfig.diagonal * 3,
                                    fontStyle: FontStyle.normal,
                                  ),
                                ),
                              ),
                              Form(
                                key: _nameKey,
                                child: ZTextField(
                                  hint: I18n.of(context).yourname,
                                  onEditingComplete: () => node.nextFocus(),
                                  onSaved: (newValue) => _name = newValue,
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                              ZRaisedButton(
                                onpressed: createAccount,
                                textIcon: Text(
                                  I18n.of(context).signUp,
                                  style: TextStyle(
                                    color:
                                        Color(Styling.primaryBackgroundColor),
                                    fontSize: SizeConfig.diagonal * 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void confirmSMSCode(String value) async {
    if (value.length == 6) {
      EasyLoading.show(status: I18n.of(context).loading);
      try {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
            verificationId: _verificationcode, smsCode: value);
        UserCredential user =
            await widget.auth.getAuth().signInWithCredential(credential);
        isProfileCreated(user);
      } on Exception catch (e) {
        EasyLoading.dismiss();
        _scaffoldKey.currentState.showSnackBar(
            SnackBar(content: Text(I18n.of(context).operationFailed)));
      }
    }
  }

  void isProfileCreated(UserCredential userCredential) async {
    final User user = userCredential.user;
    /*String token = await widget.messaging.firebaseMessaging.getToken();
    await widget.db.setToken(user.uid, token);*/
    String role = await widget.db.getUserRole(user.uid);
    if (role == null || role == "") {
      EasyLoading.dismiss();
      setState(() {
        _pageState = 2;
        _firebaseUser = user;
      });
    } else {
      String token = await widget.messaging.firebaseMessaging.getToken();
      await widget.db.setToken(user.uid, token);
      EasyLoading.dismiss();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DashboardPage(
              auth: widget.auth,
              userId: user.uid,
              userRole: role,
              db: widget.db,
              messaging: widget.messaging),
        ),
      );
    }
  }

  bool validate() {
    final form = _phoneKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void createAccount() async {
    if (validate2()) {
      EasyLoading.show(status: I18n.of(context).loading);
      bool isOnline = await hasConnection();
      if (!isOnline) {
        EasyLoading.dismiss();
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(I18n.of(context).noInternet)));
      } else {
        try {
          User currentUser;
          if (_firebaseUser != null)
            currentUser = _firebaseUser;
          else
            currentUser = widget.user;

          String token = await widget.messaging.firebaseMessaging.getToken();
          UserProfile userProfile = UserProfile(
            id: currentUser.uid,
            name: _name,
            role: Fields.client,
            phoneNumber: currentUser.phoneNumber,
            token: token,
          );
          await widget.db.createAccount(context, userProfile);
          EasyLoading.dismiss();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(
                auth: widget.auth,
                userId: userProfile.id,
                userRole: userProfile.role,
                db: widget.db,
                messaging: widget.messaging,
              ),
            ),
          );
        } on Exception catch (e) {
          EasyLoading.dismiss();
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text(I18n.of(context).operationFailed)));
        }
      }
    }
  }

  bool validate2() {
    final form = _nameKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void sendCode() async {
    if (validate()) {
      EasyLoading.show(status: I18n.of(context).loading);
      bool isOnline = await hasConnection();
      if (!isOnline) {
        EasyLoading.dismiss();
        _scaffoldKey.currentState
            .showSnackBar(SnackBar(content: Text(I18n.of(context).noInternet)));
      } else {
        try {
          String number = _selectedAreaCode + _phoneNumber;
          await FirebaseAuth.instance.verifyPhoneNumber(
            phoneNumber: number,
            verificationCompleted: (PhoneAuthCredential credential) async {
              UserCredential user =
                  await widget.auth.getAuth().signInWithCredential(credential);
              isProfileCreated(user);
            },
            verificationFailed: (FirebaseAuthException e) {
              EasyLoading.dismiss();
              _scaffoldKey.currentState.showSnackBar(
                SnackBar(
                  content: Text(e.message),
                ),
              );
            },
            codeSent: (String verificationId, int resendToken) {
              setState(() {
                _verificationcode = verificationId;
              });

              bool isAndroid =
                  Theme.of(context).platform == TargetPlatform.android;
              if (!isAndroid) {
                EasyLoading.dismiss();
                setState(() {
                  _pageState = 1;
                });
              }
            },
            timeout: Duration(seconds: 5),
            codeAutoRetrievalTimeout: (String verificationId) {
              setState(() {
                _verificationcode = verificationId;
              });
              bool isAndroid =
                  Theme.of(context).platform == TargetPlatform.android;
              if (isAndroid) {
                EasyLoading.dismiss();
                setState(() {
                  _pageState = 1;
                });
              }
            },
          );
        } on Exception catch (e) {
          EasyLoading.dismiss();
          _scaffoldKey.currentState.showSnackBar(
              SnackBar(content: Text(I18n.of(context).operationFailed)));
        }
      }
    }
  }
}

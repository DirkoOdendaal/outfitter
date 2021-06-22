import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outfitter/service_locator.dart';
import 'package:outfitter/services/parse_service.dart';
import 'package:outfitter/services/navigation_service.dart';
import 'package:provider/provider.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:wiredash/wiredash.dart';

class EmailFieldValidator {
  static String? validate(String? value) {
    if (value!.isEmpty) {
      return 'Email can\'t be empty';
    }

    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regExp = RegExp(pattern);

    if (!regExp.hasMatch(value)) {
      return 'Email address is not valid.';
    }

    // Validate email is correct
    return null;
  }
}

class PasswordFieldValidator {
  static String? validate(String? value) {
    return value!.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

enum FormType { login, registration }

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode _usernameFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  late String _email;
  late String _password;
  String _errorMessage = 'None';
  bool _showErrorMessage = false;

  bool _submitPressed = false;

  bool isLargeScreen = false;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }
    print('not valid');
    return false;
  }

  Future<void> validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _submitPressed = true;
      });
      try {
        final auth = Provider.of<ParseService>(context, listen: false);

        try {
          await auth.signInWithEmailAndPassword(_email, _password);
        } on Exception catch (e) {
          // Show message to user with the correct error description
          setState(() {
            // final ParseException error = e as ParseError;
            print(e);
            _errorMessage = determineErrorMessage(e as String);
            _showErrorMessage = true;
            _submitPressed = false;
          });
        }
      } catch (e) {
        print('Error: $e');
        setState(() {
          _submitPressed = false;
        });
      }
    }
  }

  String determineErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'Invalid username/password.':
        {
          return 'Invalid username or password supplied.';
        }
      // case 'ERROR_USER_NOT_FOUND':
      //   {
      //     return 'Account was not found. Please register an account to login.';
      //   }
      // case 'ERROR_TOO_MANY_REQUESTS':
      //   {
      //     return 'Too many unsuccessful login attempts. Please wait 5 min and try again.';
      //   }
      // case 'ERROR_INVALID_EMAIL':
      //   {
      //     return 'The email address supplied is not in the correct format.';
      //   }
      // case 'ERROR_EMAIL_ALREADY_IN_USE':
      //   {
      //     return 'An account for the specified email is already in use.';
      //   }
      default:
        {
          return 'Sorry, we seem to be having technical difficulties. Please try again later.';
        }
    }
  }

  Future<void> moveToRegistration() async {
    formKey.currentState!.reset();
    setState(() {
      _showErrorMessage = false;
    });
    await locator<NavigationService>().navigateTo('/register');
  }

  Future<void> moveToForgottenPassword() async {
    formKey.currentState!.reset();
    setState(() {
      _showErrorMessage = false;
    });
    await locator<NavigationService>().navigateTo('/reset-password');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent.shade200,
          onPressed: () => Wiredash.of(context)!.show(),
          child: const Icon(
            Typicons.message,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF201E1E),
        body: OrientationBuilder(
            builder: (BuildContext context, Orientation orientation) {
          if (MediaQuery.of(context).size.width > 600) {
            isLargeScreen = true;
          } else {
            isLargeScreen = false;
          }

          return Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: viewportConstraints.maxHeight,
                ),
                child: Container(
                  margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                  width: isLargeScreen
                      ? viewportConstraints.maxWidth * 0.5
                      : viewportConstraints.maxWidth,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: const Padding(
                              padding: EdgeInsets.all(25.0),
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 30.0,
                                  color: Colors.white,
                                ),
                                textDirection: TextDirection.ltr,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Form(
                        key: formKey,
                        child: Wrap(
                          spacing: 5.0,
                          runSpacing: 10.0,
                          children: <Widget>[
                            Material(
                              elevation: 15.0,
                              shadowColor: Colors.black,
                              child: TextFormField(
                                key: const Key('email'),
                                cursorColor: Colors.white,
                                keyboardType: TextInputType.emailAddress,
                                validator: EmailFieldValidator.validate,
                                onSaved: (String? value) => _email = value!,
                                style: const TextStyle(color: Colors.white),
                                focusNode: _usernameFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (String value) {
                                  _usernameFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocus);
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xFF2D2D2D),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Email',
                                ),
                              ),
                            ),
                            Material(
                              elevation: 15.0,
                              shadowColor: Colors.black,
                              child: TextFormField(
                                key: const Key('password'),
                                cursorColor: Colors.white,
                                validator: PasswordFieldValidator.validate,
                                onSaved: (String? value) => _password = value!,
                                obscureText: true,
                                style: const TextStyle(color: Colors.white),
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (String value) {
                                  _passwordFocus.unfocus();
                                  setState(() {
                                    _submitPressed = true;
                                  });
                                  validateAndSubmit();
                                },
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xFF2D2D2D),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Password',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin:
                                const EdgeInsets.only(top: 20.0, bottom: 10.0),
                            child: RichText(
                              text: TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    moveToForgottenPassword();
                                  },
                                text: 'FORGOT PASSWORD',
                                style: const TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin:
                                const EdgeInsets.only(bottom: 20.0, top: 10.0),
                            child: RichText(
                              text: TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    moveToRegistration();
                                  },
                                text: 'CREATE USER',
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  decoration: TextDecoration.underline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            margin:
                                const EdgeInsets.only(right: 10.0, left: 10.0),
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Visibility(
                              visible: _showErrorMessage,
                              child: Text(
                                _errorMessage,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(child: _submitButton()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      );
    });
  }

  Widget _submitButton() {
    if (_submitPressed) {
      return OutlinedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return const Color(0xFF201E1E);
          }),
          foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
            return Colors.white;
          }),
          padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
              (Set<MaterialState> states) {
            return const EdgeInsets.all(10.0);
          }),
          side: MaterialStateProperty.resolveWith<BorderSide>(
              (Set<MaterialState> states) {
            return BorderSide(
              color: Colors.blueAccent.shade700, //Color of the border
              style: BorderStyle.solid, //Style of the border
              width: 2, //width of the border
            );
          }),
          shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
              (Set<MaterialState> states) {
            return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
                side:
                    BorderSide(color: Colors.blueAccent.shade200, width: 2.0));
          }),
        ),
        onPressed: () {},
        child: const SizedBox(
          height: 22.0,
          width: 22.0,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return OutlinedButton(
      key: const Key('signIn'),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          return const Color(0xFF201E1E);
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
          return Colors.white;
        }),
        padding: MaterialStateProperty.resolveWith<EdgeInsetsGeometry>(
            (Set<MaterialState> states) {
          return const EdgeInsets.all(10.0);
        }),
        side: MaterialStateProperty.resolveWith<BorderSide>(
            (Set<MaterialState> states) {
          return BorderSide(
            color: Colors.blueAccent.shade700, //Color of the border
            style: BorderStyle.solid, //Style of the border
            width: 2, //width of the border
          );
        }),
        shape: MaterialStateProperty.resolveWith<OutlinedBorder>(
            (Set<MaterialState> states) {
          return RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
              side: BorderSide(color: Colors.blueAccent.shade200, width: 2.0));
        }),
      ),
      onPressed: validateAndSubmit,
      child: const Text(
        'Login',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

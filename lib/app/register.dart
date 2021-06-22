import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:outfitter/service_locator.dart';
import 'package:outfitter/services/navigation_service.dart';
import 'package:outfitter/services/parse_service.dart';
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

class NameFieldValidator {
  static String? validate(String? value) {
    return value!.isEmpty ? 'Name can\'t be empty' : null;
  }
}

class SurnameFieldValidator {
  static String? validate(String? value) {
    return value!.isEmpty ? 'Surname can\'t be empty' : null;
  }
}

class PasswordFieldValidator {
  static String? validate(String? value) {
    return value!.isEmpty ? 'Password can\'t be empty' : null;
  }
}

class RegisterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

enum FormType { login, registration }

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _surnameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  String _email = '';
  String _password = '';
  String _name = '';
  String _surname = '';
  String _errorMessage = 'None';
  bool _showErrorMessage = false;

  bool _submitPressed = false;

  bool isLargeScreen = false;

  bool validateAndSave() {
    final form = formKey.currentState!;
    print(form.validate());
    if (form.validate()) {
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
          await auth.createUserWithEmailAndPassword(
              _email, _password, _name, _surname);
          await locator<NavigationService>().navigateTo('/home');
        } on Exception catch (e) {
          // Show message to user with the correct error description
          setState(() {
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
      case 'ERROR_WRONG_PASSWORD':
        {
          return 'Invalid username or password supplied.';
        }
      case 'ERROR_INVALID_EMAIL':
        {
          return 'The email address supplied is not in the correct format.';
        }
      case 'Account already exists for this username.':
        {
          return 'An account for the specified email is already in use.';
        }
      default:
        {
          return 'Sorry, we seem to be having technical difficulties. Please try again later.';
        }
    }
  }

  Future<void> moveToLogin() async {
    formKey.currentState!.reset();
    setState(() {
      _showErrorMessage = false;
    });
    await locator<NavigationService>().navigateTo('/login');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
      return Scaffold(
        backgroundColor: const Color(0xFF201E1E),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent.shade200,
          onPressed: () => Wiredash.of(context)!.show(),
          child: const Icon(
            Typicons.message,
            color: Colors.white,
          ),
        ),
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
                                'Register',
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
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xFF2D2D2D),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Email',
                                ),
                                validator: EmailFieldValidator.validate,
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (String? value) => _email = value!,
                                focusNode: _emailFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (String value) {
                                  _emailFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_nameFocus);
                                },
                              ),
                            ),
                            Material(
                              elevation: 15.0,
                              shadowColor: Colors.black,
                              child: TextFormField(
                                key: const Key('name'),
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xFF2D2D2D),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Name',
                                ),
                                validator: NameFieldValidator.validate,
                                onSaved: (String? value) => _name = value!,
                                focusNode: _nameFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (String value) {
                                  _nameFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_surnameFocus);
                                },
                              ),
                            ),
                            Material(
                              elevation: 15.0,
                              shadowColor: Colors.black,
                              child: TextFormField(
                                key: const Key('surname'),
                                cursorColor: Colors.white,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xFF2D2D2D),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Surname',
                                ),
                                validator: SurnameFieldValidator.validate,
                                keyboardType: TextInputType.emailAddress,
                                onSaved: (String? value) => _surname = value!,
                                focusNode: _surnameFocus,
                                textInputAction: TextInputAction.next,
                                onFieldSubmitted: (String value) {
                                  _surnameFocus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(_passwordFocus);
                                },
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
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  fillColor: Color(0xFF2D2D2D),
                                  filled: true,
                                  hintStyle: TextStyle(color: Colors.grey),
                                  hintText: 'Password',
                                ),
                                focusNode: _passwordFocus,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (String value) {
                                  _passwordFocus.unfocus();
                                  setState(() {
                                    _submitPressed = true;
                                  });
                                  validateAndSubmit();
                                },
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
                                const EdgeInsets.only(bottom: 20.0, top: 20.0),
                            child: RichText(
                              text: TextSpan(
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    moveToLogin();
                                  },
                                text: 'HAVE AN ACCOUNT? LOGIN',
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
                          Expanded(
                            child: _submitButton(),
                          ),
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
      key: const Key('register'),
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
        'Register',
        style: TextStyle(
          fontSize: 20.0,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:secure_counter/secrets.dart';
import 'package:secure_counter/user_service.dart';

class RefreshTokenLogin extends StatefulWidget {
  const RefreshTokenLogin({Key? key}) : super(key: key);

  @override
  State<RefreshTokenLogin> createState() => _RefreshTokenLoginState();
}

class _RefreshTokenLoginState extends State<RefreshTokenLogin> {
  TextEditingController _controller = TextEditingController();
      final _userService = UserService(userPool);
  bool _isAuthenticated = false;
  @override
  void initState() {
    // tokenExpiration();
    super.initState();
  }

  Future<UserService> _getValues() async {
    await _userService.init();
    _isAuthenticated = await _userService.checkAuthenticated();
    return _userService;
  }

  bool checkTokenValidity(String token) {
    if (DateTime.now().add(Duration(minutes: 3)).isBefore(
          tokenExpiration(token),
        )) print('token is valid');
    {
      return true;
    }
  }

  DateTime tokenExpiration(String token) {
    final parts = token.split('.');

    if (parts.length != 3) {
      throw Exception();
    }

    final payloadMap = json.decode(_decodeBase64(parts[1]));

    if (payloadMap is! Map<String, dynamic>) {
      throw Exception();
    }

    return DateTime.fromMillisecondsSinceEpoch(payloadMap['exp'] * 1000);
  }

  String _decodeBase64(String str) {
    var output = str.replaceAll('-', '+').replaceAll('_', '/');

    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception();
    }

    return utf8.decode(base64Url.decode(output));
  }

  void login(String refreshtoken) async {
    try {
      // final cognitoUser = CognitoUser(
      //     'bc222d26-ec41-40b1-a177-981adc75dc92', userPool,
      //     storage: storage);

      debugPrint('cognitoUser: ${_userService}');
      final newsession = _userService.refreshSession(refreshtoken);
      
      debugPrint('newSession: ${newsession}');
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.amber,
          title: Text('Login with refresh token'),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Text('Login with refresh token'),
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: 20,
                  controller: _controller,
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    login(_controller.text);
                  },
                  child: Text('Login with refresh token')),
              ElevatedButton(
                  onPressed: () async {
                    try {
                      // final user = await usersev
                      // debugPrint('user: ${user}');
                      // final session = await user?.getSession();
                      // debugPrint('session: ${session}');
                      final teck = await _userService.init();
                      debugPrint('teck: ${teck}');
                      // usersev.getCurrentUser();

                      // print('\n${cognitoUser.getSignInUserSession()!.refreshToken!.token}\n test');
                      //  print(
                      // '${cognitoUser.username} ${cognitoUser.getSignInUserSession()!.accessToken.jwtToken}');

                      //  checkTokenValidity(cognitoUser.getSignInUserSession()!.accessToken.jwtToken!);
                    } catch (e) {
                      print(e);
                    }
                  },
                  child: Text('Login with refresh token'))
            ],
          ),
        ));
  }
}

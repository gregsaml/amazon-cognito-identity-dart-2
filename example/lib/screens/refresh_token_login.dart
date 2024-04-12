import 'dart:convert';

import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/material.dart';
import 'package:secure_counter/secrets.dart';

class RefreshTokenLogin extends StatefulWidget {
  const RefreshTokenLogin({Key? key}) : super(key: key);

  @override
  State<RefreshTokenLogin> createState() => _RefreshTokenLoginState();
}

class _RefreshTokenLoginState extends State<RefreshTokenLogin> {
  TextEditingController _controller = TextEditingController();
  final cognitoUser =
      CognitoUser('bc222d26-ec41-40b1-a177-981adc75dc92', userPool);

@override
  void initState() {
// checkTokenValidity(cognitoUser.getCognitoUserSession().);
    super.initState();
  }


  bool checkTokenValidity(String token) {
    if (DateTime.now().add(Duration(minutes: 5)).isBefore(
          tokenExpiration(token),
        )) {
      return true;
    }
    return false;
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
      debugPrint('cognitoUser: ${cognitoUser.client}');
      final cognitoRefreshToken = await CognitoRefreshToken(refreshtoken);
      debugPrint('cognitoRefreshToken: ${cognitoRefreshToken.token}');
      final newSession = await cognitoUser.refreshSession(cognitoRefreshToken);
      debugPrint('newSession: ${newSession}');
    cognitoUser.cacheTokens();

      print('  ${newSession?.isValid()}');
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
                      print(
                          '${cognitoUser.username} ${cognitoUser.getSession().toString()}');
                      cognitoUser.username;

                      // _session =
                      //     await cognitoUser.authenticateUser(authDetails);
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

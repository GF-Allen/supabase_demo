import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:protocol_handler/protocol_handler.dart';
import 'package:supabase_auth_ui/supabase_auth_ui.dart';
import 'package:supabase_demo/main.dart';
import 'package:url_protocol/url_protocol.dart';

class AuthLogin extends StatefulWidget {
  const AuthLogin({Key? key}) : super(key: key);

  @override
  State<AuthLogin> createState() => _AuthLoginState();
}

class _AuthLoginState extends State<AuthLogin> with ProtocolListener {
//   // String rawNonce = 'dsfjsadkflsdflsdfsldccns';
//   final hashedNonce = sha256.convert(utf8.encode('dsfjsadkflsdflsdfsldccns')).toString();
//
// // Your registered Google client ID here.
// // This will be different for iOS and Android
//   String clientId = '327263140686-gu0qr5o9idfgrqrstcl8tilc0rrgfp7k.apps.googleusercontent.com';
//
// // bundle ID for iOS, package name for Android here
//   final packageName = 'io.supabase.example';
//
//   /// fixed for google login
//   final redirectUrl = 'tech.gentleflow.supabase.supabase_demo://google_auth';
//
//   /// fixed for google login
//   String discoveryUrl = 'https://accounts.google.com/.well-known/openid-configuration';
//
//   final appAuth = FlutterAppAuth();

  StreamSubscription? _subscription;

  @override
  void initState() {
    protocolHandler.addListener(this);
    print('session: ${Supabase.instance.client.auth.currentSession}');
    _subscription = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      print('onAuthStateChange ${event.session}');
    });
    super.initState();
  }

  @override
  void dispose() {
    protocolHandler.removeListener(this);
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void onProtocolUrlReceived(String url) {
    final uri = Uri.parse(url);
    _handleDeeplink(uri);
  }

  Future<void> _handleDeeplink(Uri uri) async {
    Supabase.instance.log('***** SupabaseAuthState handleDeeplink $uri');

    // notify auth deeplink received
    Supabase.instance.log('onReceivedAuthDeeplink uri: $uri');

    try {
      await Supabase.instance.client.auth.getSessionFromUrl(uri);
    } on AuthException catch (error, stackTrace) {
      Supabase.instance.log(error.toString(), stackTrace);
    } catch (error, stackTrace) {
      Supabase.instance.log(error.toString(), stackTrace);
    }
  }


  // signIn() async {
  //   final result = await appAuth.authorize(
  //     AuthorizationRequest(
  //       clientId,
  //       redirectUrl,
  //       discoveryUrl: discoveryUrl,
  //       nonce: hashedNonce,
  //       scopes: [
  //         'openid',
  //         'email',
  //       ],
  //     ),
  //   );
  //
  //   if (result == null) {
  //     throw AuthException('Could not find AuthorizationResponse after authorizing');
  //   }
  //   // Request the access and id token to google
  //   final tokenResponse = await appAuth.token(
  //     TokenRequest(
  //       clientId,
  //       redirectUrl,
  //       authorizationCode: result.authorizationCode,
  //       discoveryUrl: discoveryUrl,
  //       codeVerifier: result.codeVerifier,
  //       nonce: result.nonce,
  //       scopes: [
  //         'openid',
  //         'email',
  //       ],
  //     ),
  //   );
  //
  //   final idToken = tokenResponse?.idToken;
  //
  //   if (idToken == null) {
  //     throw AuthException('Could not find idToken from the token response');
  //   }
  //
  //   AuthResponse response = await supabase.auth.signInWithIdToken(provider: Provider.google, idToken: idToken);
  //   print('response ${response}');
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auth'),
      ),
      body: Center(
        child: Column(
          children: [
            TextButton(
                onPressed: () async {
                  await supabase.auth.signInWithOAuth(
                    Provider.google,
                    redirectTo: "tech.gentleflow.supabase://login-callback/"
                  );
                },
                child: Text('Google Sign in')),
            SupaSocialsAuth(
              socialProviders: [
                // SocialProviders.apple,
                SocialProviders.google,
              ],
              colored: true,
              redirectUrl: 'tech.gentleflow.supabase://login-callback/',
              // redirectUrl: 'https://loqaurrqgqdzircucmrc.supabase.co/auth/v1/callback',
              // redirectUrl: 'http://localhost:3000',
              // redirectUrl: 'tech.gentleflow.supabase://login-callback/',
              onSuccess: (Session response) {
                print('response ${response.toJson()}');
                // do something, for example: navigate('home');
              },
              onError: (error) {
                print('error ${error.toString()}');
                // do something, for example: navigate("wait_for_email");
              },
            ),
          ],
        ),
      ),
    );
  }
}

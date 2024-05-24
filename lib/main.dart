// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'url_protocol/api.dart';

///////////////////////////////////////////////////////////////////////////////
/// Please make sure to follow the setup instructions below
///
/// Please take a look at:
/// - example/android/app/main/AndroidManifest.xml for Android.
///
/// - example/ios/Runner/Runner.entitlements for Universal Link sample.
/// - example/ios/Runner/Info.plist for Custom URL scheme sample.
///
/// You can launch an intent on an Android Emulator like this:
///    adb shell am start -a android.intent.action.VIEW \
///     -d "sample://open.my.app/#/book/hello-world"
///
///
/// On windows & macOS:
///   The simplest way to test it is by
///   opening your browser and type: sample://foo/#/book/hello-world2
///////////////////////////////////////////////////////////////////////////////

const kWindowsScheme = 'sample';

void main() {
  // Register our protocol only on Windows platform
  _registerWindowsProtocol();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();

    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();

    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle links
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      print('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.toString());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      initialRoute: "/",
      onGenerateRoute: (RouteSettings settings) {
        final routeName = settings.name;
        Widget routeWidget = defaultScreen(routeName);

        return MaterialPageRoute(
          builder: (context) => routeWidget,
          settings: settings,
          fullscreenDialog: true,
        );
      },
    );
  }

  Widget defaultScreen(String? routeName) {
    return Scaffold(
      appBar: AppBar(title: const Text('Default Screen')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectableText(routeName ?? 'No name provided'),
            const SizedBox(height: 20),
            buildWindowsUnregisterBtn(),
          ],
        ),
      ),
    );
  }

  Widget buildWindowsUnregisterBtn() {
    if (!kIsWeb) {
      if (Platform.isWindows) {
        return TextButton(
            onPressed: () => unregisterProtocolHandler(kWindowsScheme),
            child: const Text('Remove Windows protocol registration'));
      }
    }

    return const SizedBox.shrink();
  }
}

void _registerWindowsProtocol() {
  // Register our protocol only on Windows platform
  if (!kIsWeb) {
    if (Platform.isWindows) {
      registerProtocolHandler(kWindowsScheme);
    }
  }
}

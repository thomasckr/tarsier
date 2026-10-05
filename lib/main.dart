import 'dart:io';

import 'package:flutter/material.dart';

import 'package:dim_flutter/dim_flutter.dart';

import 'root.dart';
import 'views/register.dart';

// ---- diag logging (temporary): write startup checkpoints to a file so a hang
// can be located without a console. Appended after every startup step.
File? _diagFile;
void _diag(String msg) {
  final line = '${DateTime.now().toIso8601String()}  $msg';
  debugPrint('DIAG $msg');
  try {
    _diagFile ??= () {
      final base = Platform.environment['APPDATA']
          ?? Platform.environment['HOME']
          ?? Directory.systemTemp.path;
      final dir = Directory('$base/chat.dim/tarsier');
      dir.createSync(recursive: true);
      return File('${dir.path}${Platform.pathSeparator}diag.log');
    }();
    _diagFile!.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
  } catch (_) {}
}


void main() async {
  _diag('main: entered');
  WidgetsFlutterBinding.ensureInitialized();
  _diag('main: bindings initialized');

  // Set log level
  Log.level = Log.RELEASE;
  // Log.level = Log.DEVELOP;
  if (DevicePlatform.isIOS) {
    Log.colorful = false;
    Log.showTime = false;
    Log.showCaller = true;
  } else {
    Log.colorful = true;
    Log.showTime = true;
    Log.showCaller = true;
  }

  // debugShowCheckedModeBanner
  bool debug = false;
  assert((){
    debug = Log.level != Log.RELEASE;
    return true;
  }());

  // Check Brightness & Language
  // Load device + package info
  await SysInfo().beforeLaunchApp();
  _diag('main: SysInfo.beforeLaunchApp done');
  // Launch the app
  launchApp(const _RootRouterPage(), debug: debug);
  _diag('main: launchApp called');
}


class _RootRouterPage extends StatefulWidget {
  const _RootRouterPage();

  @override
  State<_RootRouterPage> createState() => _RootRouterPageState();
}

class _RootRouterPageState extends State<_RootRouterPage> with Logging {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleAppRoute(context));
  }

  Future<void> _handleAppRoute(BuildContext context) async {
    _diag('route: entered');
    User? user;
    // Check permission: Storage
    bool permitted = await PermissionChecker().checkDatabasePermissions();
    _diag('route: permission check done, permitted=$permitted');
    if (permitted) {
      // check current user
      logDebug('check current user');
      GlobalVariable shared = GlobalVariable();
      _diag('route: loading current user ...');
      user = await shared.facebook.currentUser;
      _diag('route: current user loaded -> $user');
    }
    // Launch the app
    if (!context.mounted) {
      logError('context error: $context');
    } else if (user != null) {
      logInfo('open main page');
      changeToMainPage(context);
    } else {
      logInfo('open register page');
      // changeToRegisterPage
      changeRootPage(context, (context) => RegisterPage());
    }

  }

  @override
  Widget build(BuildContext context) {
    Widget view = const Center(child: CircularProgressIndicator());
    view = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _logo(),
        view,
      ],
    );
    return MaterialApp(
      home: Scaffold(
        body: view,
        backgroundColor: Styles.colors.logoBackgroundColor,
      ),
    );
  }

  Widget _logo() => SizedBox(
    width: 60,
    height: 60,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _eye(),
        const SizedBox(width: 6,),
        _eye(),
      ],
    ),
  );
  Widget _eye() => const Icon(Icons.panorama_fish_eye,
    size: 18,
    color: Colors.white,
  );

}

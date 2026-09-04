import 'package:flutter/material.dart';
import 'package:jn_smarter_iptv_player_pro/screens/home_screen.dart';
import 'package:jn_smarter_iptv_player_pro/screens/live_screen.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/app_state.dart';
import 'services/desktop_video_backend.dart';
import 'theme.dart';

void main() {
  registerDesktopVideoBackend();
  runApp(const JnSmarterIptvApp());
}

class JnSmarterIptvApp extends StatelessWidget {
  const JnSmarterIptvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'JN Smarter IPTV Player Pro',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
        routes: {
          '/HomeScreen': (context) => const HomeScreen(),
          '/LiveScreen': (context) => const LiveScreen(),
        },
      ),
    );
  }
}

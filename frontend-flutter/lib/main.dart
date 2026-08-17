import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'services/app_state.dart';
import 'theme.dart';

void main() {
  runApp(const JnSmarterIptvApp());
}

class JnSmarterIptvApp extends StatelessWidget {
  const JnSmarterIptvApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'JN Smarter IPTV Player Pro',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const HomeScreen(),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../theme.dart';
import 'home_screen.dart';
import 'live_screen.dart';

/// Shown while the app connects to the backend and loads playlists. Once
/// [AppState.init] finishes (and a minimum display time has elapsed, so it
/// never just flickers on a fast connection), replaces itself with
/// [LiveScreen].
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  static const _minSplashTime = Duration(milliseconds: 900);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _boot();
  }

  Future<void> _boot() async {
    final started = DateTime.now();
    await context.read<AppState>().init();

    final elapsed = DateTime.now().difference(started);
    if (elapsed < _minSplashTime) {
      await Future.delayed(_minSplashTime - elapsed);
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: Tween<double>(begin: 0.5, end: 1.0).animate(
                CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.panel,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(Icons.live_tv_rounded, color: AppColors.accent, size: 34),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'JN SMARTER',
              style: TextStyle(fontSize: 13, letterSpacing: 4, color: AppColors.accent, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            const Text(
              'IPTV Player Pro',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
            const SizedBox(height: 32),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: AppColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

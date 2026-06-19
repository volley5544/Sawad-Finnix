import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/firebase/firebase_init.dart';
import 'core/router/app_router.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseInit.initialize(AppState.instance.env);
  runApp(const SawadFinnixApp());
}

class SawadFinnixApp extends StatelessWidget {
  const SawadFinnixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      // Same singleton used by non-widget code via AppState.instance.
      value: AppState.instance,
      child: MaterialApp.router(
        title: 'Sawad Finnix',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}

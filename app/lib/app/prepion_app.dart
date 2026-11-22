import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/router.dart';
import 'package:prepion/app/theme.dart';

class PrepionApp extends StatelessWidget {
  const PrepionApp({this.routerConfig, super.key});

  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Prepion',
      debugShowCheckedModeBanner: false,
      theme: crearTemaPrepion(),
      routerConfig: routerConfig ?? router,
    );
  }
}

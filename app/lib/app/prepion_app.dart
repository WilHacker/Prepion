import 'dart:ui';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/router.dart';
import 'package:prepion/app/theme.dart';

class _PrepionScrollBehavior extends MaterialScrollBehavior {
  const _PrepionScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const <PointerDeviceKind>{
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class PrepionApp extends StatelessWidget {
  const PrepionApp({this.routerConfig, super.key});

  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Prepion',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _PrepionScrollBehavior(),
      theme: crearTemaPrepion(),
      routerConfig: routerConfig ?? router,
    );
  }
}

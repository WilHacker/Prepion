import 'dart:ui';

import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/modo_tema_provider.dart';
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

class PrepionApp extends ConsumerWidget {
  const PrepionApp({this.routerConfig, super.key});

  final GoRouter? routerConfig;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Prepion',
      debugShowCheckedModeBanner: false,
      scrollBehavior: const _PrepionScrollBehavior(),
      theme: crearTemaClaroPrepion(),
      darkTheme: crearTemaPrepion(),
      themeMode: ref.watch(modoTemaProvider),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: routerConfig ?? router,
    );
  }
}

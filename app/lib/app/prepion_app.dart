import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/router.dart';

class PrepionApp extends StatelessWidget {
  const PrepionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Prepion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      routerConfig: router,
    );
  }
}

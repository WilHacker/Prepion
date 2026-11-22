import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

class InicioPage extends StatelessWidget {
  const InicioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Prepion', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 24),
            // Accesos temporales; los reemplaza el onboarding (#2).
            FilledButton(
              onPressed: () => context.push('/practica'),
              child: const Text('Practicar hoy'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/banco'),
              child: const Text('Ver banco de preguntas'),
            ),
          ],
        ),
      ),
    );
  }
}

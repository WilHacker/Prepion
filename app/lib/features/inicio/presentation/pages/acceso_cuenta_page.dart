import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/app/theme.dart';

/// Vista secundaria de acceso con cuenta (respaldo opcional, HU-07).
class AccesoCuentaPage extends StatelessWidget {
  const AccesoCuentaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: context.tokens.superficie,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: context.tokens.borde),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.verified_user_outlined,
                      size: 36,
                      color: context.tokens.azul,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tu cuenta es opcional',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: context.tokens.textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'El inicio de sesión con correo y código de recuperación se habilitará para respaldar tu progreso entre dispositivos. Mientras tanto puedes empezar a practicar sin cuenta y vincular tu progreso luego.',
                      style: TextStyle(
                        fontSize: 14,
                        color: context.tokens.textoSecundario,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              FilledButton(
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/onboarding');
                  }
                },
                child: const Text('Volver y empezar sin cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

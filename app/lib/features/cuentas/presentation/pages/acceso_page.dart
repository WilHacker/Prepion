import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:prepion/features/cuentas/domain/cuenta.dart';
import 'package:prepion/features/cuentas/presentation/providers/cuentas_provider.dart';

/// Inicio de sesión o registro (mismo formulario). La cuenta es opcional.
class AccesoPage extends ConsumerStatefulWidget {
  const AccesoPage({super.key, this.esRegistro = false});

  final bool esRegistro;

  @override
  ConsumerState<AccesoPage> createState() => _AccesoPageState();
}

class _AccesoPageState extends ConsumerState<AccesoPage> {
  final _formulario = GlobalKey<FormState>();
  final _correo = TextEditingController();
  final _contrasena = TextEditingController();
  bool _enviando = false;
  String? _error;

  @override
  void dispose() {
    _correo.dispose();
    _contrasena.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formulario.currentState!.validate()) return;
    setState(() {
      _enviando = true;
      _error = null;
    });
    final sesion = ref.read(sesionProvider.notifier);
    try {
      final cuenta = widget.esRegistro
          ? await sesion.registrar(_correo.text, _contrasena.text)
          : await sesion.iniciarSesion(_correo.text, _contrasena.text);
      if (mounted) context.go(cuenta.esAdmin ? '/admin' : '/');
    } on ErrorCuentas catch (error) {
      if (mounted) setState(() => _error = error.mensaje);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuenta = ref.watch(sesionProvider).asData?.value;
    final titulo = widget.esRegistro ? 'Crear cuenta' : 'Iniciar sesión';
    return Scaffold(
      appBar: AppBar(title: Text(titulo)),
      body: SafeArea(
        child: cuenta != null
            ? _SesionIniciada(cuenta: cuenta)
            : _formularioAcceso(context),
      ),
    );
  }

  Widget _formularioAcceso(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: <Widget>[
        Form(
          key: _formulario,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                key: const Key('campo_correo'),
                controller: _correo,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const <String>[AutofillHints.email],
                decoration: const InputDecoration(labelText: 'Correo'),
                validator: (v) =>
                    (v == null || !v.contains('@') || !v.contains('.'))
                    ? 'Escribe un correo válido'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('campo_contrasena'),
                controller: _contrasena,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Mínimo 8 caracteres' : null,
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  key: const Key('mensaje_error_acceso'),
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('boton_enviar_acceso'),
                onPressed: _enviando ? null : _enviar,
                child: Text(
                  _enviando
                      ? 'Un momento...'
                      : (widget.esRegistro ? 'Registrarme' : 'Entrar'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('boton_cambiar_modo'),
                onPressed: _enviando
                    ? null
                    : () => context.pushReplacement(
                        widget.esRegistro ? '/iniciar-sesion' : '/registro',
                      ),
                child: Text(
                  widget.esRegistro
                      ? 'Ya tengo cuenta · Iniciar sesión'
                      : 'No tengo cuenta · Registrarme',
                ),
              ),
              TextButton(
                onPressed: () =>
                    context.canPop() ? context.pop() : context.go('/'),
                child: const Text('Continuar sin cuenta'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SesionIniciada extends ConsumerWidget {
  const _SesionIniciada({required this.cuenta});

  final Cuenta cuenta;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'Sesión iniciada como ${cuenta.correo ?? 'invitado'}',
            key: const Key('texto_sesion_iniciada'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 24),
          if (cuenta.esAdmin)
            FilledButton(
              key: const Key('boton_ir_panel_admin'),
              onPressed: () => context.go('/admin'),
              child: const Text('Ir al panel de administración'),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            key: const Key('boton_cerrar_sesion'),
            onPressed: () => ref.read(sesionProvider.notifier).cerrarSesion(),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}

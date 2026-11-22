import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:prepion/features/cuentas/presentation/providers/cuentas_provider.dart';

enum _Opcion { iniciarSesion, registrarse, panelAdmin, cerrarSesion }

/// Icono de usuario para la barra superior: muestra quién usa la app
/// (invitado o la cuenta) y da acceso a iniciar sesión, registrarse o salir.
///
/// Vive en `app/` porque junta `inicio` con `cuentas` sin que se importen entre sí.
class BotonCuenta extends ConsumerWidget {
  const BotonCuenta({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuenta = ref.watch(sesionProvider).asData?.value;
    final etiqueta = cuenta == null ? 'Invitado' : (cuenta.correo ?? 'Cuenta');

    return PopupMenuButton<_Opcion>(
      key: const Key('boton_cuenta'),
      tooltip: etiqueta,
      icon: Icon(
        cuenta == null ? Icons.person_outline_rounded : Icons.account_circle,
      ),
      onSelected: (opcion) async {
        switch (opcion) {
          case _Opcion.iniciarSesion:
            await context.push('/iniciar-sesion');
          case _Opcion.registrarse:
            await context.push('/registro');
          case _Opcion.panelAdmin:
            await context.push('/admin');
          case _Opcion.cerrarSesion:
            await ref.read(sesionProvider.notifier).cerrarSesion();
        }
      },
      itemBuilder: (_) => <PopupMenuEntry<_Opcion>>[
        PopupMenuItem<_Opcion>(
          enabled: false,
          child: Text(
            etiqueta,
            key: const Key('texto_cuenta_actual'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const PopupMenuDivider(),
        if (cuenta == null) ...<PopupMenuEntry<_Opcion>>[
          const PopupMenuItem<_Opcion>(
            value: _Opcion.iniciarSesion,
            child: Text('Iniciar sesión'),
          ),
          const PopupMenuItem<_Opcion>(
            value: _Opcion.registrarse,
            child: Text('Crear cuenta'),
          ),
        ] else ...<PopupMenuEntry<_Opcion>>[
          if (cuenta.esAdmin)
            const PopupMenuItem<_Opcion>(
              value: _Opcion.panelAdmin,
              child: Text('Panel de administración'),
            ),
          const PopupMenuItem<_Opcion>(
            value: _Opcion.cerrarSesion,
            child: Text('Cerrar sesión'),
          ),
        ],
      ],
    );
  }
}

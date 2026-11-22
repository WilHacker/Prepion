import 'package:flutter_riverpod/legacy.dart';
import 'package:material_ui/material_ui.dart';

/// Tema activo de la app; arranca en el oscuro oficial de la marca.
final modoTemaProvider = StateProvider<ThemeMode>((ref) => ThemeMode.dark);

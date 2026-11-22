// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExamenesTable extends Examenes with TableInfo<$ExamenesTable, Examen> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamenesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gestionMeta = const VerificationMeta(
    'gestion',
  );
  @override
  late final GeneratedColumn<String> gestion = GeneratedColumn<String>(
    'gestion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivoMeta = const VerificationMeta(
    'archivo',
  );
  @override
  late final GeneratedColumn<String> archivo = GeneratedColumn<String>(
    'archivo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, gestion, tipo, archivo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'examenes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Examen> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('gestion')) {
      context.handle(
        _gestionMeta,
        gestion.isAcceptableOrUnknown(data['gestion']!, _gestionMeta),
      );
    } else if (isInserting) {
      context.missing(_gestionMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('archivo')) {
      context.handle(
        _archivoMeta,
        archivo.isAcceptableOrUnknown(data['archivo']!, _archivoMeta),
      );
    } else if (isInserting) {
      context.missing(_archivoMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Examen map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Examen(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gestion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gestion'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      archivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archivo'],
      )!,
    );
  }

  @override
  $ExamenesTable createAlias(String alias) {
    return $ExamenesTable(attachedDatabase, alias);
  }
}

class Examen extends DataClass implements Insertable<Examen> {
  final String id;
  final String gestion;
  final String tipo;
  final String archivo;
  const Examen({
    required this.id,
    required this.gestion,
    required this.tipo,
    required this.archivo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['gestion'] = Variable<String>(gestion);
    map['tipo'] = Variable<String>(tipo);
    map['archivo'] = Variable<String>(archivo);
    return map;
  }

  ExamenesCompanion toCompanion(bool nullToAbsent) {
    return ExamenesCompanion(
      id: Value(id),
      gestion: Value(gestion),
      tipo: Value(tipo),
      archivo: Value(archivo),
    );
  }

  factory Examen.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Examen(
      id: serializer.fromJson<String>(json['id']),
      gestion: serializer.fromJson<String>(json['gestion']),
      tipo: serializer.fromJson<String>(json['tipo']),
      archivo: serializer.fromJson<String>(json['archivo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gestion': serializer.toJson<String>(gestion),
      'tipo': serializer.toJson<String>(tipo),
      'archivo': serializer.toJson<String>(archivo),
    };
  }

  Examen copyWith({
    String? id,
    String? gestion,
    String? tipo,
    String? archivo,
  }) => Examen(
    id: id ?? this.id,
    gestion: gestion ?? this.gestion,
    tipo: tipo ?? this.tipo,
    archivo: archivo ?? this.archivo,
  );
  Examen copyWithCompanion(ExamenesCompanion data) {
    return Examen(
      id: data.id.present ? data.id.value : this.id,
      gestion: data.gestion.present ? data.gestion.value : this.gestion,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      archivo: data.archivo.present ? data.archivo.value : this.archivo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Examen(')
          ..write('id: $id, ')
          ..write('gestion: $gestion, ')
          ..write('tipo: $tipo, ')
          ..write('archivo: $archivo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gestion, tipo, archivo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Examen &&
          other.id == this.id &&
          other.gestion == this.gestion &&
          other.tipo == this.tipo &&
          other.archivo == this.archivo);
}

class ExamenesCompanion extends UpdateCompanion<Examen> {
  final Value<String> id;
  final Value<String> gestion;
  final Value<String> tipo;
  final Value<String> archivo;
  final Value<int> rowid;
  const ExamenesCompanion({
    this.id = const Value.absent(),
    this.gestion = const Value.absent(),
    this.tipo = const Value.absent(),
    this.archivo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamenesCompanion.insert({
    required String id,
    required String gestion,
    required String tipo,
    required String archivo,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gestion = Value(gestion),
       tipo = Value(tipo),
       archivo = Value(archivo);
  static Insertable<Examen> custom({
    Expression<String>? id,
    Expression<String>? gestion,
    Expression<String>? tipo,
    Expression<String>? archivo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gestion != null) 'gestion': gestion,
      if (tipo != null) 'tipo': tipo,
      if (archivo != null) 'archivo': archivo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamenesCompanion copyWith({
    Value<String>? id,
    Value<String>? gestion,
    Value<String>? tipo,
    Value<String>? archivo,
    Value<int>? rowid,
  }) {
    return ExamenesCompanion(
      id: id ?? this.id,
      gestion: gestion ?? this.gestion,
      tipo: tipo ?? this.tipo,
      archivo: archivo ?? this.archivo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gestion.present) {
      map['gestion'] = Variable<String>(gestion.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (archivo.present) {
      map['archivo'] = Variable<String>(archivo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamenesCompanion(')
          ..write('id: $id, ')
          ..write('gestion: $gestion, ')
          ..write('tipo: $tipo, ')
          ..write('archivo: $archivo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemasTable extends Temas with TableInfo<$TemasTable, Tema> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _materiaMeta = const VerificationMeta(
    'materia',
  );
  @override
  late final GeneratedColumn<String> materia = GeneratedColumn<String>(
    'materia',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, materia, nombre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'temas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tema> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('materia')) {
      context.handle(
        _materiaMeta,
        materia.isAcceptableOrUnknown(data['materia']!, _materiaMeta),
      );
    } else if (isInserting) {
      context.missing(_materiaMeta);
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {materia, nombre},
  ];
  @override
  Tema map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tema(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      materia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}materia'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
    );
  }

  @override
  $TemasTable createAlias(String alias) {
    return $TemasTable(attachedDatabase, alias);
  }
}

class Tema extends DataClass implements Insertable<Tema> {
  final String id;
  final String materia;
  final String nombre;
  const Tema({required this.id, required this.materia, required this.nombre});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['materia'] = Variable<String>(materia);
    map['nombre'] = Variable<String>(nombre);
    return map;
  }

  TemasCompanion toCompanion(bool nullToAbsent) {
    return TemasCompanion(
      id: Value(id),
      materia: Value(materia),
      nombre: Value(nombre),
    );
  }

  factory Tema.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tema(
      id: serializer.fromJson<String>(json['id']),
      materia: serializer.fromJson<String>(json['materia']),
      nombre: serializer.fromJson<String>(json['nombre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'materia': serializer.toJson<String>(materia),
      'nombre': serializer.toJson<String>(nombre),
    };
  }

  Tema copyWith({String? id, String? materia, String? nombre}) => Tema(
    id: id ?? this.id,
    materia: materia ?? this.materia,
    nombre: nombre ?? this.nombre,
  );
  Tema copyWithCompanion(TemasCompanion data) {
    return Tema(
      id: data.id.present ? data.id.value : this.id,
      materia: data.materia.present ? data.materia.value : this.materia,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tema(')
          ..write('id: $id, ')
          ..write('materia: $materia, ')
          ..write('nombre: $nombre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, materia, nombre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tema &&
          other.id == this.id &&
          other.materia == this.materia &&
          other.nombre == this.nombre);
}

class TemasCompanion extends UpdateCompanion<Tema> {
  final Value<String> id;
  final Value<String> materia;
  final Value<String> nombre;
  final Value<int> rowid;
  const TemasCompanion({
    this.id = const Value.absent(),
    this.materia = const Value.absent(),
    this.nombre = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemasCompanion.insert({
    required String id,
    required String materia,
    required String nombre,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       materia = Value(materia),
       nombre = Value(nombre);
  static Insertable<Tema> custom({
    Expression<String>? id,
    Expression<String>? materia,
    Expression<String>? nombre,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (materia != null) 'materia': materia,
      if (nombre != null) 'nombre': nombre,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemasCompanion copyWith({
    Value<String>? id,
    Value<String>? materia,
    Value<String>? nombre,
    Value<int>? rowid,
  }) {
    return TemasCompanion(
      id: id ?? this.id,
      materia: materia ?? this.materia,
      nombre: nombre ?? this.nombre,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (materia.present) {
      map['materia'] = Variable<String>(materia.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemasCompanion(')
          ..write('id: $id, ')
          ..write('materia: $materia, ')
          ..write('nombre: $nombre, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreguntasTable extends Preguntas
    with TableInfo<$PreguntasTable, Pregunta> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreguntasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examenIdMeta = const VerificationMeta(
    'examenId',
  );
  @override
  late final GeneratedColumn<String> examenId = GeneratedColumn<String>(
    'examen_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES examenes (id)',
    ),
  );
  static const VerificationMeta _codigoMeta = const VerificationMeta('codigo');
  @override
  late final GeneratedColumn<String> codigo = GeneratedColumn<String>(
    'codigo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temaIdMeta = const VerificationMeta('temaId');
  @override
  late final GeneratedColumn<String> temaId = GeneratedColumn<String>(
    'tema_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES temas (id)',
    ),
  );
  static const VerificationMeta _enunciadoMeta = const VerificationMeta(
    'enunciado',
  );
  @override
  late final GeneratedColumn<String> enunciado = GeneratedColumn<String>(
    'enunciado',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>, String> opciones =
      GeneratedColumn<String>(
        'opciones',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<List<String>>($PreguntasTable.$converteropciones);
  static const VerificationMeta _respuestaMeta = const VerificationMeta(
    'respuesta',
  );
  @override
  late final GeneratedColumn<String> respuesta = GeneratedColumn<String>(
    'respuesta',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _explicacionMeta = const VerificationMeta(
    'explicacion',
  );
  @override
  late final GeneratedColumn<String> explicacion = GeneratedColumn<String>(
    'explicacion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rutaImagenMeta = const VerificationMeta(
    'rutaImagen',
  );
  @override
  late final GeneratedColumn<String> rutaImagen = GeneratedColumn<String>(
    'ruta_imagen',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fuenteMeta = const VerificationMeta('fuente');
  @override
  late final GeneratedColumn<String> fuente = GeneratedColumn<String>(
    'fuente',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examenId,
    codigo,
    temaId,
    enunciado,
    opciones,
    respuesta,
    explicacion,
    rutaImagen,
    fuente,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'preguntas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Pregunta> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('examen_id')) {
      context.handle(
        _examenIdMeta,
        examenId.isAcceptableOrUnknown(data['examen_id']!, _examenIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examenIdMeta);
    }
    if (data.containsKey('codigo')) {
      context.handle(
        _codigoMeta,
        codigo.isAcceptableOrUnknown(data['codigo']!, _codigoMeta),
      );
    } else if (isInserting) {
      context.missing(_codigoMeta);
    }
    if (data.containsKey('tema_id')) {
      context.handle(
        _temaIdMeta,
        temaId.isAcceptableOrUnknown(data['tema_id']!, _temaIdMeta),
      );
    }
    if (data.containsKey('enunciado')) {
      context.handle(
        _enunciadoMeta,
        enunciado.isAcceptableOrUnknown(data['enunciado']!, _enunciadoMeta),
      );
    } else if (isInserting) {
      context.missing(_enunciadoMeta);
    }
    if (data.containsKey('respuesta')) {
      context.handle(
        _respuestaMeta,
        respuesta.isAcceptableOrUnknown(data['respuesta']!, _respuestaMeta),
      );
    } else if (isInserting) {
      context.missing(_respuestaMeta);
    }
    if (data.containsKey('explicacion')) {
      context.handle(
        _explicacionMeta,
        explicacion.isAcceptableOrUnknown(
          data['explicacion']!,
          _explicacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_explicacionMeta);
    }
    if (data.containsKey('ruta_imagen')) {
      context.handle(
        _rutaImagenMeta,
        rutaImagen.isAcceptableOrUnknown(data['ruta_imagen']!, _rutaImagenMeta),
      );
    }
    if (data.containsKey('fuente')) {
      context.handle(
        _fuenteMeta,
        fuente.isAcceptableOrUnknown(data['fuente']!, _fuenteMeta),
      );
    } else if (isInserting) {
      context.missing(_fuenteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {examenId, codigo},
  ];
  @override
  Pregunta map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Pregunta(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      examenId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examen_id'],
      )!,
      codigo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo'],
      )!,
      temaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tema_id'],
      ),
      enunciado: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}enunciado'],
      )!,
      opciones: $PreguntasTable.$converteropciones.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}opciones'],
        )!,
      ),
      respuesta: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}respuesta'],
      )!,
      explicacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}explicacion'],
      )!,
      rutaImagen: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ruta_imagen'],
      ),
      fuente: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fuente'],
      )!,
    );
  }

  @override
  $PreguntasTable createAlias(String alias) {
    return $PreguntasTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $converteropciones =
      const OpcionesConverter();
}

class Pregunta extends DataClass implements Insertable<Pregunta> {
  final String id;
  final String examenId;
  final String codigo;
  final String? temaId;
  final String enunciado;
  final List<String> opciones;
  final String respuesta;
  final String explicacion;
  final String? rutaImagen;
  final String fuente;
  const Pregunta({
    required this.id,
    required this.examenId,
    required this.codigo,
    this.temaId,
    required this.enunciado,
    required this.opciones,
    required this.respuesta,
    required this.explicacion,
    this.rutaImagen,
    required this.fuente,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['examen_id'] = Variable<String>(examenId);
    map['codigo'] = Variable<String>(codigo);
    if (!nullToAbsent || temaId != null) {
      map['tema_id'] = Variable<String>(temaId);
    }
    map['enunciado'] = Variable<String>(enunciado);
    {
      map['opciones'] = Variable<String>(
        $PreguntasTable.$converteropciones.toSql(opciones),
      );
    }
    map['respuesta'] = Variable<String>(respuesta);
    map['explicacion'] = Variable<String>(explicacion);
    if (!nullToAbsent || rutaImagen != null) {
      map['ruta_imagen'] = Variable<String>(rutaImagen);
    }
    map['fuente'] = Variable<String>(fuente);
    return map;
  }

  PreguntasCompanion toCompanion(bool nullToAbsent) {
    return PreguntasCompanion(
      id: Value(id),
      examenId: Value(examenId),
      codigo: Value(codigo),
      temaId: temaId == null && nullToAbsent
          ? const Value.absent()
          : Value(temaId),
      enunciado: Value(enunciado),
      opciones: Value(opciones),
      respuesta: Value(respuesta),
      explicacion: Value(explicacion),
      rutaImagen: rutaImagen == null && nullToAbsent
          ? const Value.absent()
          : Value(rutaImagen),
      fuente: Value(fuente),
    );
  }

  factory Pregunta.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Pregunta(
      id: serializer.fromJson<String>(json['id']),
      examenId: serializer.fromJson<String>(json['examenId']),
      codigo: serializer.fromJson<String>(json['codigo']),
      temaId: serializer.fromJson<String?>(json['temaId']),
      enunciado: serializer.fromJson<String>(json['enunciado']),
      opciones: serializer.fromJson<List<String>>(json['opciones']),
      respuesta: serializer.fromJson<String>(json['respuesta']),
      explicacion: serializer.fromJson<String>(json['explicacion']),
      rutaImagen: serializer.fromJson<String?>(json['rutaImagen']),
      fuente: serializer.fromJson<String>(json['fuente']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'examenId': serializer.toJson<String>(examenId),
      'codigo': serializer.toJson<String>(codigo),
      'temaId': serializer.toJson<String?>(temaId),
      'enunciado': serializer.toJson<String>(enunciado),
      'opciones': serializer.toJson<List<String>>(opciones),
      'respuesta': serializer.toJson<String>(respuesta),
      'explicacion': serializer.toJson<String>(explicacion),
      'rutaImagen': serializer.toJson<String?>(rutaImagen),
      'fuente': serializer.toJson<String>(fuente),
    };
  }

  Pregunta copyWith({
    String? id,
    String? examenId,
    String? codigo,
    Value<String?> temaId = const Value.absent(),
    String? enunciado,
    List<String>? opciones,
    String? respuesta,
    String? explicacion,
    Value<String?> rutaImagen = const Value.absent(),
    String? fuente,
  }) => Pregunta(
    id: id ?? this.id,
    examenId: examenId ?? this.examenId,
    codigo: codigo ?? this.codigo,
    temaId: temaId.present ? temaId.value : this.temaId,
    enunciado: enunciado ?? this.enunciado,
    opciones: opciones ?? this.opciones,
    respuesta: respuesta ?? this.respuesta,
    explicacion: explicacion ?? this.explicacion,
    rutaImagen: rutaImagen.present ? rutaImagen.value : this.rutaImagen,
    fuente: fuente ?? this.fuente,
  );
  Pregunta copyWithCompanion(PreguntasCompanion data) {
    return Pregunta(
      id: data.id.present ? data.id.value : this.id,
      examenId: data.examenId.present ? data.examenId.value : this.examenId,
      codigo: data.codigo.present ? data.codigo.value : this.codigo,
      temaId: data.temaId.present ? data.temaId.value : this.temaId,
      enunciado: data.enunciado.present ? data.enunciado.value : this.enunciado,
      opciones: data.opciones.present ? data.opciones.value : this.opciones,
      respuesta: data.respuesta.present ? data.respuesta.value : this.respuesta,
      explicacion: data.explicacion.present
          ? data.explicacion.value
          : this.explicacion,
      rutaImagen: data.rutaImagen.present
          ? data.rutaImagen.value
          : this.rutaImagen,
      fuente: data.fuente.present ? data.fuente.value : this.fuente,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Pregunta(')
          ..write('id: $id, ')
          ..write('examenId: $examenId, ')
          ..write('codigo: $codigo, ')
          ..write('temaId: $temaId, ')
          ..write('enunciado: $enunciado, ')
          ..write('opciones: $opciones, ')
          ..write('respuesta: $respuesta, ')
          ..write('explicacion: $explicacion, ')
          ..write('rutaImagen: $rutaImagen, ')
          ..write('fuente: $fuente')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examenId,
    codigo,
    temaId,
    enunciado,
    opciones,
    respuesta,
    explicacion,
    rutaImagen,
    fuente,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Pregunta &&
          other.id == this.id &&
          other.examenId == this.examenId &&
          other.codigo == this.codigo &&
          other.temaId == this.temaId &&
          other.enunciado == this.enunciado &&
          other.opciones == this.opciones &&
          other.respuesta == this.respuesta &&
          other.explicacion == this.explicacion &&
          other.rutaImagen == this.rutaImagen &&
          other.fuente == this.fuente);
}

class PreguntasCompanion extends UpdateCompanion<Pregunta> {
  final Value<String> id;
  final Value<String> examenId;
  final Value<String> codigo;
  final Value<String?> temaId;
  final Value<String> enunciado;
  final Value<List<String>> opciones;
  final Value<String> respuesta;
  final Value<String> explicacion;
  final Value<String?> rutaImagen;
  final Value<String> fuente;
  final Value<int> rowid;
  const PreguntasCompanion({
    this.id = const Value.absent(),
    this.examenId = const Value.absent(),
    this.codigo = const Value.absent(),
    this.temaId = const Value.absent(),
    this.enunciado = const Value.absent(),
    this.opciones = const Value.absent(),
    this.respuesta = const Value.absent(),
    this.explicacion = const Value.absent(),
    this.rutaImagen = const Value.absent(),
    this.fuente = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreguntasCompanion.insert({
    required String id,
    required String examenId,
    required String codigo,
    this.temaId = const Value.absent(),
    required String enunciado,
    required List<String> opciones,
    required String respuesta,
    required String explicacion,
    this.rutaImagen = const Value.absent(),
    required String fuente,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       examenId = Value(examenId),
       codigo = Value(codigo),
       enunciado = Value(enunciado),
       opciones = Value(opciones),
       respuesta = Value(respuesta),
       explicacion = Value(explicacion),
       fuente = Value(fuente);
  static Insertable<Pregunta> custom({
    Expression<String>? id,
    Expression<String>? examenId,
    Expression<String>? codigo,
    Expression<String>? temaId,
    Expression<String>? enunciado,
    Expression<String>? opciones,
    Expression<String>? respuesta,
    Expression<String>? explicacion,
    Expression<String>? rutaImagen,
    Expression<String>? fuente,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examenId != null) 'examen_id': examenId,
      if (codigo != null) 'codigo': codigo,
      if (temaId != null) 'tema_id': temaId,
      if (enunciado != null) 'enunciado': enunciado,
      if (opciones != null) 'opciones': opciones,
      if (respuesta != null) 'respuesta': respuesta,
      if (explicacion != null) 'explicacion': explicacion,
      if (rutaImagen != null) 'ruta_imagen': rutaImagen,
      if (fuente != null) 'fuente': fuente,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreguntasCompanion copyWith({
    Value<String>? id,
    Value<String>? examenId,
    Value<String>? codigo,
    Value<String?>? temaId,
    Value<String>? enunciado,
    Value<List<String>>? opciones,
    Value<String>? respuesta,
    Value<String>? explicacion,
    Value<String?>? rutaImagen,
    Value<String>? fuente,
    Value<int>? rowid,
  }) {
    return PreguntasCompanion(
      id: id ?? this.id,
      examenId: examenId ?? this.examenId,
      codigo: codigo ?? this.codigo,
      temaId: temaId ?? this.temaId,
      enunciado: enunciado ?? this.enunciado,
      opciones: opciones ?? this.opciones,
      respuesta: respuesta ?? this.respuesta,
      explicacion: explicacion ?? this.explicacion,
      rutaImagen: rutaImagen ?? this.rutaImagen,
      fuente: fuente ?? this.fuente,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (examenId.present) {
      map['examen_id'] = Variable<String>(examenId.value);
    }
    if (codigo.present) {
      map['codigo'] = Variable<String>(codigo.value);
    }
    if (temaId.present) {
      map['tema_id'] = Variable<String>(temaId.value);
    }
    if (enunciado.present) {
      map['enunciado'] = Variable<String>(enunciado.value);
    }
    if (opciones.present) {
      map['opciones'] = Variable<String>(
        $PreguntasTable.$converteropciones.toSql(opciones.value),
      );
    }
    if (respuesta.present) {
      map['respuesta'] = Variable<String>(respuesta.value);
    }
    if (explicacion.present) {
      map['explicacion'] = Variable<String>(explicacion.value);
    }
    if (rutaImagen.present) {
      map['ruta_imagen'] = Variable<String>(rutaImagen.value);
    }
    if (fuente.present) {
      map['fuente'] = Variable<String>(fuente.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreguntasCompanion(')
          ..write('id: $id, ')
          ..write('examenId: $examenId, ')
          ..write('codigo: $codigo, ')
          ..write('temaId: $temaId, ')
          ..write('enunciado: $enunciado, ')
          ..write('opciones: $opciones, ')
          ..write('respuesta: $respuesta, ')
          ..write('explicacion: $explicacion, ')
          ..write('rutaImagen: $rutaImagen, ')
          ..write('fuente: $fuente, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExamenesTable examenes = $ExamenesTable(this);
  late final $TemasTable temas = $TemasTable(this);
  late final $PreguntasTable preguntas = $PreguntasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    examenes,
    temas,
    preguntas,
  ];
}

typedef $$ExamenesTableCreateCompanionBuilder = ExamenesCompanion Function({
  required String id,
  required String gestion,
  required String tipo,
  required String archivo,
  Value<int> rowid,
});
typedef $$ExamenesTableUpdateCompanionBuilder = ExamenesCompanion Function({
  Value<String> id,
  Value<String> gestion,
  Value<String> tipo,
  Value<String> archivo,
  Value<int> rowid,
});

final class $$ExamenesTableReferences
    extends BaseReferences<_$AppDatabase, $ExamenesTable, Examen> {
  $$ExamenesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PreguntasTable, List<Pregunta>>
  _preguntasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.preguntas,
    aliasName: 'examenes__id__preguntas__examen_id',
  );

  $$PreguntasTableProcessedTableManager get preguntasRefs {
    final manager = $$PreguntasTableTableManager(
      $_db,
      $_db.preguntas,
    ).filter((f) => f.examenId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_preguntasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamenesTableFilterComposer
    extends Composer<_$AppDatabase, $ExamenesTable> {
  $$ExamenesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gestion => $composableBuilder(
    column: $table.gestion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archivo => $composableBuilder(
    column: $table.archivo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> preguntasRefs(
    Expression<bool> Function($$PreguntasTableFilterComposer f) f,
  ) {
    final $$PreguntasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.examenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasTableFilterComposer(
            $db: $db,
            $table: $db.preguntas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamenesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamenesTable> {
  $$ExamenesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gestion => $composableBuilder(
    column: $table.gestion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archivo => $composableBuilder(
    column: $table.archivo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamenesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamenesTable> {
  $$ExamenesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get gestion =>
      $composableBuilder(column: $table.gestion, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<String> get archivo =>
      $composableBuilder(column: $table.archivo, builder: (column) => column);

  Expression<T> preguntasRefs<T extends Object>(
    Expression<T> Function($$PreguntasTableAnnotationComposer a) f,
  ) {
    final $$PreguntasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.examenId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasTableAnnotationComposer(
            $db: $db,
            $table: $db.preguntas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamenesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamenesTable,
          Examen,
          $$ExamenesTableFilterComposer,
          $$ExamenesTableOrderingComposer,
          $$ExamenesTableAnnotationComposer,
          $$ExamenesTableCreateCompanionBuilder,
          $$ExamenesTableUpdateCompanionBuilder,
          (Examen, $$ExamenesTableReferences),
          Examen,
          PrefetchHooks Function({bool preguntasRefs})
        > {
  $$ExamenesTableTableManager(_$AppDatabase db, $ExamenesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamenesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamenesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamenesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gestion = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<String> archivo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamenesCompanion(
                id: id,
                gestion: gestion,
                tipo: tipo,
                archivo: archivo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gestion,
                required String tipo,
                required String archivo,
                Value<int> rowid = const Value.absent(),
              }) => ExamenesCompanion.insert(
                id: id,
                gestion: gestion,
                tipo: tipo,
                archivo: archivo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExamenesTable, Examen>(table),
                  $$ExamenesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({preguntasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (preguntasRefs) db.preguntas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (preguntasRefs)
                    await $_getPrefetchedDataByColumns<
                      Examen,
                      $ExamenesTable,
                      Pregunta,
                      $PreguntasTable
                    >(
                      currentTable: table,
                      referencedTable: $$ExamenesTableReferences
                          ._preguntasRefsTable(db),
                      managerFromTypedResult: (p0) => $$ExamenesTableReferences(
                        db,
                        table,
                        p0,
                      ).preguntasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'examen_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExamenesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamenesTable,
      Examen,
      $$ExamenesTableFilterComposer,
      $$ExamenesTableOrderingComposer,
      $$ExamenesTableAnnotationComposer,
      $$ExamenesTableCreateCompanionBuilder,
      $$ExamenesTableUpdateCompanionBuilder,
      (Examen, $$ExamenesTableReferences),
      Examen,
      PrefetchHooks Function({bool preguntasRefs})
    >;
typedef $$TemasTableCreateCompanionBuilder = TemasCompanion Function({
  required String id,
  required String materia,
  required String nombre,
  Value<int> rowid,
});
typedef $$TemasTableUpdateCompanionBuilder = TemasCompanion Function({
  Value<String> id,
  Value<String> materia,
  Value<String> nombre,
  Value<int> rowid,
});

final class $$TemasTableReferences
    extends BaseReferences<_$AppDatabase, $TemasTable, Tema> {
  $$TemasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PreguntasTable, List<Pregunta>>
  _preguntasRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.preguntas,
    aliasName: 'temas__id__preguntas__tema_id',
  );

  $$PreguntasTableProcessedTableManager get preguntasRefs {
    final manager = $$PreguntasTableTableManager(
      $_db,
      $_db.preguntas,
    ).filter((f) => f.temaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_preguntasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TemasTableFilterComposer extends Composer<_$AppDatabase, $TemasTable> {
  $$TemasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materia => $composableBuilder(
    column: $table.materia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> preguntasRefs(
    Expression<bool> Function($$PreguntasTableFilterComposer f) f,
  ) {
    final $$PreguntasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.temaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasTableFilterComposer(
            $db: $db,
            $table: $db.preguntas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TemasTableOrderingComposer
    extends Composer<_$AppDatabase, $TemasTable> {
  $$TemasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materia => $composableBuilder(
    column: $table.materia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemasTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemasTable> {
  $$TemasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get materia =>
      $composableBuilder(column: $table.materia, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  Expression<T> preguntasRefs<T extends Object>(
    Expression<T> Function($$PreguntasTableAnnotationComposer a) f,
  ) {
    final $$PreguntasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.temaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasTableAnnotationComposer(
            $db: $db,
            $table: $db.preguntas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TemasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemasTable,
          Tema,
          $$TemasTableFilterComposer,
          $$TemasTableOrderingComposer,
          $$TemasTableAnnotationComposer,
          $$TemasTableCreateCompanionBuilder,
          $$TemasTableUpdateCompanionBuilder,
          (Tema, $$TemasTableReferences),
          Tema,
          PrefetchHooks Function({bool preguntasRefs})
        > {
  $$TemasTableTableManager(_$AppDatabase db, $TemasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> materia = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemasCompanion(
                id: id,
                materia: materia,
                nombre: nombre,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String materia,
                required String nombre,
                Value<int> rowid = const Value.absent(),
              }) => TemasCompanion.insert(
                id: id,
                materia: materia,
                nombre: nombre,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TemasTable, Tema>(table),
                  $$TemasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({preguntasRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (preguntasRefs) db.preguntas],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (preguntasRefs)
                    await $_getPrefetchedDataByColumns<
                      Tema,
                      $TemasTable,
                      Pregunta,
                      $PreguntasTable
                    >(
                      currentTable: table,
                      referencedTable: $$TemasTableReferences
                          ._preguntasRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TemasTableReferences(db, table, p0).preguntasRefs,
                      currentColumn: 'id',
                      referencedColumn: 'tema_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TemasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemasTable,
      Tema,
      $$TemasTableFilterComposer,
      $$TemasTableOrderingComposer,
      $$TemasTableAnnotationComposer,
      $$TemasTableCreateCompanionBuilder,
      $$TemasTableUpdateCompanionBuilder,
      (Tema, $$TemasTableReferences),
      Tema,
      PrefetchHooks Function({bool preguntasRefs})
    >;
typedef $$PreguntasTableCreateCompanionBuilder = PreguntasCompanion Function({
  required String id,
  required String examenId,
  required String codigo,
  Value<String?> temaId,
  required String enunciado,
  required List<String> opciones,
  required String respuesta,
  required String explicacion,
  Value<String?> rutaImagen,
  required String fuente,
  Value<int> rowid,
});
typedef $$PreguntasTableUpdateCompanionBuilder = PreguntasCompanion Function({
  Value<String> id,
  Value<String> examenId,
  Value<String> codigo,
  Value<String?> temaId,
  Value<String> enunciado,
  Value<List<String>> opciones,
  Value<String> respuesta,
  Value<String> explicacion,
  Value<String?> rutaImagen,
  Value<String> fuente,
  Value<int> rowid,
});

final class $$PreguntasTableReferences
    extends BaseReferences<_$AppDatabase, $PreguntasTable, Pregunta> {
  $$PreguntasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamenesTable _examenIdTable(_$AppDatabase db) =>
      db.examenes.createAlias('preguntas__examen_id__examenes__id');

  $$ExamenesTableProcessedTableManager get examenId {
    final $_column = $_itemColumn<String>('examen_id')!;

    final manager = $$ExamenesTableTableManager(
      $_db,
      $_db.examenes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examenIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TemasTable _temaIdTable(_$AppDatabase db) =>
      db.temas.createAlias('preguntas__tema_id__temas__id');

  $$TemasTableProcessedTableManager? get temaId {
    final $_column = $_itemColumn<String>('tema_id');
    if ($_column == null) return null;
    final manager = $$TemasTableTableManager(
      $_db,
      $_db.temas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_temaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PreguntasTableFilterComposer
    extends Composer<_$AppDatabase, $PreguntasTable> {
  $$PreguntasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get enunciado => $composableBuilder(
    column: $table.enunciado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>, List<String>, String>
  get opciones => $composableBuilder(
    column: $table.opciones,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get respuesta => $composableBuilder(
    column: $table.respuesta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get explicacion => $composableBuilder(
    column: $table.explicacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rutaImagen => $composableBuilder(
    column: $table.rutaImagen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fuente => $composableBuilder(
    column: $table.fuente,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamenesTableFilterComposer get examenId {
    final $$ExamenesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examenId,
      referencedTable: $db.examenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamenesTableFilterComposer(
            $db: $db,
            $table: $db.examenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TemasTableFilterComposer get temaId {
    final $$TemasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.temaId,
      referencedTable: $db.temas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemasTableFilterComposer(
            $db: $db,
            $table: $db.temas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreguntasTableOrderingComposer
    extends Composer<_$AppDatabase, $PreguntasTable> {
  $$PreguntasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codigo => $composableBuilder(
    column: $table.codigo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get enunciado => $composableBuilder(
    column: $table.enunciado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opciones => $composableBuilder(
    column: $table.opciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get respuesta => $composableBuilder(
    column: $table.respuesta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get explicacion => $composableBuilder(
    column: $table.explicacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rutaImagen => $composableBuilder(
    column: $table.rutaImagen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fuente => $composableBuilder(
    column: $table.fuente,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamenesTableOrderingComposer get examenId {
    final $$ExamenesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examenId,
      referencedTable: $db.examenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamenesTableOrderingComposer(
            $db: $db,
            $table: $db.examenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TemasTableOrderingComposer get temaId {
    final $$TemasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.temaId,
      referencedTable: $db.temas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemasTableOrderingComposer(
            $db: $db,
            $table: $db.temas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreguntasTableAnnotationComposer
    extends Composer<_$AppDatabase, $PreguntasTable> {
  $$PreguntasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigo =>
      $composableBuilder(column: $table.codigo, builder: (column) => column);

  GeneratedColumn<String> get enunciado =>
      $composableBuilder(column: $table.enunciado, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>, String> get opciones =>
      $composableBuilder(column: $table.opciones, builder: (column) => column);

  GeneratedColumn<String> get respuesta =>
      $composableBuilder(column: $table.respuesta, builder: (column) => column);

  GeneratedColumn<String> get explicacion => $composableBuilder(
    column: $table.explicacion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rutaImagen => $composableBuilder(
    column: $table.rutaImagen,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fuente =>
      $composableBuilder(column: $table.fuente, builder: (column) => column);

  $$ExamenesTableAnnotationComposer get examenId {
    final $$ExamenesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examenId,
      referencedTable: $db.examenes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamenesTableAnnotationComposer(
            $db: $db,
            $table: $db.examenes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TemasTableAnnotationComposer get temaId {
    final $$TemasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.temaId,
      referencedTable: $db.temas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemasTableAnnotationComposer(
            $db: $db,
            $table: $db.temas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PreguntasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PreguntasTable,
          Pregunta,
          $$PreguntasTableFilterComposer,
          $$PreguntasTableOrderingComposer,
          $$PreguntasTableAnnotationComposer,
          $$PreguntasTableCreateCompanionBuilder,
          $$PreguntasTableUpdateCompanionBuilder,
          (Pregunta, $$PreguntasTableReferences),
          Pregunta,
          PrefetchHooks Function({bool examenId, bool temaId})
        > {
  $$PreguntasTableTableManager(_$AppDatabase db, $PreguntasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreguntasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreguntasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreguntasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> examenId = const Value.absent(),
                Value<String> codigo = const Value.absent(),
                Value<String?> temaId = const Value.absent(),
                Value<String> enunciado = const Value.absent(),
                Value<List<String>> opciones = const Value.absent(),
                Value<String> respuesta = const Value.absent(),
                Value<String> explicacion = const Value.absent(),
                Value<String?> rutaImagen = const Value.absent(),
                Value<String> fuente = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreguntasCompanion(
                id: id,
                examenId: examenId,
                codigo: codigo,
                temaId: temaId,
                enunciado: enunciado,
                opciones: opciones,
                respuesta: respuesta,
                explicacion: explicacion,
                rutaImagen: rutaImagen,
                fuente: fuente,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String examenId,
                required String codigo,
                Value<String?> temaId = const Value.absent(),
                required String enunciado,
                required List<String> opciones,
                required String respuesta,
                required String explicacion,
                Value<String?> rutaImagen = const Value.absent(),
                required String fuente,
                Value<int> rowid = const Value.absent(),
              }) => PreguntasCompanion.insert(
                id: id,
                examenId: examenId,
                codigo: codigo,
                temaId: temaId,
                enunciado: enunciado,
                opciones: opciones,
                respuesta: respuesta,
                explicacion: explicacion,
                rutaImagen: rutaImagen,
                fuente: fuente,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreguntasTable, Pregunta>(table),
                  $$PreguntasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({examenId = false, temaId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (examenId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.examenId,
                        referencedTable: $$PreguntasTableReferences
                            ._examenIdTable(db),
                        referencedColumn: $$PreguntasTableReferences
                            ._examenIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (temaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.temaId,
                        referencedTable: $$PreguntasTableReferences
                            ._temaIdTable(db),
                        referencedColumn: $$PreguntasTableReferences
                            ._temaIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PreguntasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PreguntasTable,
      Pregunta,
      $$PreguntasTableFilterComposer,
      $$PreguntasTableOrderingComposer,
      $$PreguntasTableAnnotationComposer,
      $$PreguntasTableCreateCompanionBuilder,
      $$PreguntasTableUpdateCompanionBuilder,
      (Pregunta, $$PreguntasTableReferences),
      Pregunta,
      PrefetchHooks Function({bool examenId, bool temaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExamenesTableTableManager get examenes =>
      $$ExamenesTableTableManager(_db, _db.examenes);
  $$TemasTableTableManager get temas =>
      $$TemasTableTableManager(_db, _db.temas);
  $$PreguntasTableTableManager get preguntas =>
      $$PreguntasTableTableManager(_db, _db.preguntas);
}

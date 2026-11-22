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

class $TarjetasFsrsTable extends TarjetasFsrs
    with TableInfo<$TarjetasFsrsTable, TarjetaFsrs> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TarjetasFsrsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _preguntaIdMeta = const VerificationMeta(
    'preguntaId',
  );
  @override
  late final GeneratedColumn<String> preguntaId = GeneratedColumn<String>(
    'pregunta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES preguntas (id)',
    ),
  );
  static const VerificationMeta _estadoMeta = const VerificationMeta('estado');
  @override
  late final GeneratedColumn<int> estado = GeneratedColumn<int>(
    'estado',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pasoMeta = const VerificationMeta('paso');
  @override
  late final GeneratedColumn<int> paso = GeneratedColumn<int>(
    'paso',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estabilidadMeta = const VerificationMeta(
    'estabilidad',
  );
  @override
  late final GeneratedColumn<double> estabilidad = GeneratedColumn<double>(
    'estabilidad',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dificultadMeta = const VerificationMeta(
    'dificultad',
  );
  @override
  late final GeneratedColumn<double> dificultad = GeneratedColumn<double>(
    'dificultad',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _venceMeta = const VerificationMeta('vence');
  @override
  late final GeneratedColumn<DateTime> vence = GeneratedColumn<DateTime>(
    'vence',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ultimaRevisionMeta = const VerificationMeta(
    'ultimaRevision',
  );
  @override
  late final GeneratedColumn<DateTime> ultimaRevision =
      GeneratedColumn<DateTime>(
        'ultima_revision',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    preguntaId,
    estado,
    paso,
    estabilidad,
    dificultad,
    vence,
    ultimaRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tarjetas_fsrs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TarjetaFsrs> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('pregunta_id')) {
      context.handle(
        _preguntaIdMeta,
        preguntaId.isAcceptableOrUnknown(data['pregunta_id']!, _preguntaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_preguntaIdMeta);
    }
    if (data.containsKey('estado')) {
      context.handle(
        _estadoMeta,
        estado.isAcceptableOrUnknown(data['estado']!, _estadoMeta),
      );
    } else if (isInserting) {
      context.missing(_estadoMeta);
    }
    if (data.containsKey('paso')) {
      context.handle(
        _pasoMeta,
        paso.isAcceptableOrUnknown(data['paso']!, _pasoMeta),
      );
    }
    if (data.containsKey('estabilidad')) {
      context.handle(
        _estabilidadMeta,
        estabilidad.isAcceptableOrUnknown(
          data['estabilidad']!,
          _estabilidadMeta,
        ),
      );
    }
    if (data.containsKey('dificultad')) {
      context.handle(
        _dificultadMeta,
        dificultad.isAcceptableOrUnknown(data['dificultad']!, _dificultadMeta),
      );
    }
    if (data.containsKey('vence')) {
      context.handle(
        _venceMeta,
        vence.isAcceptableOrUnknown(data['vence']!, _venceMeta),
      );
    } else if (isInserting) {
      context.missing(_venceMeta);
    }
    if (data.containsKey('ultima_revision')) {
      context.handle(
        _ultimaRevisionMeta,
        ultimaRevision.isAcceptableOrUnknown(
          data['ultima_revision']!,
          _ultimaRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {preguntaId};
  @override
  TarjetaFsrs map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TarjetaFsrs(
      preguntaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pregunta_id'],
      )!,
      estado: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estado'],
      )!,
      paso: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}paso'],
      ),
      estabilidad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}estabilidad'],
      ),
      dificultad: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}dificultad'],
      ),
      vence: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}vence'],
      )!,
      ultimaRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ultima_revision'],
      ),
    );
  }

  @override
  $TarjetasFsrsTable createAlias(String alias) {
    return $TarjetasFsrsTable(attachedDatabase, alias);
  }
}

class TarjetaFsrs extends DataClass implements Insertable<TarjetaFsrs> {
  final String preguntaId;
  final int estado;
  final int? paso;
  final double? estabilidad;
  final double? dificultad;
  final DateTime vence;
  final DateTime? ultimaRevision;
  const TarjetaFsrs({
    required this.preguntaId,
    required this.estado,
    this.paso,
    this.estabilidad,
    this.dificultad,
    required this.vence,
    this.ultimaRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['pregunta_id'] = Variable<String>(preguntaId);
    map['estado'] = Variable<int>(estado);
    if (!nullToAbsent || paso != null) {
      map['paso'] = Variable<int>(paso);
    }
    if (!nullToAbsent || estabilidad != null) {
      map['estabilidad'] = Variable<double>(estabilidad);
    }
    if (!nullToAbsent || dificultad != null) {
      map['dificultad'] = Variable<double>(dificultad);
    }
    map['vence'] = Variable<DateTime>(vence);
    if (!nullToAbsent || ultimaRevision != null) {
      map['ultima_revision'] = Variable<DateTime>(ultimaRevision);
    }
    return map;
  }

  TarjetasFsrsCompanion toCompanion(bool nullToAbsent) {
    return TarjetasFsrsCompanion(
      preguntaId: Value(preguntaId),
      estado: Value(estado),
      paso: paso == null && nullToAbsent ? const Value.absent() : Value(paso),
      estabilidad: estabilidad == null && nullToAbsent
          ? const Value.absent()
          : Value(estabilidad),
      dificultad: dificultad == null && nullToAbsent
          ? const Value.absent()
          : Value(dificultad),
      vence: Value(vence),
      ultimaRevision: ultimaRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimaRevision),
    );
  }

  factory TarjetaFsrs.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TarjetaFsrs(
      preguntaId: serializer.fromJson<String>(json['preguntaId']),
      estado: serializer.fromJson<int>(json['estado']),
      paso: serializer.fromJson<int?>(json['paso']),
      estabilidad: serializer.fromJson<double?>(json['estabilidad']),
      dificultad: serializer.fromJson<double?>(json['dificultad']),
      vence: serializer.fromJson<DateTime>(json['vence']),
      ultimaRevision: serializer.fromJson<DateTime?>(json['ultimaRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'preguntaId': serializer.toJson<String>(preguntaId),
      'estado': serializer.toJson<int>(estado),
      'paso': serializer.toJson<int?>(paso),
      'estabilidad': serializer.toJson<double?>(estabilidad),
      'dificultad': serializer.toJson<double?>(dificultad),
      'vence': serializer.toJson<DateTime>(vence),
      'ultimaRevision': serializer.toJson<DateTime?>(ultimaRevision),
    };
  }

  TarjetaFsrs copyWith({
    String? preguntaId,
    int? estado,
    Value<int?> paso = const Value.absent(),
    Value<double?> estabilidad = const Value.absent(),
    Value<double?> dificultad = const Value.absent(),
    DateTime? vence,
    Value<DateTime?> ultimaRevision = const Value.absent(),
  }) => TarjetaFsrs(
    preguntaId: preguntaId ?? this.preguntaId,
    estado: estado ?? this.estado,
    paso: paso.present ? paso.value : this.paso,
    estabilidad: estabilidad.present ? estabilidad.value : this.estabilidad,
    dificultad: dificultad.present ? dificultad.value : this.dificultad,
    vence: vence ?? this.vence,
    ultimaRevision: ultimaRevision.present
        ? ultimaRevision.value
        : this.ultimaRevision,
  );
  TarjetaFsrs copyWithCompanion(TarjetasFsrsCompanion data) {
    return TarjetaFsrs(
      preguntaId: data.preguntaId.present
          ? data.preguntaId.value
          : this.preguntaId,
      estado: data.estado.present ? data.estado.value : this.estado,
      paso: data.paso.present ? data.paso.value : this.paso,
      estabilidad: data.estabilidad.present
          ? data.estabilidad.value
          : this.estabilidad,
      dificultad: data.dificultad.present
          ? data.dificultad.value
          : this.dificultad,
      vence: data.vence.present ? data.vence.value : this.vence,
      ultimaRevision: data.ultimaRevision.present
          ? data.ultimaRevision.value
          : this.ultimaRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TarjetaFsrs(')
          ..write('preguntaId: $preguntaId, ')
          ..write('estado: $estado, ')
          ..write('paso: $paso, ')
          ..write('estabilidad: $estabilidad, ')
          ..write('dificultad: $dificultad, ')
          ..write('vence: $vence, ')
          ..write('ultimaRevision: $ultimaRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    preguntaId,
    estado,
    paso,
    estabilidad,
    dificultad,
    vence,
    ultimaRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TarjetaFsrs &&
          other.preguntaId == this.preguntaId &&
          other.estado == this.estado &&
          other.paso == this.paso &&
          other.estabilidad == this.estabilidad &&
          other.dificultad == this.dificultad &&
          other.vence == this.vence &&
          other.ultimaRevision == this.ultimaRevision);
}

class TarjetasFsrsCompanion extends UpdateCompanion<TarjetaFsrs> {
  final Value<String> preguntaId;
  final Value<int> estado;
  final Value<int?> paso;
  final Value<double?> estabilidad;
  final Value<double?> dificultad;
  final Value<DateTime> vence;
  final Value<DateTime?> ultimaRevision;
  final Value<int> rowid;
  const TarjetasFsrsCompanion({
    this.preguntaId = const Value.absent(),
    this.estado = const Value.absent(),
    this.paso = const Value.absent(),
    this.estabilidad = const Value.absent(),
    this.dificultad = const Value.absent(),
    this.vence = const Value.absent(),
    this.ultimaRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TarjetasFsrsCompanion.insert({
    required String preguntaId,
    required int estado,
    this.paso = const Value.absent(),
    this.estabilidad = const Value.absent(),
    this.dificultad = const Value.absent(),
    required DateTime vence,
    this.ultimaRevision = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : preguntaId = Value(preguntaId),
       estado = Value(estado),
       vence = Value(vence);
  static Insertable<TarjetaFsrs> custom({
    Expression<String>? preguntaId,
    Expression<int>? estado,
    Expression<int>? paso,
    Expression<double>? estabilidad,
    Expression<double>? dificultad,
    Expression<DateTime>? vence,
    Expression<DateTime>? ultimaRevision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (preguntaId != null) 'pregunta_id': preguntaId,
      if (estado != null) 'estado': estado,
      if (paso != null) 'paso': paso,
      if (estabilidad != null) 'estabilidad': estabilidad,
      if (dificultad != null) 'dificultad': dificultad,
      if (vence != null) 'vence': vence,
      if (ultimaRevision != null) 'ultima_revision': ultimaRevision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TarjetasFsrsCompanion copyWith({
    Value<String>? preguntaId,
    Value<int>? estado,
    Value<int?>? paso,
    Value<double?>? estabilidad,
    Value<double?>? dificultad,
    Value<DateTime>? vence,
    Value<DateTime?>? ultimaRevision,
    Value<int>? rowid,
  }) {
    return TarjetasFsrsCompanion(
      preguntaId: preguntaId ?? this.preguntaId,
      estado: estado ?? this.estado,
      paso: paso ?? this.paso,
      estabilidad: estabilidad ?? this.estabilidad,
      dificultad: dificultad ?? this.dificultad,
      vence: vence ?? this.vence,
      ultimaRevision: ultimaRevision ?? this.ultimaRevision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (preguntaId.present) {
      map['pregunta_id'] = Variable<String>(preguntaId.value);
    }
    if (estado.present) {
      map['estado'] = Variable<int>(estado.value);
    }
    if (paso.present) {
      map['paso'] = Variable<int>(paso.value);
    }
    if (estabilidad.present) {
      map['estabilidad'] = Variable<double>(estabilidad.value);
    }
    if (dificultad.present) {
      map['dificultad'] = Variable<double>(dificultad.value);
    }
    if (vence.present) {
      map['vence'] = Variable<DateTime>(vence.value);
    }
    if (ultimaRevision.present) {
      map['ultima_revision'] = Variable<DateTime>(ultimaRevision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TarjetasFsrsCompanion(')
          ..write('preguntaId: $preguntaId, ')
          ..write('estado: $estado, ')
          ..write('paso: $paso, ')
          ..write('estabilidad: $estabilidad, ')
          ..write('dificultad: $dificultad, ')
          ..write('vence: $vence, ')
          ..write('ultimaRevision: $ultimaRevision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RespuestasLocalesTable extends RespuestasLocales
    with TableInfo<$RespuestasLocalesTable, RespuestaLocal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RespuestasLocalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idEventoMeta = const VerificationMeta(
    'idEvento',
  );
  @override
  late final GeneratedColumn<String> idEvento = GeneratedColumn<String>(
    'id_evento',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preguntaIdMeta = const VerificationMeta(
    'preguntaId',
  );
  @override
  late final GeneratedColumn<String> preguntaId = GeneratedColumn<String>(
    'pregunta_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES preguntas (id)',
    ),
  );
  static const VerificationMeta _opcionElegidaMeta = const VerificationMeta(
    'opcionElegida',
  );
  @override
  late final GeneratedColumn<String> opcionElegida = GeneratedColumn<String>(
    'opcion_elegida',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _esCorrectaMeta = const VerificationMeta(
    'esCorrecta',
  );
  @override
  late final GeneratedColumn<bool> esCorrecta = GeneratedColumn<bool>(
    'es_correcta',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("es_correcta" IN (0, 1))',
    ),
  );
  static const VerificationMeta _calificacionMeta = const VerificationMeta(
    'calificacion',
  );
  @override
  late final GeneratedColumn<int> calificacion = GeneratedColumn<int>(
    'calificacion',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tiempoMsMeta = const VerificationMeta(
    'tiempoMs',
  );
  @override
  late final GeneratedColumn<int> tiempoMs = GeneratedColumn<int>(
    'tiempo_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _respondidaEnMeta = const VerificationMeta(
    'respondidaEn',
  );
  @override
  late final GeneratedColumn<DateTime> respondidaEn = GeneratedColumn<DateTime>(
    'respondida_en',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    idEvento,
    preguntaId,
    opcionElegida,
    esCorrecta,
    calificacion,
    tiempoMs,
    respondidaEn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'respuestas_locales';
  @override
  VerificationContext validateIntegrity(
    Insertable<RespuestaLocal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id_evento')) {
      context.handle(
        _idEventoMeta,
        idEvento.isAcceptableOrUnknown(data['id_evento']!, _idEventoMeta),
      );
    } else if (isInserting) {
      context.missing(_idEventoMeta);
    }
    if (data.containsKey('pregunta_id')) {
      context.handle(
        _preguntaIdMeta,
        preguntaId.isAcceptableOrUnknown(data['pregunta_id']!, _preguntaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_preguntaIdMeta);
    }
    if (data.containsKey('opcion_elegida')) {
      context.handle(
        _opcionElegidaMeta,
        opcionElegida.isAcceptableOrUnknown(
          data['opcion_elegida']!,
          _opcionElegidaMeta,
        ),
      );
    }
    if (data.containsKey('es_correcta')) {
      context.handle(
        _esCorrectaMeta,
        esCorrecta.isAcceptableOrUnknown(data['es_correcta']!, _esCorrectaMeta),
      );
    } else if (isInserting) {
      context.missing(_esCorrectaMeta);
    }
    if (data.containsKey('calificacion')) {
      context.handle(
        _calificacionMeta,
        calificacion.isAcceptableOrUnknown(
          data['calificacion']!,
          _calificacionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calificacionMeta);
    }
    if (data.containsKey('tiempo_ms')) {
      context.handle(
        _tiempoMsMeta,
        tiempoMs.isAcceptableOrUnknown(data['tiempo_ms']!, _tiempoMsMeta),
      );
    } else if (isInserting) {
      context.missing(_tiempoMsMeta);
    }
    if (data.containsKey('respondida_en')) {
      context.handle(
        _respondidaEnMeta,
        respondidaEn.isAcceptableOrUnknown(
          data['respondida_en']!,
          _respondidaEnMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_respondidaEnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {idEvento};
  @override
  RespuestaLocal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RespuestaLocal(
      idEvento: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id_evento'],
      )!,
      preguntaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pregunta_id'],
      )!,
      opcionElegida: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opcion_elegida'],
      ),
      esCorrecta: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}es_correcta'],
      )!,
      calificacion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calificacion'],
      )!,
      tiempoMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tiempo_ms'],
      )!,
      respondidaEn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}respondida_en'],
      )!,
    );
  }

  @override
  $RespuestasLocalesTable createAlias(String alias) {
    return $RespuestasLocalesTable(attachedDatabase, alias);
  }
}

class RespuestaLocal extends DataClass implements Insertable<RespuestaLocal> {
  final String idEvento;
  final String preguntaId;
  final String? opcionElegida;
  final bool esCorrecta;
  final int calificacion;
  final int tiempoMs;
  final DateTime respondidaEn;
  const RespuestaLocal({
    required this.idEvento,
    required this.preguntaId,
    this.opcionElegida,
    required this.esCorrecta,
    required this.calificacion,
    required this.tiempoMs,
    required this.respondidaEn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id_evento'] = Variable<String>(idEvento);
    map['pregunta_id'] = Variable<String>(preguntaId);
    if (!nullToAbsent || opcionElegida != null) {
      map['opcion_elegida'] = Variable<String>(opcionElegida);
    }
    map['es_correcta'] = Variable<bool>(esCorrecta);
    map['calificacion'] = Variable<int>(calificacion);
    map['tiempo_ms'] = Variable<int>(tiempoMs);
    map['respondida_en'] = Variable<DateTime>(respondidaEn);
    return map;
  }

  RespuestasLocalesCompanion toCompanion(bool nullToAbsent) {
    return RespuestasLocalesCompanion(
      idEvento: Value(idEvento),
      preguntaId: Value(preguntaId),
      opcionElegida: opcionElegida == null && nullToAbsent
          ? const Value.absent()
          : Value(opcionElegida),
      esCorrecta: Value(esCorrecta),
      calificacion: Value(calificacion),
      tiempoMs: Value(tiempoMs),
      respondidaEn: Value(respondidaEn),
    );
  }

  factory RespuestaLocal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RespuestaLocal(
      idEvento: serializer.fromJson<String>(json['idEvento']),
      preguntaId: serializer.fromJson<String>(json['preguntaId']),
      opcionElegida: serializer.fromJson<String?>(json['opcionElegida']),
      esCorrecta: serializer.fromJson<bool>(json['esCorrecta']),
      calificacion: serializer.fromJson<int>(json['calificacion']),
      tiempoMs: serializer.fromJson<int>(json['tiempoMs']),
      respondidaEn: serializer.fromJson<DateTime>(json['respondidaEn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'idEvento': serializer.toJson<String>(idEvento),
      'preguntaId': serializer.toJson<String>(preguntaId),
      'opcionElegida': serializer.toJson<String?>(opcionElegida),
      'esCorrecta': serializer.toJson<bool>(esCorrecta),
      'calificacion': serializer.toJson<int>(calificacion),
      'tiempoMs': serializer.toJson<int>(tiempoMs),
      'respondidaEn': serializer.toJson<DateTime>(respondidaEn),
    };
  }

  RespuestaLocal copyWith({
    String? idEvento,
    String? preguntaId,
    Value<String?> opcionElegida = const Value.absent(),
    bool? esCorrecta,
    int? calificacion,
    int? tiempoMs,
    DateTime? respondidaEn,
  }) => RespuestaLocal(
    idEvento: idEvento ?? this.idEvento,
    preguntaId: preguntaId ?? this.preguntaId,
    opcionElegida: opcionElegida.present
        ? opcionElegida.value
        : this.opcionElegida,
    esCorrecta: esCorrecta ?? this.esCorrecta,
    calificacion: calificacion ?? this.calificacion,
    tiempoMs: tiempoMs ?? this.tiempoMs,
    respondidaEn: respondidaEn ?? this.respondidaEn,
  );
  RespuestaLocal copyWithCompanion(RespuestasLocalesCompanion data) {
    return RespuestaLocal(
      idEvento: data.idEvento.present ? data.idEvento.value : this.idEvento,
      preguntaId: data.preguntaId.present
          ? data.preguntaId.value
          : this.preguntaId,
      opcionElegida: data.opcionElegida.present
          ? data.opcionElegida.value
          : this.opcionElegida,
      esCorrecta: data.esCorrecta.present
          ? data.esCorrecta.value
          : this.esCorrecta,
      calificacion: data.calificacion.present
          ? data.calificacion.value
          : this.calificacion,
      tiempoMs: data.tiempoMs.present ? data.tiempoMs.value : this.tiempoMs,
      respondidaEn: data.respondidaEn.present
          ? data.respondidaEn.value
          : this.respondidaEn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RespuestaLocal(')
          ..write('idEvento: $idEvento, ')
          ..write('preguntaId: $preguntaId, ')
          ..write('opcionElegida: $opcionElegida, ')
          ..write('esCorrecta: $esCorrecta, ')
          ..write('calificacion: $calificacion, ')
          ..write('tiempoMs: $tiempoMs, ')
          ..write('respondidaEn: $respondidaEn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    idEvento,
    preguntaId,
    opcionElegida,
    esCorrecta,
    calificacion,
    tiempoMs,
    respondidaEn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RespuestaLocal &&
          other.idEvento == this.idEvento &&
          other.preguntaId == this.preguntaId &&
          other.opcionElegida == this.opcionElegida &&
          other.esCorrecta == this.esCorrecta &&
          other.calificacion == this.calificacion &&
          other.tiempoMs == this.tiempoMs &&
          other.respondidaEn == this.respondidaEn);
}

class RespuestasLocalesCompanion extends UpdateCompanion<RespuestaLocal> {
  final Value<String> idEvento;
  final Value<String> preguntaId;
  final Value<String?> opcionElegida;
  final Value<bool> esCorrecta;
  final Value<int> calificacion;
  final Value<int> tiempoMs;
  final Value<DateTime> respondidaEn;
  final Value<int> rowid;
  const RespuestasLocalesCompanion({
    this.idEvento = const Value.absent(),
    this.preguntaId = const Value.absent(),
    this.opcionElegida = const Value.absent(),
    this.esCorrecta = const Value.absent(),
    this.calificacion = const Value.absent(),
    this.tiempoMs = const Value.absent(),
    this.respondidaEn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RespuestasLocalesCompanion.insert({
    required String idEvento,
    required String preguntaId,
    this.opcionElegida = const Value.absent(),
    required bool esCorrecta,
    required int calificacion,
    required int tiempoMs,
    required DateTime respondidaEn,
    this.rowid = const Value.absent(),
  }) : idEvento = Value(idEvento),
       preguntaId = Value(preguntaId),
       esCorrecta = Value(esCorrecta),
       calificacion = Value(calificacion),
       tiempoMs = Value(tiempoMs),
       respondidaEn = Value(respondidaEn);
  static Insertable<RespuestaLocal> custom({
    Expression<String>? idEvento,
    Expression<String>? preguntaId,
    Expression<String>? opcionElegida,
    Expression<bool>? esCorrecta,
    Expression<int>? calificacion,
    Expression<int>? tiempoMs,
    Expression<DateTime>? respondidaEn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (idEvento != null) 'id_evento': idEvento,
      if (preguntaId != null) 'pregunta_id': preguntaId,
      if (opcionElegida != null) 'opcion_elegida': opcionElegida,
      if (esCorrecta != null) 'es_correcta': esCorrecta,
      if (calificacion != null) 'calificacion': calificacion,
      if (tiempoMs != null) 'tiempo_ms': tiempoMs,
      if (respondidaEn != null) 'respondida_en': respondidaEn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RespuestasLocalesCompanion copyWith({
    Value<String>? idEvento,
    Value<String>? preguntaId,
    Value<String?>? opcionElegida,
    Value<bool>? esCorrecta,
    Value<int>? calificacion,
    Value<int>? tiempoMs,
    Value<DateTime>? respondidaEn,
    Value<int>? rowid,
  }) {
    return RespuestasLocalesCompanion(
      idEvento: idEvento ?? this.idEvento,
      preguntaId: preguntaId ?? this.preguntaId,
      opcionElegida: opcionElegida ?? this.opcionElegida,
      esCorrecta: esCorrecta ?? this.esCorrecta,
      calificacion: calificacion ?? this.calificacion,
      tiempoMs: tiempoMs ?? this.tiempoMs,
      respondidaEn: respondidaEn ?? this.respondidaEn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (idEvento.present) {
      map['id_evento'] = Variable<String>(idEvento.value);
    }
    if (preguntaId.present) {
      map['pregunta_id'] = Variable<String>(preguntaId.value);
    }
    if (opcionElegida.present) {
      map['opcion_elegida'] = Variable<String>(opcionElegida.value);
    }
    if (esCorrecta.present) {
      map['es_correcta'] = Variable<bool>(esCorrecta.value);
    }
    if (calificacion.present) {
      map['calificacion'] = Variable<int>(calificacion.value);
    }
    if (tiempoMs.present) {
      map['tiempo_ms'] = Variable<int>(tiempoMs.value);
    }
    if (respondidaEn.present) {
      map['respondida_en'] = Variable<DateTime>(respondidaEn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RespuestasLocalesCompanion(')
          ..write('idEvento: $idEvento, ')
          ..write('preguntaId: $preguntaId, ')
          ..write('opcionElegida: $opcionElegida, ')
          ..write('esCorrecta: $esCorrecta, ')
          ..write('calificacion: $calificacion, ')
          ..write('tiempoMs: $tiempoMs, ')
          ..write('respondidaEn: $respondidaEn, ')
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
  late final $TarjetasFsrsTable tarjetasFsrs = $TarjetasFsrsTable(this);
  late final $RespuestasLocalesTable respuestasLocales =
      $RespuestasLocalesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    examenes,
    temas,
    preguntas,
    tarjetasFsrs,
    respuestasLocales,
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

  static MultiTypedResultKey<$TarjetasFsrsTable, List<TarjetaFsrs>>
  _tarjetasFsrsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tarjetasFsrs,
    aliasName: 'preguntas__id__tarjetas_fsrs__pregunta_id',
  );

  $$TarjetasFsrsTableProcessedTableManager get tarjetasFsrsRefs {
    final manager = $$TarjetasFsrsTableTableManager(
      $_db,
      $_db.tarjetasFsrs,
    ).filter((f) => f.preguntaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tarjetasFsrsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RespuestasLocalesTable, List<RespuestaLocal>>
  _respuestasLocalesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.respuestasLocales,
        aliasName: 'preguntas__id__respuestas_locales__pregunta_id',
      );

  $$RespuestasLocalesTableProcessedTableManager get respuestasLocalesRefs {
    final manager = $$RespuestasLocalesTableTableManager(
      $_db,
      $_db.respuestasLocales,
    ).filter((f) => f.preguntaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _respuestasLocalesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  Expression<bool> tarjetasFsrsRefs(
    Expression<bool> Function($$TarjetasFsrsTableFilterComposer f) f,
  ) {
    final $$TarjetasFsrsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tarjetasFsrs,
      getReferencedColumn: (t) => t.preguntaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarjetasFsrsTableFilterComposer(
            $db: $db,
            $table: $db.tarjetasFsrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> respuestasLocalesRefs(
    Expression<bool> Function($$RespuestasLocalesTableFilterComposer f) f,
  ) {
    final $$RespuestasLocalesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.respuestasLocales,
      getReferencedColumn: (t) => t.preguntaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RespuestasLocalesTableFilterComposer(
            $db: $db,
            $table: $db.respuestasLocales,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<T> tarjetasFsrsRefs<T extends Object>(
    Expression<T> Function($$TarjetasFsrsTableAnnotationComposer a) f,
  ) {
    final $$TarjetasFsrsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tarjetasFsrs,
      getReferencedColumn: (t) => t.preguntaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TarjetasFsrsTableAnnotationComposer(
            $db: $db,
            $table: $db.tarjetasFsrs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> respuestasLocalesRefs<T extends Object>(
    Expression<T> Function($$RespuestasLocalesTableAnnotationComposer a) f,
  ) {
    final $$RespuestasLocalesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.respuestasLocales,
          getReferencedColumn: (t) => t.preguntaId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RespuestasLocalesTableAnnotationComposer(
                $db: $db,
                $table: $db.respuestasLocales,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
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
          PrefetchHooks Function({
            bool examenId,
            bool temaId,
            bool tarjetasFsrsRefs,
            bool respuestasLocalesRefs,
          })
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
          prefetchHooksCallback:
              ({
                examenId = false,
                temaId = false,
                tarjetasFsrsRefs = false,
                respuestasLocalesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (tarjetasFsrsRefs) db.tarjetasFsrs,
                    if (respuestasLocalesRefs) db.respuestasLocales,
                  ],
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
                    return [
                      if (tarjetasFsrsRefs)
                        await $_getPrefetchedDataByColumns<
                          Pregunta,
                          $PreguntasTable,
                          TarjetaFsrs,
                          $TarjetasFsrsTable
                        >(
                          currentTable: table,
                          referencedTable: $$PreguntasTableReferences
                              ._tarjetasFsrsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PreguntasTableReferences(
                                db,
                                table,
                                p0,
                              ).tarjetasFsrsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pregunta_id',
                          typedResults: items,
                        ),
                      if (respuestasLocalesRefs)
                        await $_getPrefetchedDataByColumns<
                          Pregunta,
                          $PreguntasTable,
                          RespuestaLocal,
                          $RespuestasLocalesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PreguntasTableReferences
                              ._respuestasLocalesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PreguntasTableReferences(
                                db,
                                table,
                                p0,
                              ).respuestasLocalesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pregunta_id',
                          typedResults: items,
                        ),
                    ];
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
      PrefetchHooks Function({
        bool examenId,
        bool temaId,
        bool tarjetasFsrsRefs,
        bool respuestasLocalesRefs,
      })
    >;
typedef $$TarjetasFsrsTableCreateCompanionBuilder =
    TarjetasFsrsCompanion Function({
      required String preguntaId,
      required int estado,
      Value<int?> paso,
      Value<double?> estabilidad,
      Value<double?> dificultad,
      required DateTime vence,
      Value<DateTime?> ultimaRevision,
      Value<int> rowid,
    });
typedef $$TarjetasFsrsTableUpdateCompanionBuilder =
    TarjetasFsrsCompanion Function({
      Value<String> preguntaId,
      Value<int> estado,
      Value<int?> paso,
      Value<double?> estabilidad,
      Value<double?> dificultad,
      Value<DateTime> vence,
      Value<DateTime?> ultimaRevision,
      Value<int> rowid,
    });

final class $$TarjetasFsrsTableReferences
    extends BaseReferences<_$AppDatabase, $TarjetasFsrsTable, TarjetaFsrs> {
  $$TarjetasFsrsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PreguntasTable _preguntaIdTable(_$AppDatabase db) =>
      db.preguntas.createAlias('tarjetas_fsrs__pregunta_id__preguntas__id');

  $$PreguntasTableProcessedTableManager get preguntaId {
    final $_column = $_itemColumn<String>('pregunta_id')!;

    final manager = $$PreguntasTableTableManager(
      $_db,
      $_db.preguntas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_preguntaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TarjetasFsrsTableFilterComposer
    extends Composer<_$AppDatabase, $TarjetasFsrsTable> {
  $$TarjetasFsrsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get paso => $composableBuilder(
    column: $table.paso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get estabilidad => $composableBuilder(
    column: $table.estabilidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get dificultad => $composableBuilder(
    column: $table.dificultad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get vence => $composableBuilder(
    column: $table.vence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ultimaRevision => $composableBuilder(
    column: $table.ultimaRevision,
    builder: (column) => ColumnFilters(column),
  );

  $$PreguntasTableFilterComposer get preguntaId {
    final $$PreguntasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$TarjetasFsrsTableOrderingComposer
    extends Composer<_$AppDatabase, $TarjetasFsrsTable> {
  $$TarjetasFsrsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get estado => $composableBuilder(
    column: $table.estado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get paso => $composableBuilder(
    column: $table.paso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get estabilidad => $composableBuilder(
    column: $table.estabilidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get dificultad => $composableBuilder(
    column: $table.dificultad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get vence => $composableBuilder(
    column: $table.vence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ultimaRevision => $composableBuilder(
    column: $table.ultimaRevision,
    builder: (column) => ColumnOrderings(column),
  );

  $$PreguntasTableOrderingComposer get preguntaId {
    final $$PreguntasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasTableOrderingComposer(
            $db: $db,
            $table: $db.preguntas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TarjetasFsrsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TarjetasFsrsTable> {
  $$TarjetasFsrsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get estado =>
      $composableBuilder(column: $table.estado, builder: (column) => column);

  GeneratedColumn<int> get paso =>
      $composableBuilder(column: $table.paso, builder: (column) => column);

  GeneratedColumn<double> get estabilidad => $composableBuilder(
    column: $table.estabilidad,
    builder: (column) => column,
  );

  GeneratedColumn<double> get dificultad => $composableBuilder(
    column: $table.dificultad,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get vence =>
      $composableBuilder(column: $table.vence, builder: (column) => column);

  GeneratedColumn<DateTime> get ultimaRevision => $composableBuilder(
    column: $table.ultimaRevision,
    builder: (column) => column,
  );

  $$PreguntasTableAnnotationComposer get preguntaId {
    final $$PreguntasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$TarjetasFsrsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TarjetasFsrsTable,
          TarjetaFsrs,
          $$TarjetasFsrsTableFilterComposer,
          $$TarjetasFsrsTableOrderingComposer,
          $$TarjetasFsrsTableAnnotationComposer,
          $$TarjetasFsrsTableCreateCompanionBuilder,
          $$TarjetasFsrsTableUpdateCompanionBuilder,
          (TarjetaFsrs, $$TarjetasFsrsTableReferences),
          TarjetaFsrs,
          PrefetchHooks Function({bool preguntaId})
        > {
  $$TarjetasFsrsTableTableManager(_$AppDatabase db, $TarjetasFsrsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TarjetasFsrsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TarjetasFsrsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TarjetasFsrsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> preguntaId = const Value.absent(),
                Value<int> estado = const Value.absent(),
                Value<int?> paso = const Value.absent(),
                Value<double?> estabilidad = const Value.absent(),
                Value<double?> dificultad = const Value.absent(),
                Value<DateTime> vence = const Value.absent(),
                Value<DateTime?> ultimaRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarjetasFsrsCompanion(
                preguntaId: preguntaId,
                estado: estado,
                paso: paso,
                estabilidad: estabilidad,
                dificultad: dificultad,
                vence: vence,
                ultimaRevision: ultimaRevision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String preguntaId,
                required int estado,
                Value<int?> paso = const Value.absent(),
                Value<double?> estabilidad = const Value.absent(),
                Value<double?> dificultad = const Value.absent(),
                required DateTime vence,
                Value<DateTime?> ultimaRevision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TarjetasFsrsCompanion.insert(
                preguntaId: preguntaId,
                estado: estado,
                paso: paso,
                estabilidad: estabilidad,
                dificultad: dificultad,
                vence: vence,
                ultimaRevision: ultimaRevision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TarjetasFsrsTable, TarjetaFsrs>(table),
                  $$TarjetasFsrsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({preguntaId = false}) {
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
                    if (preguntaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.preguntaId,
                        referencedTable: $$TarjetasFsrsTableReferences
                            ._preguntaIdTable(db),
                        referencedColumn: $$TarjetasFsrsTableReferences
                            ._preguntaIdTable(db)
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

typedef $$TarjetasFsrsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TarjetasFsrsTable,
      TarjetaFsrs,
      $$TarjetasFsrsTableFilterComposer,
      $$TarjetasFsrsTableOrderingComposer,
      $$TarjetasFsrsTableAnnotationComposer,
      $$TarjetasFsrsTableCreateCompanionBuilder,
      $$TarjetasFsrsTableUpdateCompanionBuilder,
      (TarjetaFsrs, $$TarjetasFsrsTableReferences),
      TarjetaFsrs,
      PrefetchHooks Function({bool preguntaId})
    >;
typedef $$RespuestasLocalesTableCreateCompanionBuilder =
    RespuestasLocalesCompanion Function({
      required String idEvento,
      required String preguntaId,
      Value<String?> opcionElegida,
      required bool esCorrecta,
      required int calificacion,
      required int tiempoMs,
      required DateTime respondidaEn,
      Value<int> rowid,
    });
typedef $$RespuestasLocalesTableUpdateCompanionBuilder =
    RespuestasLocalesCompanion Function({
      Value<String> idEvento,
      Value<String> preguntaId,
      Value<String?> opcionElegida,
      Value<bool> esCorrecta,
      Value<int> calificacion,
      Value<int> tiempoMs,
      Value<DateTime> respondidaEn,
      Value<int> rowid,
    });

final class $$RespuestasLocalesTableReferences
    extends
        BaseReferences<_$AppDatabase, $RespuestasLocalesTable, RespuestaLocal> {
  $$RespuestasLocalesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PreguntasTable _preguntaIdTable(_$AppDatabase db) => db.preguntas
      .createAlias('respuestas_locales__pregunta_id__preguntas__id');

  $$PreguntasTableProcessedTableManager get preguntaId {
    final $_column = $_itemColumn<String>('pregunta_id')!;

    final manager = $$PreguntasTableTableManager(
      $_db,
      $_db.preguntas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_preguntaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RespuestasLocalesTableFilterComposer
    extends Composer<_$AppDatabase, $RespuestasLocalesTable> {
  $$RespuestasLocalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get idEvento => $composableBuilder(
    column: $table.idEvento,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opcionElegida => $composableBuilder(
    column: $table.opcionElegida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get esCorrecta => $composableBuilder(
    column: $table.esCorrecta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calificacion => $composableBuilder(
    column: $table.calificacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tiempoMs => $composableBuilder(
    column: $table.tiempoMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get respondidaEn => $composableBuilder(
    column: $table.respondidaEn,
    builder: (column) => ColumnFilters(column),
  );

  $$PreguntasTableFilterComposer get preguntaId {
    final $$PreguntasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$RespuestasLocalesTableOrderingComposer
    extends Composer<_$AppDatabase, $RespuestasLocalesTable> {
  $$RespuestasLocalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get idEvento => $composableBuilder(
    column: $table.idEvento,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opcionElegida => $composableBuilder(
    column: $table.opcionElegida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get esCorrecta => $composableBuilder(
    column: $table.esCorrecta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calificacion => $composableBuilder(
    column: $table.calificacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tiempoMs => $composableBuilder(
    column: $table.tiempoMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get respondidaEn => $composableBuilder(
    column: $table.respondidaEn,
    builder: (column) => ColumnOrderings(column),
  );

  $$PreguntasTableOrderingComposer get preguntaId {
    final $$PreguntasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PreguntasTableOrderingComposer(
            $db: $db,
            $table: $db.preguntas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RespuestasLocalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RespuestasLocalesTable> {
  $$RespuestasLocalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get idEvento =>
      $composableBuilder(column: $table.idEvento, builder: (column) => column);

  GeneratedColumn<String> get opcionElegida => $composableBuilder(
    column: $table.opcionElegida,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get esCorrecta => $composableBuilder(
    column: $table.esCorrecta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get calificacion => $composableBuilder(
    column: $table.calificacion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tiempoMs =>
      $composableBuilder(column: $table.tiempoMs, builder: (column) => column);

  GeneratedColumn<DateTime> get respondidaEn => $composableBuilder(
    column: $table.respondidaEn,
    builder: (column) => column,
  );

  $$PreguntasTableAnnotationComposer get preguntaId {
    final $$PreguntasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.preguntaId,
      referencedTable: $db.preguntas,
      getReferencedColumn: (t) => t.id,
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
    return composer;
  }
}

class $$RespuestasLocalesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RespuestasLocalesTable,
          RespuestaLocal,
          $$RespuestasLocalesTableFilterComposer,
          $$RespuestasLocalesTableOrderingComposer,
          $$RespuestasLocalesTableAnnotationComposer,
          $$RespuestasLocalesTableCreateCompanionBuilder,
          $$RespuestasLocalesTableUpdateCompanionBuilder,
          (RespuestaLocal, $$RespuestasLocalesTableReferences),
          RespuestaLocal,
          PrefetchHooks Function({bool preguntaId})
        > {
  $$RespuestasLocalesTableTableManager(
    _$AppDatabase db,
    $RespuestasLocalesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RespuestasLocalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RespuestasLocalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RespuestasLocalesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> idEvento = const Value.absent(),
                Value<String> preguntaId = const Value.absent(),
                Value<String?> opcionElegida = const Value.absent(),
                Value<bool> esCorrecta = const Value.absent(),
                Value<int> calificacion = const Value.absent(),
                Value<int> tiempoMs = const Value.absent(),
                Value<DateTime> respondidaEn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RespuestasLocalesCompanion(
                idEvento: idEvento,
                preguntaId: preguntaId,
                opcionElegida: opcionElegida,
                esCorrecta: esCorrecta,
                calificacion: calificacion,
                tiempoMs: tiempoMs,
                respondidaEn: respondidaEn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String idEvento,
                required String preguntaId,
                Value<String?> opcionElegida = const Value.absent(),
                required bool esCorrecta,
                required int calificacion,
                required int tiempoMs,
                required DateTime respondidaEn,
                Value<int> rowid = const Value.absent(),
              }) => RespuestasLocalesCompanion.insert(
                idEvento: idEvento,
                preguntaId: preguntaId,
                opcionElegida: opcionElegida,
                esCorrecta: esCorrecta,
                calificacion: calificacion,
                tiempoMs: tiempoMs,
                respondidaEn: respondidaEn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RespuestasLocalesTable, RespuestaLocal>(table),
                  $$RespuestasLocalesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({preguntaId = false}) {
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
                    if (preguntaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.preguntaId,
                        referencedTable: $$RespuestasLocalesTableReferences
                            ._preguntaIdTable(db),
                        referencedColumn: $$RespuestasLocalesTableReferences
                            ._preguntaIdTable(db)
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

typedef $$RespuestasLocalesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RespuestasLocalesTable,
      RespuestaLocal,
      $$RespuestasLocalesTableFilterComposer,
      $$RespuestasLocalesTableOrderingComposer,
      $$RespuestasLocalesTableAnnotationComposer,
      $$RespuestasLocalesTableCreateCompanionBuilder,
      $$RespuestasLocalesTableUpdateCompanionBuilder,
      (RespuestaLocal, $$RespuestasLocalesTableReferences),
      RespuestaLocal,
      PrefetchHooks Function({bool preguntaId})
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
  $$TarjetasFsrsTableTableManager get tarjetasFsrs =>
      $$TarjetasFsrsTableTableManager(_db, _db.tarjetasFsrs);
  $$RespuestasLocalesTableTableManager get respuestasLocales =>
      $$RespuestasLocalesTableTableManager(_db, _db.respuestasLocales);
}

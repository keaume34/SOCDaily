// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, code, title, description, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(Insertable<Subject> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String code;
  final String title;
  final String? description;
  final int orderIndex;
  const Subject(
      {required this.id,
      required this.code,
      required this.title,
      this.description,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      code: Value(code),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      orderIndex: Value(orderIndex),
    );
  }

  factory Subject.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Subject copyWith(
          {int? id,
          String? code,
          String? title,
          Value<String?> description = const Value.absent(),
          int? orderIndex}) =>
      Subject(
        id: id ?? this.id,
        code: code ?? this.code,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, title, description, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.code == this.code &&
          other.title == this.title &&
          other.description == this.description &&
          other.orderIndex == this.orderIndex);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> orderIndex;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String title,
    this.description = const Value.absent(),
    this.orderIndex = const Value.absent(),
  })  : code = Value(code),
        title = Value(title);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  SubjectsCompanion copyWith(
      {Value<int>? id,
      Value<String>? code,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? orderIndex}) {
    return SubjectsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _subjectIdMeta =
      const VerificationMeta('subjectId');
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
      'subject_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES subjects (id)'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, subjectId, code, title, description, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(Insertable<Chapter> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(_subjectIdMeta,
          subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta));
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {subjectId, code},
      ];
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      subjectId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}subject_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final int id;
  final int subjectId;
  final String code;
  final String title;
  final String? description;
  final int orderIndex;
  const Chapter(
      {required this.id,
      required this.subjectId,
      required this.code,
      required this.title,
      this.description,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<int>(subjectId);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      code: Value(code),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      orderIndex: Value(orderIndex),
    );
  }

  factory Chapter.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<int>(subjectId),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Chapter copyWith(
          {int? id,
          int? subjectId,
          String? code,
          String? title,
          Value<String?> description = const Value.absent(),
          int? orderIndex}) =>
      Chapter(
        id: id ?? this.id,
        subjectId: subjectId ?? this.subjectId,
        code: code ?? this.code,
        title: title ?? this.title,
        description: description.present ? description.value : this.description,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      description:
          data.description.present ? data.description.value : this.description,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, subjectId, code, title, description, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.code == this.code &&
          other.title == this.title &&
          other.description == this.description &&
          other.orderIndex == this.orderIndex);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<int> id;
  final Value<int> subjectId;
  final Value<String> code;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> orderIndex;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  ChaptersCompanion.insert({
    this.id = const Value.absent(),
    required int subjectId,
    required String code,
    required String title,
    this.description = const Value.absent(),
    this.orderIndex = const Value.absent(),
  })  : subjectId = Value(subjectId),
        code = Value(code),
        title = Value(title);
  static Insertable<Chapter> custom({
    Expression<int>? id,
    Expression<int>? subjectId,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  ChaptersCompanion copyWith(
      {Value<int>? id,
      Value<int>? subjectId,
      Value<String>? code,
      Value<String>? title,
      Value<String?>? description,
      Value<int>? orderIndex}) {
    return ChaptersCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $TopicsTable extends Topics with TableInfo<$TopicsTable, Topic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _chapterIdMeta =
      const VerificationMeta('chapterId');
  @override
  late final GeneratedColumn<int> chapterId = GeneratedColumn<int>(
      'chapter_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES chapters (id)'));
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _summaryMeta =
      const VerificationMeta('summary');
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
      'summary', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, chapterId, code, title, summary, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'topics';
  @override
  VerificationContext validateIntegrity(Insertable<Topic> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('chapter_id')) {
      context.handle(_chapterIdMeta,
          chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta));
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('summary')) {
      context.handle(_summaryMeta,
          summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
        {chapterId, code},
      ];
  @override
  Topic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Topic(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      chapterId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}chapter_id'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      summary: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}summary']),
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $TopicsTable createAlias(String alias) {
    return $TopicsTable(attachedDatabase, alias);
  }
}

class Topic extends DataClass implements Insertable<Topic> {
  final int id;
  final int chapterId;
  final String code;
  final String title;
  final String? summary;
  final int orderIndex;
  const Topic(
      {required this.id,
      required this.chapterId,
      required this.code,
      required this.title,
      this.summary,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['chapter_id'] = Variable<int>(chapterId);
    map['code'] = Variable<String>(code);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || summary != null) {
      map['summary'] = Variable<String>(summary);
    }
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  TopicsCompanion toCompanion(bool nullToAbsent) {
    return TopicsCompanion(
      id: Value(id),
      chapterId: Value(chapterId),
      code: Value(code),
      title: Value(title),
      summary: summary == null && nullToAbsent
          ? const Value.absent()
          : Value(summary),
      orderIndex: Value(orderIndex),
    );
  }

  factory Topic.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Topic(
      id: serializer.fromJson<int>(json['id']),
      chapterId: serializer.fromJson<int>(json['chapterId']),
      code: serializer.fromJson<String>(json['code']),
      title: serializer.fromJson<String>(json['title']),
      summary: serializer.fromJson<String?>(json['summary']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'chapterId': serializer.toJson<int>(chapterId),
      'code': serializer.toJson<String>(code),
      'title': serializer.toJson<String>(title),
      'summary': serializer.toJson<String?>(summary),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  Topic copyWith(
          {int? id,
          int? chapterId,
          String? code,
          String? title,
          Value<String?> summary = const Value.absent(),
          int? orderIndex}) =>
      Topic(
        id: id ?? this.id,
        chapterId: chapterId ?? this.chapterId,
        code: code ?? this.code,
        title: title ?? this.title,
        summary: summary.present ? summary.value : this.summary,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  Topic copyWithCompanion(TopicsCompanion data) {
    return Topic(
      id: data.id.present ? data.id.value : this.id,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      code: data.code.present ? data.code.value : this.code,
      title: data.title.present ? data.title.value : this.title,
      summary: data.summary.present ? data.summary.value : this.summary,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Topic(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, chapterId, code, title, summary, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Topic &&
          other.id == this.id &&
          other.chapterId == this.chapterId &&
          other.code == this.code &&
          other.title == this.title &&
          other.summary == this.summary &&
          other.orderIndex == this.orderIndex);
}

class TopicsCompanion extends UpdateCompanion<Topic> {
  final Value<int> id;
  final Value<int> chapterId;
  final Value<String> code;
  final Value<String> title;
  final Value<String?> summary;
  final Value<int> orderIndex;
  const TopicsCompanion({
    this.id = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.code = const Value.absent(),
    this.title = const Value.absent(),
    this.summary = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  TopicsCompanion.insert({
    this.id = const Value.absent(),
    required int chapterId,
    required String code,
    required String title,
    this.summary = const Value.absent(),
    this.orderIndex = const Value.absent(),
  })  : chapterId = Value(chapterId),
        code = Value(code),
        title = Value(title);
  static Insertable<Topic> custom({
    Expression<int>? id,
    Expression<int>? chapterId,
    Expression<String>? code,
    Expression<String>? title,
    Expression<String>? summary,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (chapterId != null) 'chapter_id': chapterId,
      if (code != null) 'code': code,
      if (title != null) 'title': title,
      if (summary != null) 'summary': summary,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  TopicsCompanion copyWith(
      {Value<int>? id,
      Value<int>? chapterId,
      Value<String>? code,
      Value<String>? title,
      Value<String?>? summary,
      Value<int>? orderIndex}) {
    return TopicsCompanion(
      id: id ?? this.id,
      chapterId: chapterId ?? this.chapterId,
      code: code ?? this.code,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<int>(chapterId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TopicsCompanion(')
          ..write('id: $id, ')
          ..write('chapterId: $chapterId, ')
          ..write('code: $code, ')
          ..write('title: $title, ')
          ..write('summary: $summary, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $SourcesTable extends Sources with TableInfo<$SourcesTable, Source> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SourcesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _pdfPathMeta =
      const VerificationMeta('pdfPath');
  @override
  late final GeneratedColumn<String> pdfPath = GeneratedColumn<String>(
      'pdf_path', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, pdfPath, category, title, pageCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sources';
  @override
  VerificationContext validateIntegrity(Insertable<Source> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('pdf_path')) {
      context.handle(_pdfPathMeta,
          pdfPath.isAcceptableOrUnknown(data['pdf_path']!, _pdfPathMeta));
    } else if (isInserting) {
      context.missing(_pdfPathMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Source map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Source(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      pdfPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pdf_path'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count']),
    );
  }

  @override
  $SourcesTable createAlias(String alias) {
    return $SourcesTable(attachedDatabase, alias);
  }
}

class Source extends DataClass implements Insertable<Source> {
  final int id;
  final String pdfPath;
  final String? category;
  final String? title;
  final int? pageCount;
  const Source(
      {required this.id,
      required this.pdfPath,
      this.category,
      this.title,
      this.pageCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['pdf_path'] = Variable<String>(pdfPath);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    return map;
  }

  SourcesCompanion toCompanion(bool nullToAbsent) {
    return SourcesCompanion(
      id: Value(id),
      pdfPath: Value(pdfPath),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
    );
  }

  factory Source.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Source(
      id: serializer.fromJson<int>(json['id']),
      pdfPath: serializer.fromJson<String>(json['pdfPath']),
      category: serializer.fromJson<String?>(json['category']),
      title: serializer.fromJson<String?>(json['title']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'pdfPath': serializer.toJson<String>(pdfPath),
      'category': serializer.toJson<String?>(category),
      'title': serializer.toJson<String?>(title),
      'pageCount': serializer.toJson<int?>(pageCount),
    };
  }

  Source copyWith(
          {int? id,
          String? pdfPath,
          Value<String?> category = const Value.absent(),
          Value<String?> title = const Value.absent(),
          Value<int?> pageCount = const Value.absent()}) =>
      Source(
        id: id ?? this.id,
        pdfPath: pdfPath ?? this.pdfPath,
        category: category.present ? category.value : this.category,
        title: title.present ? title.value : this.title,
        pageCount: pageCount.present ? pageCount.value : this.pageCount,
      );
  Source copyWithCompanion(SourcesCompanion data) {
    return Source(
      id: data.id.present ? data.id.value : this.id,
      pdfPath: data.pdfPath.present ? data.pdfPath.value : this.pdfPath,
      category: data.category.present ? data.category.value : this.category,
      title: data.title.present ? data.title.value : this.title,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Source(')
          ..write('id: $id, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('pageCount: $pageCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, pdfPath, category, title, pageCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Source &&
          other.id == this.id &&
          other.pdfPath == this.pdfPath &&
          other.category == this.category &&
          other.title == this.title &&
          other.pageCount == this.pageCount);
}

class SourcesCompanion extends UpdateCompanion<Source> {
  final Value<int> id;
  final Value<String> pdfPath;
  final Value<String?> category;
  final Value<String?> title;
  final Value<int?> pageCount;
  const SourcesCompanion({
    this.id = const Value.absent(),
    this.pdfPath = const Value.absent(),
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.pageCount = const Value.absent(),
  });
  SourcesCompanion.insert({
    this.id = const Value.absent(),
    required String pdfPath,
    this.category = const Value.absent(),
    this.title = const Value.absent(),
    this.pageCount = const Value.absent(),
  }) : pdfPath = Value(pdfPath);
  static Insertable<Source> custom({
    Expression<int>? id,
    Expression<String>? pdfPath,
    Expression<String>? category,
    Expression<String>? title,
    Expression<int>? pageCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (pdfPath != null) 'pdf_path': pdfPath,
      if (category != null) 'category': category,
      if (title != null) 'title': title,
      if (pageCount != null) 'page_count': pageCount,
    });
  }

  SourcesCompanion copyWith(
      {Value<int>? id,
      Value<String>? pdfPath,
      Value<String?>? category,
      Value<String?>? title,
      Value<int?>? pageCount}) {
    return SourcesCompanion(
      id: id ?? this.id,
      pdfPath: pdfPath ?? this.pdfPath,
      category: category ?? this.category,
      title: title ?? this.title,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (pdfPath.present) {
      map['pdf_path'] = Variable<String>(pdfPath.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SourcesCompanion(')
          ..write('id: $id, ')
          ..write('pdfPath: $pdfPath, ')
          ..write('category: $category, ')
          ..write('title: $title, ')
          ..write('pageCount: $pageCount')
          ..write(')'))
        .toString();
  }
}

class $FlashcardsTable extends Flashcards
    with TableInfo<$FlashcardsTable, Flashcard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FlashcardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<int> topicId = GeneratedColumn<int>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES topics (id)'));
  static const VerificationMeta _frontMeta = const VerificationMeta('front');
  @override
  late final GeneratedColumn<String> front = GeneratedColumn<String>(
      'front', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _backMeta = const VerificationMeta('back');
  @override
  late final GeneratedColumn<String> back = GeneratedColumn<String>(
      'back', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hintMeta = const VerificationMeta('hint');
  @override
  late final GeneratedColumn<String> hint = GeneratedColumn<String>(
      'hint', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sources (id)'));
  static const VerificationMeta _sourcePageMeta =
      const VerificationMeta('sourcePage');
  @override
  late final GeneratedColumn<int> sourcePage = GeneratedColumn<int>(
      'source_page', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        topicId,
        front,
        back,
        hint,
        difficulty,
        tagsJson,
        sourceId,
        sourcePage,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'flashcards';
  @override
  VerificationContext validateIntegrity(Insertable<Flashcard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('front')) {
      context.handle(
          _frontMeta, front.isAcceptableOrUnknown(data['front']!, _frontMeta));
    } else if (isInserting) {
      context.missing(_frontMeta);
    }
    if (data.containsKey('back')) {
      context.handle(
          _backMeta, back.isAcceptableOrUnknown(data['back']!, _backMeta));
    } else if (isInserting) {
      context.missing(_backMeta);
    }
    if (data.containsKey('hint')) {
      context.handle(
          _hintMeta, hint.isAcceptableOrUnknown(data['hint']!, _hintMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('source_page')) {
      context.handle(
          _sourcePageMeta,
          sourcePage.isAcceptableOrUnknown(
              data['source_page']!, _sourcePageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Flashcard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Flashcard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}topic_id'])!,
      front: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}front'])!,
      back: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}back'])!,
      hint: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hint']),
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id']),
      sourcePage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_page']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $FlashcardsTable createAlias(String alias) {
    return $FlashcardsTable(attachedDatabase, alias);
  }
}

class Flashcard extends DataClass implements Insertable<Flashcard> {
  final int id;
  final int topicId;
  final String front;
  final String back;
  final String? hint;
  final String difficulty;
  final String tagsJson;
  final int? sourceId;
  final int? sourcePage;
  final DateTime createdAt;
  const Flashcard(
      {required this.id,
      required this.topicId,
      required this.front,
      required this.back,
      this.hint,
      required this.difficulty,
      required this.tagsJson,
      this.sourceId,
      this.sourcePage,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['topic_id'] = Variable<int>(topicId);
    map['front'] = Variable<String>(front);
    map['back'] = Variable<String>(back);
    if (!nullToAbsent || hint != null) {
      map['hint'] = Variable<String>(hint);
    }
    map['difficulty'] = Variable<String>(difficulty);
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    if (!nullToAbsent || sourcePage != null) {
      map['source_page'] = Variable<int>(sourcePage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FlashcardsCompanion toCompanion(bool nullToAbsent) {
    return FlashcardsCompanion(
      id: Value(id),
      topicId: Value(topicId),
      front: Value(front),
      back: Value(back),
      hint: hint == null && nullToAbsent ? const Value.absent() : Value(hint),
      difficulty: Value(difficulty),
      tagsJson: Value(tagsJson),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      sourcePage: sourcePage == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePage),
      createdAt: Value(createdAt),
    );
  }

  factory Flashcard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Flashcard(
      id: serializer.fromJson<int>(json['id']),
      topicId: serializer.fromJson<int>(json['topicId']),
      front: serializer.fromJson<String>(json['front']),
      back: serializer.fromJson<String>(json['back']),
      hint: serializer.fromJson<String?>(json['hint']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      sourcePage: serializer.fromJson<int?>(json['sourcePage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'topicId': serializer.toJson<int>(topicId),
      'front': serializer.toJson<String>(front),
      'back': serializer.toJson<String>(back),
      'hint': serializer.toJson<String?>(hint),
      'difficulty': serializer.toJson<String>(difficulty),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'sourceId': serializer.toJson<int?>(sourceId),
      'sourcePage': serializer.toJson<int?>(sourcePage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Flashcard copyWith(
          {int? id,
          int? topicId,
          String? front,
          String? back,
          Value<String?> hint = const Value.absent(),
          String? difficulty,
          String? tagsJson,
          Value<int?> sourceId = const Value.absent(),
          Value<int?> sourcePage = const Value.absent(),
          DateTime? createdAt}) =>
      Flashcard(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        front: front ?? this.front,
        back: back ?? this.back,
        hint: hint.present ? hint.value : this.hint,
        difficulty: difficulty ?? this.difficulty,
        tagsJson: tagsJson ?? this.tagsJson,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        sourcePage: sourcePage.present ? sourcePage.value : this.sourcePage,
        createdAt: createdAt ?? this.createdAt,
      );
  Flashcard copyWithCompanion(FlashcardsCompanion data) {
    return Flashcard(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      front: data.front.present ? data.front.value : this.front,
      back: data.back.present ? data.back.value : this.back,
      hint: data.hint.present ? data.hint.value : this.hint,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourcePage:
          data.sourcePage.present ? data.sourcePage.value : this.sourcePage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Flashcard(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('difficulty: $difficulty, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, topicId, front, back, hint, difficulty,
      tagsJson, sourceId, sourcePage, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Flashcard &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.front == this.front &&
          other.back == this.back &&
          other.hint == this.hint &&
          other.difficulty == this.difficulty &&
          other.tagsJson == this.tagsJson &&
          other.sourceId == this.sourceId &&
          other.sourcePage == this.sourcePage &&
          other.createdAt == this.createdAt);
}

class FlashcardsCompanion extends UpdateCompanion<Flashcard> {
  final Value<int> id;
  final Value<int> topicId;
  final Value<String> front;
  final Value<String> back;
  final Value<String?> hint;
  final Value<String> difficulty;
  final Value<String> tagsJson;
  final Value<int?> sourceId;
  final Value<int?> sourcePage;
  final Value<DateTime> createdAt;
  const FlashcardsCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.front = const Value.absent(),
    this.back = const Value.absent(),
    this.hint = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FlashcardsCompanion.insert({
    this.id = const Value.absent(),
    required int topicId,
    required String front,
    required String back,
    this.hint = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : topicId = Value(topicId),
        front = Value(front),
        back = Value(back);
  static Insertable<Flashcard> custom({
    Expression<int>? id,
    Expression<int>? topicId,
    Expression<String>? front,
    Expression<String>? back,
    Expression<String>? hint,
    Expression<String>? difficulty,
    Expression<String>? tagsJson,
    Expression<int>? sourceId,
    Expression<int>? sourcePage,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (front != null) 'front': front,
      if (back != null) 'back': back,
      if (hint != null) 'hint': hint,
      if (difficulty != null) 'difficulty': difficulty,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (sourceId != null) 'source_id': sourceId,
      if (sourcePage != null) 'source_page': sourcePage,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FlashcardsCompanion copyWith(
      {Value<int>? id,
      Value<int>? topicId,
      Value<String>? front,
      Value<String>? back,
      Value<String?>? hint,
      Value<String>? difficulty,
      Value<String>? tagsJson,
      Value<int?>? sourceId,
      Value<int?>? sourcePage,
      Value<DateTime>? createdAt}) {
    return FlashcardsCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      front: front ?? this.front,
      back: back ?? this.back,
      hint: hint ?? this.hint,
      difficulty: difficulty ?? this.difficulty,
      tagsJson: tagsJson ?? this.tagsJson,
      sourceId: sourceId ?? this.sourceId,
      sourcePage: sourcePage ?? this.sourcePage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<int>(topicId.value);
    }
    if (front.present) {
      map['front'] = Variable<String>(front.value);
    }
    if (back.present) {
      map['back'] = Variable<String>(back.value);
    }
    if (hint.present) {
      map['hint'] = Variable<String>(hint.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (sourcePage.present) {
      map['source_page'] = Variable<int>(sourcePage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FlashcardsCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('front: $front, ')
          ..write('back: $back, ')
          ..write('hint: $hint, ')
          ..write('difficulty: $difficulty, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _topicIdMeta =
      const VerificationMeta('topicId');
  @override
  late final GeneratedColumn<int> topicId = GeneratedColumn<int>(
      'topic_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES topics (id)'));
  static const VerificationMeta _qtypeMeta = const VerificationMeta('qtype');
  @override
  late final GeneratedColumn<String> qtype = GeneratedColumn<String>(
      'qtype', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('single'));
  static const VerificationMeta _stemMeta = const VerificationMeta('stem');
  @override
  late final GeneratedColumn<String> stem = GeneratedColumn<String>(
      'stem', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _explanationMeta =
      const VerificationMeta('explanation');
  @override
  late final GeneratedColumn<String> explanation = GeneratedColumn<String>(
      'explanation', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<String> difficulty = GeneratedColumn<String>(
      'difficulty', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('medium'));
  static const VerificationMeta _tagsJsonMeta =
      const VerificationMeta('tagsJson');
  @override
  late final GeneratedColumn<String> tagsJson = GeneratedColumn<String>(
      'tags_json', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _sourceIdMeta =
      const VerificationMeta('sourceId');
  @override
  late final GeneratedColumn<int> sourceId = GeneratedColumn<int>(
      'source_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sources (id)'));
  static const VerificationMeta _sourcePageMeta =
      const VerificationMeta('sourcePage');
  @override
  late final GeneratedColumn<int> sourcePage = GeneratedColumn<int>(
      'source_page', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        topicId,
        qtype,
        stem,
        explanation,
        difficulty,
        tagsJson,
        sourceId,
        sourcePage,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(Insertable<Question> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('topic_id')) {
      context.handle(_topicIdMeta,
          topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta));
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('qtype')) {
      context.handle(
          _qtypeMeta, qtype.isAcceptableOrUnknown(data['qtype']!, _qtypeMeta));
    }
    if (data.containsKey('stem')) {
      context.handle(
          _stemMeta, stem.isAcceptableOrUnknown(data['stem']!, _stemMeta));
    } else if (isInserting) {
      context.missing(_stemMeta);
    }
    if (data.containsKey('explanation')) {
      context.handle(
          _explanationMeta,
          explanation.isAcceptableOrUnknown(
              data['explanation']!, _explanationMeta));
    }
    if (data.containsKey('difficulty')) {
      context.handle(
          _difficultyMeta,
          difficulty.isAcceptableOrUnknown(
              data['difficulty']!, _difficultyMeta));
    }
    if (data.containsKey('tags_json')) {
      context.handle(_tagsJsonMeta,
          tagsJson.isAcceptableOrUnknown(data['tags_json']!, _tagsJsonMeta));
    }
    if (data.containsKey('source_id')) {
      context.handle(_sourceIdMeta,
          sourceId.isAcceptableOrUnknown(data['source_id']!, _sourceIdMeta));
    }
    if (data.containsKey('source_page')) {
      context.handle(
          _sourcePageMeta,
          sourcePage.isAcceptableOrUnknown(
              data['source_page']!, _sourcePageMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      topicId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}topic_id'])!,
      qtype: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}qtype'])!,
      stem: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}stem'])!,
      explanation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}explanation']),
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}difficulty'])!,
      tagsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags_json'])!,
      sourceId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_id']),
      sourcePage: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}source_page']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final int id;
  final int topicId;
  final String qtype;
  final String stem;
  final String? explanation;
  final String difficulty;
  final String tagsJson;
  final int? sourceId;
  final int? sourcePage;
  final DateTime createdAt;
  const Question(
      {required this.id,
      required this.topicId,
      required this.qtype,
      required this.stem,
      this.explanation,
      required this.difficulty,
      required this.tagsJson,
      this.sourceId,
      this.sourcePage,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['topic_id'] = Variable<int>(topicId);
    map['qtype'] = Variable<String>(qtype);
    map['stem'] = Variable<String>(stem);
    if (!nullToAbsent || explanation != null) {
      map['explanation'] = Variable<String>(explanation);
    }
    map['difficulty'] = Variable<String>(difficulty);
    map['tags_json'] = Variable<String>(tagsJson);
    if (!nullToAbsent || sourceId != null) {
      map['source_id'] = Variable<int>(sourceId);
    }
    if (!nullToAbsent || sourcePage != null) {
      map['source_page'] = Variable<int>(sourcePage);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      topicId: Value(topicId),
      qtype: Value(qtype),
      stem: Value(stem),
      explanation: explanation == null && nullToAbsent
          ? const Value.absent()
          : Value(explanation),
      difficulty: Value(difficulty),
      tagsJson: Value(tagsJson),
      sourceId: sourceId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceId),
      sourcePage: sourcePage == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePage),
      createdAt: Value(createdAt),
    );
  }

  factory Question.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<int>(json['id']),
      topicId: serializer.fromJson<int>(json['topicId']),
      qtype: serializer.fromJson<String>(json['qtype']),
      stem: serializer.fromJson<String>(json['stem']),
      explanation: serializer.fromJson<String?>(json['explanation']),
      difficulty: serializer.fromJson<String>(json['difficulty']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      sourceId: serializer.fromJson<int?>(json['sourceId']),
      sourcePage: serializer.fromJson<int?>(json['sourcePage']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'topicId': serializer.toJson<int>(topicId),
      'qtype': serializer.toJson<String>(qtype),
      'stem': serializer.toJson<String>(stem),
      'explanation': serializer.toJson<String?>(explanation),
      'difficulty': serializer.toJson<String>(difficulty),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'sourceId': serializer.toJson<int?>(sourceId),
      'sourcePage': serializer.toJson<int?>(sourcePage),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Question copyWith(
          {int? id,
          int? topicId,
          String? qtype,
          String? stem,
          Value<String?> explanation = const Value.absent(),
          String? difficulty,
          String? tagsJson,
          Value<int?> sourceId = const Value.absent(),
          Value<int?> sourcePage = const Value.absent(),
          DateTime? createdAt}) =>
      Question(
        id: id ?? this.id,
        topicId: topicId ?? this.topicId,
        qtype: qtype ?? this.qtype,
        stem: stem ?? this.stem,
        explanation: explanation.present ? explanation.value : this.explanation,
        difficulty: difficulty ?? this.difficulty,
        tagsJson: tagsJson ?? this.tagsJson,
        sourceId: sourceId.present ? sourceId.value : this.sourceId,
        sourcePage: sourcePage.present ? sourcePage.value : this.sourcePage,
        createdAt: createdAt ?? this.createdAt,
      );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      qtype: data.qtype.present ? data.qtype.value : this.qtype,
      stem: data.stem.present ? data.stem.value : this.stem,
      explanation:
          data.explanation.present ? data.explanation.value : this.explanation,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      sourceId: data.sourceId.present ? data.sourceId.value : this.sourceId,
      sourcePage:
          data.sourcePage.present ? data.sourcePage.value : this.sourcePage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('qtype: $qtype, ')
          ..write('stem: $stem, ')
          ..write('explanation: $explanation, ')
          ..write('difficulty: $difficulty, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, topicId, qtype, stem, explanation,
      difficulty, tagsJson, sourceId, sourcePage, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.qtype == this.qtype &&
          other.stem == this.stem &&
          other.explanation == this.explanation &&
          other.difficulty == this.difficulty &&
          other.tagsJson == this.tagsJson &&
          other.sourceId == this.sourceId &&
          other.sourcePage == this.sourcePage &&
          other.createdAt == this.createdAt);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<int> id;
  final Value<int> topicId;
  final Value<String> qtype;
  final Value<String> stem;
  final Value<String?> explanation;
  final Value<String> difficulty;
  final Value<String> tagsJson;
  final Value<int?> sourceId;
  final Value<int?> sourcePage;
  final Value<DateTime> createdAt;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.qtype = const Value.absent(),
    this.stem = const Value.absent(),
    this.explanation = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  QuestionsCompanion.insert({
    this.id = const Value.absent(),
    required int topicId,
    this.qtype = const Value.absent(),
    required String stem,
    this.explanation = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.sourceId = const Value.absent(),
    this.sourcePage = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : topicId = Value(topicId),
        stem = Value(stem);
  static Insertable<Question> custom({
    Expression<int>? id,
    Expression<int>? topicId,
    Expression<String>? qtype,
    Expression<String>? stem,
    Expression<String>? explanation,
    Expression<String>? difficulty,
    Expression<String>? tagsJson,
    Expression<int>? sourceId,
    Expression<int>? sourcePage,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (qtype != null) 'qtype': qtype,
      if (stem != null) 'stem': stem,
      if (explanation != null) 'explanation': explanation,
      if (difficulty != null) 'difficulty': difficulty,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (sourceId != null) 'source_id': sourceId,
      if (sourcePage != null) 'source_page': sourcePage,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  QuestionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? topicId,
      Value<String>? qtype,
      Value<String>? stem,
      Value<String?>? explanation,
      Value<String>? difficulty,
      Value<String>? tagsJson,
      Value<int?>? sourceId,
      Value<int?>? sourcePage,
      Value<DateTime>? createdAt}) {
    return QuestionsCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      qtype: qtype ?? this.qtype,
      stem: stem ?? this.stem,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
      tagsJson: tagsJson ?? this.tagsJson,
      sourceId: sourceId ?? this.sourceId,
      sourcePage: sourcePage ?? this.sourcePage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<int>(topicId.value);
    }
    if (qtype.present) {
      map['qtype'] = Variable<String>(qtype.value);
    }
    if (stem.present) {
      map['stem'] = Variable<String>(stem.value);
    }
    if (explanation.present) {
      map['explanation'] = Variable<String>(explanation.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<String>(difficulty.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (sourceId.present) {
      map['source_id'] = Variable<int>(sourceId.value);
    }
    if (sourcePage.present) {
      map['source_page'] = Variable<int>(sourcePage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('qtype: $qtype, ')
          ..write('stem: $stem, ')
          ..write('explanation: $explanation, ')
          ..write('difficulty: $difficulty, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('sourceId: $sourceId, ')
          ..write('sourcePage: $sourcePage, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuestionOptionsTable extends QuestionOptions
    with TableInfo<$QuestionOptionsTable, QuestionOption> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionOptionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
      'question_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES questions (id)'));
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isCorrectMeta =
      const VerificationMeta('isCorrect');
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
      'is_correct', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_correct" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _orderIndexMeta =
      const VerificationMeta('orderIndex');
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
      'order_index', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, questionId, label, content, isCorrect, orderIndex];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_options';
  @override
  VerificationContext validateIntegrity(Insertable<QuestionOption> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    } else if (isInserting) {
      context.missing(_questionIdMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('is_correct')) {
      context.handle(_isCorrectMeta,
          isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta));
    }
    if (data.containsKey('order_index')) {
      context.handle(
          _orderIndexMeta,
          orderIndex.isAcceptableOrUnknown(
              data['order_index']!, _orderIndexMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionOption map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionOption(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_id'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      isCorrect: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_correct'])!,
      orderIndex: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_index'])!,
    );
  }

  @override
  $QuestionOptionsTable createAlias(String alias) {
    return $QuestionOptionsTable(attachedDatabase, alias);
  }
}

class QuestionOption extends DataClass implements Insertable<QuestionOption> {
  final int id;
  final int questionId;
  final String label;
  final String content;
  final bool isCorrect;
  final int orderIndex;
  const QuestionOption(
      {required this.id,
      required this.questionId,
      required this.label,
      required this.content,
      required this.isCorrect,
      required this.orderIndex});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question_id'] = Variable<int>(questionId);
    map['label'] = Variable<String>(label);
    map['content'] = Variable<String>(content);
    map['is_correct'] = Variable<bool>(isCorrect);
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  QuestionOptionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionOptionsCompanion(
      id: Value(id),
      questionId: Value(questionId),
      label: Value(label),
      content: Value(content),
      isCorrect: Value(isCorrect),
      orderIndex: Value(orderIndex),
    );
  }

  factory QuestionOption.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionOption(
      id: serializer.fromJson<int>(json['id']),
      questionId: serializer.fromJson<int>(json['questionId']),
      label: serializer.fromJson<String>(json['label']),
      content: serializer.fromJson<String>(json['content']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'questionId': serializer.toJson<int>(questionId),
      'label': serializer.toJson<String>(label),
      'content': serializer.toJson<String>(content),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  QuestionOption copyWith(
          {int? id,
          int? questionId,
          String? label,
          String? content,
          bool? isCorrect,
          int? orderIndex}) =>
      QuestionOption(
        id: id ?? this.id,
        questionId: questionId ?? this.questionId,
        label: label ?? this.label,
        content: content ?? this.content,
        isCorrect: isCorrect ?? this.isCorrect,
        orderIndex: orderIndex ?? this.orderIndex,
      );
  QuestionOption copyWithCompanion(QuestionOptionsCompanion data) {
    return QuestionOption(
      id: data.id.present ? data.id.value : this.id,
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      label: data.label.present ? data.label.value : this.label,
      content: data.content.present ? data.content.value : this.content,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      orderIndex:
          data.orderIndex.present ? data.orderIndex.value : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionOption(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('content: $content, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, questionId, label, content, isCorrect, orderIndex);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionOption &&
          other.id == this.id &&
          other.questionId == this.questionId &&
          other.label == this.label &&
          other.content == this.content &&
          other.isCorrect == this.isCorrect &&
          other.orderIndex == this.orderIndex);
}

class QuestionOptionsCompanion extends UpdateCompanion<QuestionOption> {
  final Value<int> id;
  final Value<int> questionId;
  final Value<String> label;
  final Value<String> content;
  final Value<bool> isCorrect;
  final Value<int> orderIndex;
  const QuestionOptionsCompanion({
    this.id = const Value.absent(),
    this.questionId = const Value.absent(),
    this.label = const Value.absent(),
    this.content = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.orderIndex = const Value.absent(),
  });
  QuestionOptionsCompanion.insert({
    this.id = const Value.absent(),
    required int questionId,
    required String label,
    required String content,
    this.isCorrect = const Value.absent(),
    this.orderIndex = const Value.absent(),
  })  : questionId = Value(questionId),
        label = Value(label),
        content = Value(content);
  static Insertable<QuestionOption> custom({
    Expression<int>? id,
    Expression<int>? questionId,
    Expression<String>? label,
    Expression<String>? content,
    Expression<bool>? isCorrect,
    Expression<int>? orderIndex,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (questionId != null) 'question_id': questionId,
      if (label != null) 'label': label,
      if (content != null) 'content': content,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (orderIndex != null) 'order_index': orderIndex,
    });
  }

  QuestionOptionsCompanion copyWith(
      {Value<int>? id,
      Value<int>? questionId,
      Value<String>? label,
      Value<String>? content,
      Value<bool>? isCorrect,
      Value<int>? orderIndex}) {
    return QuestionOptionsCompanion(
      id: id ?? this.id,
      questionId: questionId ?? this.questionId,
      label: label ?? this.label,
      content: content ?? this.content,
      isCorrect: isCorrect ?? this.isCorrect,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionOptionsCompanion(')
          ..write('id: $id, ')
          ..write('questionId: $questionId, ')
          ..write('label: $label, ')
          ..write('content: $content, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }
}

class $UserCardStateTable extends UserCardState
    with TableInfo<$UserCardStateTable, UserCardStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserCardStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _flashcardIdMeta =
      const VerificationMeta('flashcardId');
  @override
  late final GeneratedColumn<int> flashcardId = GeneratedColumn<int>(
      'flashcard_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES flashcards (id)'));
  static const VerificationMeta _easeMeta = const VerificationMeta('ease');
  @override
  late final GeneratedColumn<double> ease = GeneratedColumn<double>(
      'ease', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2.5));
  static const VerificationMeta _intervalDaysMeta =
      const VerificationMeta('intervalDays');
  @override
  late final GeneratedColumn<int> intervalDays = GeneratedColumn<int>(
      'interval_days', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _nextReviewMeta =
      const VerificationMeta('nextReview');
  @override
  late final GeneratedColumn<DateTime> nextReview = GeneratedColumn<DateTime>(
      'next_review', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastResultMeta =
      const VerificationMeta('lastResult');
  @override
  late final GeneratedColumn<String> lastResult = GeneratedColumn<String>(
      'last_result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reviewCountMeta =
      const VerificationMeta('reviewCount');
  @override
  late final GeneratedColumn<int> reviewCount = GeneratedColumn<int>(
      'review_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        flashcardId,
        ease,
        intervalDays,
        nextReview,
        lastResult,
        reviewCount,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_card_state';
  @override
  VerificationContext validateIntegrity(Insertable<UserCardStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('flashcard_id')) {
      context.handle(
          _flashcardIdMeta,
          flashcardId.isAcceptableOrUnknown(
              data['flashcard_id']!, _flashcardIdMeta));
    }
    if (data.containsKey('ease')) {
      context.handle(
          _easeMeta, ease.isAcceptableOrUnknown(data['ease']!, _easeMeta));
    }
    if (data.containsKey('interval_days')) {
      context.handle(
          _intervalDaysMeta,
          intervalDays.isAcceptableOrUnknown(
              data['interval_days']!, _intervalDaysMeta));
    }
    if (data.containsKey('next_review')) {
      context.handle(
          _nextReviewMeta,
          nextReview.isAcceptableOrUnknown(
              data['next_review']!, _nextReviewMeta));
    }
    if (data.containsKey('last_result')) {
      context.handle(
          _lastResultMeta,
          lastResult.isAcceptableOrUnknown(
              data['last_result']!, _lastResultMeta));
    }
    if (data.containsKey('review_count')) {
      context.handle(
          _reviewCountMeta,
          reviewCount.isAcceptableOrUnknown(
              data['review_count']!, _reviewCountMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {flashcardId};
  @override
  UserCardStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserCardStateData(
      flashcardId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}flashcard_id'])!,
      ease: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}ease'])!,
      intervalDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval_days'])!,
      nextReview: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_review']),
      lastResult: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_result']),
      reviewCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}review_count'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserCardStateTable createAlias(String alias) {
    return $UserCardStateTable(attachedDatabase, alias);
  }
}

class UserCardStateData extends DataClass
    implements Insertable<UserCardStateData> {
  final int flashcardId;
  final double ease;
  final int intervalDays;
  final DateTime? nextReview;
  final String? lastResult;
  final int reviewCount;
  final DateTime updatedAt;
  const UserCardStateData(
      {required this.flashcardId,
      required this.ease,
      required this.intervalDays,
      this.nextReview,
      this.lastResult,
      required this.reviewCount,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['flashcard_id'] = Variable<int>(flashcardId);
    map['ease'] = Variable<double>(ease);
    map['interval_days'] = Variable<int>(intervalDays);
    if (!nullToAbsent || nextReview != null) {
      map['next_review'] = Variable<DateTime>(nextReview);
    }
    if (!nullToAbsent || lastResult != null) {
      map['last_result'] = Variable<String>(lastResult);
    }
    map['review_count'] = Variable<int>(reviewCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserCardStateCompanion toCompanion(bool nullToAbsent) {
    return UserCardStateCompanion(
      flashcardId: Value(flashcardId),
      ease: Value(ease),
      intervalDays: Value(intervalDays),
      nextReview: nextReview == null && nullToAbsent
          ? const Value.absent()
          : Value(nextReview),
      lastResult: lastResult == null && nullToAbsent
          ? const Value.absent()
          : Value(lastResult),
      reviewCount: Value(reviewCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserCardStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserCardStateData(
      flashcardId: serializer.fromJson<int>(json['flashcardId']),
      ease: serializer.fromJson<double>(json['ease']),
      intervalDays: serializer.fromJson<int>(json['intervalDays']),
      nextReview: serializer.fromJson<DateTime?>(json['nextReview']),
      lastResult: serializer.fromJson<String?>(json['lastResult']),
      reviewCount: serializer.fromJson<int>(json['reviewCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'flashcardId': serializer.toJson<int>(flashcardId),
      'ease': serializer.toJson<double>(ease),
      'intervalDays': serializer.toJson<int>(intervalDays),
      'nextReview': serializer.toJson<DateTime?>(nextReview),
      'lastResult': serializer.toJson<String?>(lastResult),
      'reviewCount': serializer.toJson<int>(reviewCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserCardStateData copyWith(
          {int? flashcardId,
          double? ease,
          int? intervalDays,
          Value<DateTime?> nextReview = const Value.absent(),
          Value<String?> lastResult = const Value.absent(),
          int? reviewCount,
          DateTime? updatedAt}) =>
      UserCardStateData(
        flashcardId: flashcardId ?? this.flashcardId,
        ease: ease ?? this.ease,
        intervalDays: intervalDays ?? this.intervalDays,
        nextReview: nextReview.present ? nextReview.value : this.nextReview,
        lastResult: lastResult.present ? lastResult.value : this.lastResult,
        reviewCount: reviewCount ?? this.reviewCount,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserCardStateData copyWithCompanion(UserCardStateCompanion data) {
    return UserCardStateData(
      flashcardId:
          data.flashcardId.present ? data.flashcardId.value : this.flashcardId,
      ease: data.ease.present ? data.ease.value : this.ease,
      intervalDays: data.intervalDays.present
          ? data.intervalDays.value
          : this.intervalDays,
      nextReview:
          data.nextReview.present ? data.nextReview.value : this.nextReview,
      lastResult:
          data.lastResult.present ? data.lastResult.value : this.lastResult,
      reviewCount:
          data.reviewCount.present ? data.reviewCount.value : this.reviewCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserCardStateData(')
          ..write('flashcardId: $flashcardId, ')
          ..write('ease: $ease, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastResult: $lastResult, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(flashcardId, ease, intervalDays, nextReview,
      lastResult, reviewCount, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserCardStateData &&
          other.flashcardId == this.flashcardId &&
          other.ease == this.ease &&
          other.intervalDays == this.intervalDays &&
          other.nextReview == this.nextReview &&
          other.lastResult == this.lastResult &&
          other.reviewCount == this.reviewCount &&
          other.updatedAt == this.updatedAt);
}

class UserCardStateCompanion extends UpdateCompanion<UserCardStateData> {
  final Value<int> flashcardId;
  final Value<double> ease;
  final Value<int> intervalDays;
  final Value<DateTime?> nextReview;
  final Value<String?> lastResult;
  final Value<int> reviewCount;
  final Value<DateTime> updatedAt;
  const UserCardStateCompanion({
    this.flashcardId = const Value.absent(),
    this.ease = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserCardStateCompanion.insert({
    this.flashcardId = const Value.absent(),
    this.ease = const Value.absent(),
    this.intervalDays = const Value.absent(),
    this.nextReview = const Value.absent(),
    this.lastResult = const Value.absent(),
    this.reviewCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserCardStateData> custom({
    Expression<int>? flashcardId,
    Expression<double>? ease,
    Expression<int>? intervalDays,
    Expression<DateTime>? nextReview,
    Expression<String>? lastResult,
    Expression<int>? reviewCount,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (flashcardId != null) 'flashcard_id': flashcardId,
      if (ease != null) 'ease': ease,
      if (intervalDays != null) 'interval_days': intervalDays,
      if (nextReview != null) 'next_review': nextReview,
      if (lastResult != null) 'last_result': lastResult,
      if (reviewCount != null) 'review_count': reviewCount,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserCardStateCompanion copyWith(
      {Value<int>? flashcardId,
      Value<double>? ease,
      Value<int>? intervalDays,
      Value<DateTime?>? nextReview,
      Value<String?>? lastResult,
      Value<int>? reviewCount,
      Value<DateTime>? updatedAt}) {
    return UserCardStateCompanion(
      flashcardId: flashcardId ?? this.flashcardId,
      ease: ease ?? this.ease,
      intervalDays: intervalDays ?? this.intervalDays,
      nextReview: nextReview ?? this.nextReview,
      lastResult: lastResult ?? this.lastResult,
      reviewCount: reviewCount ?? this.reviewCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (flashcardId.present) {
      map['flashcard_id'] = Variable<int>(flashcardId.value);
    }
    if (ease.present) {
      map['ease'] = Variable<double>(ease.value);
    }
    if (intervalDays.present) {
      map['interval_days'] = Variable<int>(intervalDays.value);
    }
    if (nextReview.present) {
      map['next_review'] = Variable<DateTime>(nextReview.value);
    }
    if (lastResult.present) {
      map['last_result'] = Variable<String>(lastResult.value);
    }
    if (reviewCount.present) {
      map['review_count'] = Variable<int>(reviewCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCardStateCompanion(')
          ..write('flashcardId: $flashcardId, ')
          ..write('ease: $ease, ')
          ..write('intervalDays: $intervalDays, ')
          ..write('nextReview: $nextReview, ')
          ..write('lastResult: $lastResult, ')
          ..write('reviewCount: $reviewCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserQuestionStateTable extends UserQuestionState
    with TableInfo<$UserQuestionStateTable, UserQuestionStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserQuestionStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _questionIdMeta =
      const VerificationMeta('questionId');
  @override
  late final GeneratedColumn<int> questionId = GeneratedColumn<int>(
      'question_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES questions (id)'));
  static const VerificationMeta _attemptsMeta =
      const VerificationMeta('attempts');
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
      'attempts', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _correctMeta =
      const VerificationMeta('correct');
  @override
  late final GeneratedColumn<int> correct = GeneratedColumn<int>(
      'correct', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastAttemptMeta =
      const VerificationMeta('lastAttempt');
  @override
  late final GeneratedColumn<DateTime> lastAttempt = GeneratedColumn<DateTime>(
      'last_attempt', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastChoiceMeta =
      const VerificationMeta('lastChoice');
  @override
  late final GeneratedColumn<String> lastChoice = GeneratedColumn<String>(
      'last_choice', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [questionId, attempts, correct, lastAttempt, lastChoice, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_question_state';
  @override
  VerificationContext validateIntegrity(
      Insertable<UserQuestionStateData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('question_id')) {
      context.handle(
          _questionIdMeta,
          questionId.isAcceptableOrUnknown(
              data['question_id']!, _questionIdMeta));
    }
    if (data.containsKey('attempts')) {
      context.handle(_attemptsMeta,
          attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta));
    }
    if (data.containsKey('correct')) {
      context.handle(_correctMeta,
          correct.isAcceptableOrUnknown(data['correct']!, _correctMeta));
    }
    if (data.containsKey('last_attempt')) {
      context.handle(
          _lastAttemptMeta,
          lastAttempt.isAcceptableOrUnknown(
              data['last_attempt']!, _lastAttemptMeta));
    }
    if (data.containsKey('last_choice')) {
      context.handle(
          _lastChoiceMeta,
          lastChoice.isAcceptableOrUnknown(
              data['last_choice']!, _lastChoiceMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {questionId};
  @override
  UserQuestionStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserQuestionStateData(
      questionId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}question_id'])!,
      attempts: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}attempts'])!,
      correct: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}correct'])!,
      lastAttempt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_attempt']),
      lastChoice: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}last_choice']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserQuestionStateTable createAlias(String alias) {
    return $UserQuestionStateTable(attachedDatabase, alias);
  }
}

class UserQuestionStateData extends DataClass
    implements Insertable<UserQuestionStateData> {
  final int questionId;
  final int attempts;
  final int correct;
  final DateTime? lastAttempt;
  final String? lastChoice;
  final DateTime updatedAt;
  const UserQuestionStateData(
      {required this.questionId,
      required this.attempts,
      required this.correct,
      this.lastAttempt,
      this.lastChoice,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['question_id'] = Variable<int>(questionId);
    map['attempts'] = Variable<int>(attempts);
    map['correct'] = Variable<int>(correct);
    if (!nullToAbsent || lastAttempt != null) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt);
    }
    if (!nullToAbsent || lastChoice != null) {
      map['last_choice'] = Variable<String>(lastChoice);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserQuestionStateCompanion toCompanion(bool nullToAbsent) {
    return UserQuestionStateCompanion(
      questionId: Value(questionId),
      attempts: Value(attempts),
      correct: Value(correct),
      lastAttempt: lastAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttempt),
      lastChoice: lastChoice == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChoice),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserQuestionStateData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserQuestionStateData(
      questionId: serializer.fromJson<int>(json['questionId']),
      attempts: serializer.fromJson<int>(json['attempts']),
      correct: serializer.fromJson<int>(json['correct']),
      lastAttempt: serializer.fromJson<DateTime?>(json['lastAttempt']),
      lastChoice: serializer.fromJson<String?>(json['lastChoice']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'questionId': serializer.toJson<int>(questionId),
      'attempts': serializer.toJson<int>(attempts),
      'correct': serializer.toJson<int>(correct),
      'lastAttempt': serializer.toJson<DateTime?>(lastAttempt),
      'lastChoice': serializer.toJson<String?>(lastChoice),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserQuestionStateData copyWith(
          {int? questionId,
          int? attempts,
          int? correct,
          Value<DateTime?> lastAttempt = const Value.absent(),
          Value<String?> lastChoice = const Value.absent(),
          DateTime? updatedAt}) =>
      UserQuestionStateData(
        questionId: questionId ?? this.questionId,
        attempts: attempts ?? this.attempts,
        correct: correct ?? this.correct,
        lastAttempt: lastAttempt.present ? lastAttempt.value : this.lastAttempt,
        lastChoice: lastChoice.present ? lastChoice.value : this.lastChoice,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserQuestionStateData copyWithCompanion(UserQuestionStateCompanion data) {
    return UserQuestionStateData(
      questionId:
          data.questionId.present ? data.questionId.value : this.questionId,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      correct: data.correct.present ? data.correct.value : this.correct,
      lastAttempt:
          data.lastAttempt.present ? data.lastAttempt.value : this.lastAttempt,
      lastChoice:
          data.lastChoice.present ? data.lastChoice.value : this.lastChoice,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserQuestionStateData(')
          ..write('questionId: $questionId, ')
          ..write('attempts: $attempts, ')
          ..write('correct: $correct, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('lastChoice: $lastChoice, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      questionId, attempts, correct, lastAttempt, lastChoice, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserQuestionStateData &&
          other.questionId == this.questionId &&
          other.attempts == this.attempts &&
          other.correct == this.correct &&
          other.lastAttempt == this.lastAttempt &&
          other.lastChoice == this.lastChoice &&
          other.updatedAt == this.updatedAt);
}

class UserQuestionStateCompanion
    extends UpdateCompanion<UserQuestionStateData> {
  final Value<int> questionId;
  final Value<int> attempts;
  final Value<int> correct;
  final Value<DateTime?> lastAttempt;
  final Value<String?> lastChoice;
  final Value<DateTime> updatedAt;
  const UserQuestionStateCompanion({
    this.questionId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.correct = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.lastChoice = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserQuestionStateCompanion.insert({
    this.questionId = const Value.absent(),
    this.attempts = const Value.absent(),
    this.correct = const Value.absent(),
    this.lastAttempt = const Value.absent(),
    this.lastChoice = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<UserQuestionStateData> custom({
    Expression<int>? questionId,
    Expression<int>? attempts,
    Expression<int>? correct,
    Expression<DateTime>? lastAttempt,
    Expression<String>? lastChoice,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (questionId != null) 'question_id': questionId,
      if (attempts != null) 'attempts': attempts,
      if (correct != null) 'correct': correct,
      if (lastAttempt != null) 'last_attempt': lastAttempt,
      if (lastChoice != null) 'last_choice': lastChoice,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserQuestionStateCompanion copyWith(
      {Value<int>? questionId,
      Value<int>? attempts,
      Value<int>? correct,
      Value<DateTime?>? lastAttempt,
      Value<String?>? lastChoice,
      Value<DateTime>? updatedAt}) {
    return UserQuestionStateCompanion(
      questionId: questionId ?? this.questionId,
      attempts: attempts ?? this.attempts,
      correct: correct ?? this.correct,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      lastChoice: lastChoice ?? this.lastChoice,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (questionId.present) {
      map['question_id'] = Variable<int>(questionId.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (correct.present) {
      map['correct'] = Variable<int>(correct.value);
    }
    if (lastAttempt.present) {
      map['last_attempt'] = Variable<DateTime>(lastAttempt.value);
    }
    if (lastChoice.present) {
      map['last_choice'] = Variable<String>(lastChoice.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserQuestionStateCompanion(')
          ..write('questionId: $questionId, ')
          ..write('attempts: $attempts, ')
          ..write('correct: $correct, ')
          ..write('lastAttempt: $lastAttempt, ')
          ..write('lastChoice: $lastChoice, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserBookmarksTable extends UserBookmarks
    with TableInfo<$UserBookmarksTable, UserBookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemKindMeta =
      const VerificationMeta('itemKind');
  @override
  late final GeneratedColumn<String> itemKind = GeneratedColumn<String>(
      'item_kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [itemKind, itemId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_bookmarks';
  @override
  VerificationContext validateIntegrity(Insertable<UserBookmark> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_kind')) {
      context.handle(_itemKindMeta,
          itemKind.isAcceptableOrUnknown(data['item_kind']!, _itemKindMeta));
    } else if (isInserting) {
      context.missing(_itemKindMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemKind, itemId};
  @override
  UserBookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserBookmark(
      itemKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_kind'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UserBookmarksTable createAlias(String alias) {
    return $UserBookmarksTable(attachedDatabase, alias);
  }
}

class UserBookmark extends DataClass implements Insertable<UserBookmark> {
  final String itemKind;
  final int itemId;
  final DateTime createdAt;
  const UserBookmark(
      {required this.itemKind, required this.itemId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_kind'] = Variable<String>(itemKind);
    map['item_id'] = Variable<int>(itemId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserBookmarksCompanion toCompanion(bool nullToAbsent) {
    return UserBookmarksCompanion(
      itemKind: Value(itemKind),
      itemId: Value(itemId),
      createdAt: Value(createdAt),
    );
  }

  factory UserBookmark.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserBookmark(
      itemKind: serializer.fromJson<String>(json['itemKind']),
      itemId: serializer.fromJson<int>(json['itemId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemKind': serializer.toJson<String>(itemKind),
      'itemId': serializer.toJson<int>(itemId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserBookmark copyWith({String? itemKind, int? itemId, DateTime? createdAt}) =>
      UserBookmark(
        itemKind: itemKind ?? this.itemKind,
        itemId: itemId ?? this.itemId,
        createdAt: createdAt ?? this.createdAt,
      );
  UserBookmark copyWithCompanion(UserBookmarksCompanion data) {
    return UserBookmark(
      itemKind: data.itemKind.present ? data.itemKind.value : this.itemKind,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserBookmark(')
          ..write('itemKind: $itemKind, ')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemKind, itemId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserBookmark &&
          other.itemKind == this.itemKind &&
          other.itemId == this.itemId &&
          other.createdAt == this.createdAt);
}

class UserBookmarksCompanion extends UpdateCompanion<UserBookmark> {
  final Value<String> itemKind;
  final Value<int> itemId;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserBookmarksCompanion({
    this.itemKind = const Value.absent(),
    this.itemId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserBookmarksCompanion.insert({
    required String itemKind,
    required int itemId,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : itemKind = Value(itemKind),
        itemId = Value(itemId);
  static Insertable<UserBookmark> custom({
    Expression<String>? itemKind,
    Expression<int>? itemId,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemKind != null) 'item_kind': itemKind,
      if (itemId != null) 'item_id': itemId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserBookmarksCompanion copyWith(
      {Value<String>? itemKind,
      Value<int>? itemId,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UserBookmarksCompanion(
      itemKind: itemKind ?? this.itemKind,
      itemId: itemId ?? this.itemId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemKind.present) {
      map['item_kind'] = Variable<String>(itemKind.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserBookmarksCompanion(')
          ..write('itemKind: $itemKind, ')
          ..write('itemId: $itemId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserNotesTable extends UserNotes
    with TableInfo<$UserNotesTable, UserNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _itemKindMeta =
      const VerificationMeta('itemKind');
  @override
  late final GeneratedColumn<String> itemKind = GeneratedColumn<String>(
      'item_kind', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
      'item_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, itemKind, itemId, body, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_notes';
  @override
  VerificationContext validateIntegrity(Insertable<UserNote> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('item_kind')) {
      context.handle(_itemKindMeta,
          itemKind.isAcceptableOrUnknown(data['item_kind']!, _itemKindMeta));
    } else if (isInserting) {
      context.missing(_itemKindMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserNote(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      itemKind: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_kind'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}item_id'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserNotesTable createAlias(String alias) {
    return $UserNotesTable(attachedDatabase, alias);
  }
}

class UserNote extends DataClass implements Insertable<UserNote> {
  final int id;
  final String itemKind;
  final int itemId;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserNote(
      {required this.id,
      required this.itemKind,
      required this.itemId,
      required this.body,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['item_kind'] = Variable<String>(itemKind);
    map['item_id'] = Variable<int>(itemId);
    map['body'] = Variable<String>(body);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserNotesCompanion toCompanion(bool nullToAbsent) {
    return UserNotesCompanion(
      id: Value(id),
      itemKind: Value(itemKind),
      itemId: Value(itemId),
      body: Value(body),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserNote.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserNote(
      id: serializer.fromJson<int>(json['id']),
      itemKind: serializer.fromJson<String>(json['itemKind']),
      itemId: serializer.fromJson<int>(json['itemId']),
      body: serializer.fromJson<String>(json['body']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'itemKind': serializer.toJson<String>(itemKind),
      'itemId': serializer.toJson<int>(itemId),
      'body': serializer.toJson<String>(body),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserNote copyWith(
          {int? id,
          String? itemKind,
          int? itemId,
          String? body,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      UserNote(
        id: id ?? this.id,
        itemKind: itemKind ?? this.itemKind,
        itemId: itemId ?? this.itemId,
        body: body ?? this.body,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserNote copyWithCompanion(UserNotesCompanion data) {
    return UserNote(
      id: data.id.present ? data.id.value : this.id,
      itemKind: data.itemKind.present ? data.itemKind.value : this.itemKind,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
      body: data.body.present ? data.body.value : this.body,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserNote(')
          ..write('id: $id, ')
          ..write('itemKind: $itemKind, ')
          ..write('itemId: $itemId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, itemKind, itemId, body, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserNote &&
          other.id == this.id &&
          other.itemKind == this.itemKind &&
          other.itemId == this.itemId &&
          other.body == this.body &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserNotesCompanion extends UpdateCompanion<UserNote> {
  final Value<int> id;
  final Value<String> itemKind;
  final Value<int> itemId;
  final Value<String> body;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const UserNotesCompanion({
    this.id = const Value.absent(),
    this.itemKind = const Value.absent(),
    this.itemId = const Value.absent(),
    this.body = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  UserNotesCompanion.insert({
    this.id = const Value.absent(),
    required String itemKind,
    required int itemId,
    required String body,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : itemKind = Value(itemKind),
        itemId = Value(itemId),
        body = Value(body);
  static Insertable<UserNote> custom({
    Expression<int>? id,
    Expression<String>? itemKind,
    Expression<int>? itemId,
    Expression<String>? body,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (itemKind != null) 'item_kind': itemKind,
      if (itemId != null) 'item_id': itemId,
      if (body != null) 'body': body,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  UserNotesCompanion copyWith(
      {Value<int>? id,
      Value<String>? itemKind,
      Value<int>? itemId,
      Value<String>? body,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return UserNotesCompanion(
      id: id ?? this.id,
      itemKind: itemKind ?? this.itemKind,
      itemId: itemId ?? this.itemId,
      body: body ?? this.body,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (itemKind.present) {
      map['item_kind'] = Variable<String>(itemKind.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserNotesCompanion(')
          ..write('id: $id, ')
          ..write('itemKind: $itemKind, ')
          ..write('itemId: $itemId, ')
          ..write('body: $body, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $UserSessionsTable extends UserSessions
    with TableInfo<$UserSessionsTable, UserSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _cardsReviewedMeta =
      const VerificationMeta('cardsReviewed');
  @override
  late final GeneratedColumn<int> cardsReviewed = GeneratedColumn<int>(
      'cards_reviewed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _questionsAnsweredMeta =
      const VerificationMeta('questionsAnswered');
  @override
  late final GeneratedColumn<int> questionsAnswered = GeneratedColumn<int>(
      'questions_answered', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
      'mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('study'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, startedAt, endedAt, cardsReviewed, questionsAnswered, mode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_sessions';
  @override
  VerificationContext validateIntegrity(Insertable<UserSession> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('cards_reviewed')) {
      context.handle(
          _cardsReviewedMeta,
          cardsReviewed.isAcceptableOrUnknown(
              data['cards_reviewed']!, _cardsReviewedMeta));
    }
    if (data.containsKey('questions_answered')) {
      context.handle(
          _questionsAnsweredMeta,
          questionsAnswered.isAcceptableOrUnknown(
              data['questions_answered']!, _questionsAnsweredMeta));
    }
    if (data.containsKey('mode')) {
      context.handle(
          _modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserSession(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at'])!,
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      cardsReviewed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cards_reviewed'])!,
      questionsAnswered: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}questions_answered'])!,
      mode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mode'])!,
    );
  }

  @override
  $UserSessionsTable createAlias(String alias) {
    return $UserSessionsTable(attachedDatabase, alias);
  }
}

class UserSession extends DataClass implements Insertable<UserSession> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int cardsReviewed;
  final int questionsAnswered;
  final String mode;
  const UserSession(
      {required this.id,
      required this.startedAt,
      this.endedAt,
      required this.cardsReviewed,
      required this.questionsAnswered,
      required this.mode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['cards_reviewed'] = Variable<int>(cardsReviewed);
    map['questions_answered'] = Variable<int>(questionsAnswered);
    map['mode'] = Variable<String>(mode);
    return map;
  }

  UserSessionsCompanion toCompanion(bool nullToAbsent) {
    return UserSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      cardsReviewed: Value(cardsReviewed),
      questionsAnswered: Value(questionsAnswered),
      mode: Value(mode),
    );
  }

  factory UserSession.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserSession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      cardsReviewed: serializer.fromJson<int>(json['cardsReviewed']),
      questionsAnswered: serializer.fromJson<int>(json['questionsAnswered']),
      mode: serializer.fromJson<String>(json['mode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'cardsReviewed': serializer.toJson<int>(cardsReviewed),
      'questionsAnswered': serializer.toJson<int>(questionsAnswered),
      'mode': serializer.toJson<String>(mode),
    };
  }

  UserSession copyWith(
          {int? id,
          DateTime? startedAt,
          Value<DateTime?> endedAt = const Value.absent(),
          int? cardsReviewed,
          int? questionsAnswered,
          String? mode}) =>
      UserSession(
        id: id ?? this.id,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        cardsReviewed: cardsReviewed ?? this.cardsReviewed,
        questionsAnswered: questionsAnswered ?? this.questionsAnswered,
        mode: mode ?? this.mode,
      );
  UserSession copyWithCompanion(UserSessionsCompanion data) {
    return UserSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      cardsReviewed: data.cardsReviewed.present
          ? data.cardsReviewed.value
          : this.cardsReviewed,
      questionsAnswered: data.questionsAnswered.present
          ? data.questionsAnswered.value
          : this.questionsAnswered,
      mode: data.mode.present ? data.mode.value : this.mode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('questionsAnswered: $questionsAnswered, ')
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, startedAt, endedAt, cardsReviewed, questionsAnswered, mode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.cardsReviewed == this.cardsReviewed &&
          other.questionsAnswered == this.questionsAnswered &&
          other.mode == this.mode);
}

class UserSessionsCompanion extends UpdateCompanion<UserSession> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> cardsReviewed;
  final Value<int> questionsAnswered;
  final Value<String> mode;
  const UserSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.questionsAnswered = const Value.absent(),
    this.mode = const Value.absent(),
  });
  UserSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.questionsAnswered = const Value.absent(),
    this.mode = const Value.absent(),
  }) : startedAt = Value(startedAt);
  static Insertable<UserSession> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? cardsReviewed,
    Expression<int>? questionsAnswered,
    Expression<String>? mode,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (cardsReviewed != null) 'cards_reviewed': cardsReviewed,
      if (questionsAnswered != null) 'questions_answered': questionsAnswered,
      if (mode != null) 'mode': mode,
    });
  }

  UserSessionsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? startedAt,
      Value<DateTime?>? endedAt,
      Value<int>? cardsReviewed,
      Value<int>? questionsAnswered,
      Value<String>? mode}) {
    return UserSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      mode: mode ?? this.mode,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (cardsReviewed.present) {
      map['cards_reviewed'] = Variable<int>(cardsReviewed.value);
    }
    if (questionsAnswered.present) {
      map['questions_answered'] = Variable<int>(questionsAnswered.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('questionsAnswered: $questionsAnswered, ')
          ..write('mode: $mode')
          ..write(')'))
        .toString();
  }
}

class $UserStreakTable extends UserStreak
    with TableInfo<$UserStreakTable, UserStreakData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserStreakTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<DateTime> day = GeneratedColumn<DateTime>(
      'day', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _cardsReviewedMeta =
      const VerificationMeta('cardsReviewed');
  @override
  late final GeneratedColumn<int> cardsReviewed = GeneratedColumn<int>(
      'cards_reviewed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _questionsAnsweredMeta =
      const VerificationMeta('questionsAnswered');
  @override
  late final GeneratedColumn<int> questionsAnswered = GeneratedColumn<int>(
      'questions_answered', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [day, cardsReviewed, questionsAnswered];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_streak';
  @override
  VerificationContext validateIntegrity(Insertable<UserStreakData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('day')) {
      context.handle(
          _dayMeta, day.isAcceptableOrUnknown(data['day']!, _dayMeta));
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('cards_reviewed')) {
      context.handle(
          _cardsReviewedMeta,
          cardsReviewed.isAcceptableOrUnknown(
              data['cards_reviewed']!, _cardsReviewedMeta));
    }
    if (data.containsKey('questions_answered')) {
      context.handle(
          _questionsAnsweredMeta,
          questionsAnswered.isAcceptableOrUnknown(
              data['questions_answered']!, _questionsAnsweredMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {day};
  @override
  UserStreakData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserStreakData(
      day: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}day'])!,
      cardsReviewed: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cards_reviewed'])!,
      questionsAnswered: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}questions_answered'])!,
    );
  }

  @override
  $UserStreakTable createAlias(String alias) {
    return $UserStreakTable(attachedDatabase, alias);
  }
}

class UserStreakData extends DataClass implements Insertable<UserStreakData> {
  final DateTime day;
  final int cardsReviewed;
  final int questionsAnswered;
  const UserStreakData(
      {required this.day,
      required this.cardsReviewed,
      required this.questionsAnswered});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['day'] = Variable<DateTime>(day);
    map['cards_reviewed'] = Variable<int>(cardsReviewed);
    map['questions_answered'] = Variable<int>(questionsAnswered);
    return map;
  }

  UserStreakCompanion toCompanion(bool nullToAbsent) {
    return UserStreakCompanion(
      day: Value(day),
      cardsReviewed: Value(cardsReviewed),
      questionsAnswered: Value(questionsAnswered),
    );
  }

  factory UserStreakData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserStreakData(
      day: serializer.fromJson<DateTime>(json['day']),
      cardsReviewed: serializer.fromJson<int>(json['cardsReviewed']),
      questionsAnswered: serializer.fromJson<int>(json['questionsAnswered']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'day': serializer.toJson<DateTime>(day),
      'cardsReviewed': serializer.toJson<int>(cardsReviewed),
      'questionsAnswered': serializer.toJson<int>(questionsAnswered),
    };
  }

  UserStreakData copyWith(
          {DateTime? day, int? cardsReviewed, int? questionsAnswered}) =>
      UserStreakData(
        day: day ?? this.day,
        cardsReviewed: cardsReviewed ?? this.cardsReviewed,
        questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      );
  UserStreakData copyWithCompanion(UserStreakCompanion data) {
    return UserStreakData(
      day: data.day.present ? data.day.value : this.day,
      cardsReviewed: data.cardsReviewed.present
          ? data.cardsReviewed.value
          : this.cardsReviewed,
      questionsAnswered: data.questionsAnswered.present
          ? data.questionsAnswered.value
          : this.questionsAnswered,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserStreakData(')
          ..write('day: $day, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('questionsAnswered: $questionsAnswered')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(day, cardsReviewed, questionsAnswered);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserStreakData &&
          other.day == this.day &&
          other.cardsReviewed == this.cardsReviewed &&
          other.questionsAnswered == this.questionsAnswered);
}

class UserStreakCompanion extends UpdateCompanion<UserStreakData> {
  final Value<DateTime> day;
  final Value<int> cardsReviewed;
  final Value<int> questionsAnswered;
  final Value<int> rowid;
  const UserStreakCompanion({
    this.day = const Value.absent(),
    this.cardsReviewed = const Value.absent(),
    this.questionsAnswered = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserStreakCompanion.insert({
    required DateTime day,
    this.cardsReviewed = const Value.absent(),
    this.questionsAnswered = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : day = Value(day);
  static Insertable<UserStreakData> custom({
    Expression<DateTime>? day,
    Expression<int>? cardsReviewed,
    Expression<int>? questionsAnswered,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (day != null) 'day': day,
      if (cardsReviewed != null) 'cards_reviewed': cardsReviewed,
      if (questionsAnswered != null) 'questions_answered': questionsAnswered,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserStreakCompanion copyWith(
      {Value<DateTime>? day,
      Value<int>? cardsReviewed,
      Value<int>? questionsAnswered,
      Value<int>? rowid}) {
    return UserStreakCompanion(
      day: day ?? this.day,
      cardsReviewed: cardsReviewed ?? this.cardsReviewed,
      questionsAnswered: questionsAnswered ?? this.questionsAnswered,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (day.present) {
      map['day'] = Variable<DateTime>(day.value);
    }
    if (cardsReviewed.present) {
      map['cards_reviewed'] = Variable<int>(cardsReviewed.value);
    }
    if (questionsAnswered.present) {
      map['questions_answered'] = Variable<int>(questionsAnswered.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserStreakCompanion(')
          ..write('day: $day, ')
          ..write('cardsReviewed: $cardsReviewed, ')
          ..write('questionsAnswered: $questionsAnswered, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $TopicsTable topics = $TopicsTable(this);
  late final $SourcesTable sources = $SourcesTable(this);
  late final $FlashcardsTable flashcards = $FlashcardsTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $QuestionOptionsTable questionOptions =
      $QuestionOptionsTable(this);
  late final $UserCardStateTable userCardState = $UserCardStateTable(this);
  late final $UserQuestionStateTable userQuestionState =
      $UserQuestionStateTable(this);
  late final $UserBookmarksTable userBookmarks = $UserBookmarksTable(this);
  late final $UserNotesTable userNotes = $UserNotesTable(this);
  late final $UserSessionsTable userSessions = $UserSessionsTable(this);
  late final $UserStreakTable userStreak = $UserStreakTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        subjects,
        chapters,
        topics,
        sources,
        flashcards,
        questions,
        questionOptions,
        userCardState,
        userQuestionState,
        userBookmarks,
        userNotes,
        userSessions,
        userStreak
      ];
}

typedef $$SubjectsTableCreateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  required String code,
  required String title,
  Value<String?> description,
  Value<int> orderIndex,
});
typedef $$SubjectsTableUpdateCompanionBuilder = SubjectsCompanion Function({
  Value<int> id,
  Value<String> code,
  Value<String> title,
  Value<String?> description,
  Value<int> orderIndex,
});

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ChaptersTable, List<Chapter>> _chaptersRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.chapters,
          aliasName:
              $_aliasNameGenerator(db.subjects.id, db.chapters.subjectId));

  $$ChaptersTableProcessedTableManager get chaptersRefs {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.subjectId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_chaptersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  Expression<bool> chaptersRefs(
      Expression<bool> Function($$ChaptersTableFilterComposer f) f) {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  Expression<T> chaptersRefs<T extends Object>(
      Expression<T> Function($$ChaptersTableAnnotationComposer a) f) {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.subjectId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SubjectsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool chaptersRefs})> {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              SubjectsCompanion(
            id: id,
            code: code,
            title: title,
            description: description,
            orderIndex: orderIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String code,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              SubjectsCompanion.insert(
            id: id,
            code: code,
            title: title,
            description: description,
            orderIndex: orderIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SubjectsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({chaptersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (chaptersRefs) db.chapters],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (chaptersRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SubjectsTableReferences._chaptersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SubjectsTableReferences(db, table, p0)
                                .chaptersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.subjectId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SubjectsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SubjectsTable,
    Subject,
    $$SubjectsTableFilterComposer,
    $$SubjectsTableOrderingComposer,
    $$SubjectsTableAnnotationComposer,
    $$SubjectsTableCreateCompanionBuilder,
    $$SubjectsTableUpdateCompanionBuilder,
    (Subject, $$SubjectsTableReferences),
    Subject,
    PrefetchHooks Function({bool chaptersRefs})>;
typedef $$ChaptersTableCreateCompanionBuilder = ChaptersCompanion Function({
  Value<int> id,
  required int subjectId,
  required String code,
  required String title,
  Value<String?> description,
  Value<int> orderIndex,
});
typedef $$ChaptersTableUpdateCompanionBuilder = ChaptersCompanion Function({
  Value<int> id,
  Value<int> subjectId,
  Value<String> code,
  Value<String> title,
  Value<String?> description,
  Value<int> orderIndex,
});

final class $$ChaptersTableReferences
    extends BaseReferences<_$AppDatabase, $ChaptersTable, Chapter> {
  $$ChaptersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) => db.subjects
      .createAlias($_aliasNameGenerator(db.chapters.subjectId, db.subjects.id));

  $$SubjectsTableProcessedTableManager get subjectId {
    final manager = $$SubjectsTableTableManager($_db, $_db.subjects)
        .filter((f) => f.id($_item.subjectId));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$TopicsTable, List<Topic>> _topicsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.topics,
          aliasName: $_aliasNameGenerator(db.chapters.id, db.topics.chapterId));

  $$TopicsTableProcessedTableManager get topicsRefs {
    final manager = $$TopicsTableTableManager($_db, $_db.topics)
        .filter((f) => f.chapterId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_topicsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableFilterComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> topicsRefs(
      Expression<bool> Function($$TopicsTableFilterComposer f) f) {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableFilterComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableOrderingComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.subjectId,
        referencedTable: $db.subjects,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SubjectsTableAnnotationComposer(
              $db: $db,
              $table: $db.subjects,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> topicsRefs<T extends Object>(
      Expression<T> Function($$TopicsTableAnnotationComposer a) f) {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.chapterId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableAnnotationComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ChaptersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChaptersTable,
    Chapter,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (Chapter, $$ChaptersTableReferences),
    Chapter,
    PrefetchHooks Function({bool subjectId, bool topicsRefs})> {
  $$ChaptersTableTableManager(_$AppDatabase db, $ChaptersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> subjectId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              ChaptersCompanion(
            id: id,
            subjectId: subjectId,
            code: code,
            title: title,
            description: description,
            orderIndex: orderIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int subjectId,
            required String code,
            required String title,
            Value<String?> description = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              ChaptersCompanion.insert(
            id: id,
            subjectId: subjectId,
            code: code,
            title: title,
            description: description,
            orderIndex: orderIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ChaptersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({subjectId = false, topicsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (topicsRefs) db.topics],
              addJoins: <
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
                      dynamic>>(state) {
                if (subjectId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.subjectId,
                    referencedTable:
                        $$ChaptersTableReferences._subjectIdTable(db),
                    referencedColumn:
                        $$ChaptersTableReferences._subjectIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (topicsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ChaptersTableReferences._topicsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ChaptersTableReferences(db, table, p0).topicsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.chapterId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ChaptersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChaptersTable,
    Chapter,
    $$ChaptersTableFilterComposer,
    $$ChaptersTableOrderingComposer,
    $$ChaptersTableAnnotationComposer,
    $$ChaptersTableCreateCompanionBuilder,
    $$ChaptersTableUpdateCompanionBuilder,
    (Chapter, $$ChaptersTableReferences),
    Chapter,
    PrefetchHooks Function({bool subjectId, bool topicsRefs})>;
typedef $$TopicsTableCreateCompanionBuilder = TopicsCompanion Function({
  Value<int> id,
  required int chapterId,
  required String code,
  required String title,
  Value<String?> summary,
  Value<int> orderIndex,
});
typedef $$TopicsTableUpdateCompanionBuilder = TopicsCompanion Function({
  Value<int> id,
  Value<int> chapterId,
  Value<String> code,
  Value<String> title,
  Value<String?> summary,
  Value<int> orderIndex,
});

final class $$TopicsTableReferences
    extends BaseReferences<_$AppDatabase, $TopicsTable, Topic> {
  $$TopicsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ChaptersTable _chapterIdTable(_$AppDatabase db) => db.chapters
      .createAlias($_aliasNameGenerator(db.topics.chapterId, db.chapters.id));

  $$ChaptersTableProcessedTableManager get chapterId {
    final manager = $$ChaptersTableTableManager($_db, $_db.chapters)
        .filter((f) => f.id($_item.chapterId));
    final item = $_typedResult.readTableOrNull(_chapterIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
      _flashcardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.flashcards,
          aliasName: $_aliasNameGenerator(db.topics.id, db.flashcards.topicId));

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager($_db, $_db.flashcards)
        .filter((f) => f.topicId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$QuestionsTable, List<Question>>
      _questionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.questions,
          aliasName: $_aliasNameGenerator(db.topics.id, db.questions.topicId));

  $$QuestionsTableProcessedTableManager get questionsRefs {
    final manager = $$QuestionsTableTableManager($_db, $_db.questions)
        .filter((f) => f.topicId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_questionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$TopicsTableFilterComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$ChaptersTableFilterComposer get chapterId {
    final $$ChaptersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableFilterComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> flashcardsRefs(
      Expression<bool> Function($$FlashcardsTableFilterComposer f) f) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.topicId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableFilterComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> questionsRefs(
      Expression<bool> Function($$QuestionsTableFilterComposer f) f) {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.topicId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableFilterComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TopicsTableOrderingComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get summary => $composableBuilder(
      column: $table.summary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$ChaptersTableOrderingComposer get chapterId {
    final $$ChaptersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableOrderingComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$TopicsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TopicsTable> {
  $$TopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$ChaptersTableAnnotationComposer get chapterId {
    final $$ChaptersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.chapterId,
        referencedTable: $db.chapters,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ChaptersTableAnnotationComposer(
              $db: $db,
              $table: $db.chapters,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> flashcardsRefs<T extends Object>(
      Expression<T> Function($$FlashcardsTableAnnotationComposer a) f) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.topicId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableAnnotationComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> questionsRefs<T extends Object>(
      Expression<T> Function($$QuestionsTableAnnotationComposer a) f) {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.topicId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$TopicsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TopicsTable,
    Topic,
    $$TopicsTableFilterComposer,
    $$TopicsTableOrderingComposer,
    $$TopicsTableAnnotationComposer,
    $$TopicsTableCreateCompanionBuilder,
    $$TopicsTableUpdateCompanionBuilder,
    (Topic, $$TopicsTableReferences),
    Topic,
    PrefetchHooks Function(
        {bool chapterId, bool flashcardsRefs, bool questionsRefs})> {
  $$TopicsTableTableManager(_$AppDatabase db, $TopicsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> chapterId = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> summary = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              TopicsCompanion(
            id: id,
            chapterId: chapterId,
            code: code,
            title: title,
            summary: summary,
            orderIndex: orderIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int chapterId,
            required String code,
            required String title,
            Value<String?> summary = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              TopicsCompanion.insert(
            id: id,
            chapterId: chapterId,
            code: code,
            title: title,
            summary: summary,
            orderIndex: orderIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$TopicsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {chapterId = false,
              flashcardsRefs = false,
              questionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (flashcardsRefs) db.flashcards,
                if (questionsRefs) db.questions
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (chapterId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.chapterId,
                    referencedTable:
                        $$TopicsTableReferences._chapterIdTable(db),
                    referencedColumn:
                        $$TopicsTableReferences._chapterIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TopicsTableReferences._flashcardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TopicsTableReferences(db, table, p0)
                                .flashcardsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.topicId == item.id),
                        typedResults: items),
                  if (questionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$TopicsTableReferences._questionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$TopicsTableReferences(db, table, p0)
                                .questionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.topicId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$TopicsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TopicsTable,
    Topic,
    $$TopicsTableFilterComposer,
    $$TopicsTableOrderingComposer,
    $$TopicsTableAnnotationComposer,
    $$TopicsTableCreateCompanionBuilder,
    $$TopicsTableUpdateCompanionBuilder,
    (Topic, $$TopicsTableReferences),
    Topic,
    PrefetchHooks Function(
        {bool chapterId, bool flashcardsRefs, bool questionsRefs})>;
typedef $$SourcesTableCreateCompanionBuilder = SourcesCompanion Function({
  Value<int> id,
  required String pdfPath,
  Value<String?> category,
  Value<String?> title,
  Value<int?> pageCount,
});
typedef $$SourcesTableUpdateCompanionBuilder = SourcesCompanion Function({
  Value<int> id,
  Value<String> pdfPath,
  Value<String?> category,
  Value<String?> title,
  Value<int?> pageCount,
});

final class $$SourcesTableReferences
    extends BaseReferences<_$AppDatabase, $SourcesTable, Source> {
  $$SourcesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FlashcardsTable, List<Flashcard>>
      _flashcardsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.flashcards,
              aliasName:
                  $_aliasNameGenerator(db.sources.id, db.flashcards.sourceId));

  $$FlashcardsTableProcessedTableManager get flashcardsRefs {
    final manager = $$FlashcardsTableTableManager($_db, $_db.flashcards)
        .filter((f) => f.sourceId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_flashcardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$QuestionsTable, List<Question>>
      _questionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.questions,
              aliasName:
                  $_aliasNameGenerator(db.sources.id, db.questions.sourceId));

  $$QuestionsTableProcessedTableManager get questionsRefs {
    final manager = $$QuestionsTableTableManager($_db, $_db.questions)
        .filter((f) => f.sourceId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_questionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SourcesTableFilterComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  Expression<bool> flashcardsRefs(
      Expression<bool> Function($$FlashcardsTableFilterComposer f) f) {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableFilterComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> questionsRefs(
      Expression<bool> Function($$QuestionsTableFilterComposer f) f) {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableFilterComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get pdfPath => $composableBuilder(
      column: $table.pdfPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));
}

class $$SourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SourcesTable> {
  $$SourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get pdfPath =>
      $composableBuilder(column: $table.pdfPath, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  Expression<T> flashcardsRefs<T extends Object>(
      Expression<T> Function($$FlashcardsTableAnnotationComposer a) f) {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableAnnotationComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> questionsRefs<T extends Object>(
      Expression<T> Function($$QuestionsTableAnnotationComposer a) f) {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.sourceId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SourcesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SourcesTable,
    Source,
    $$SourcesTableFilterComposer,
    $$SourcesTableOrderingComposer,
    $$SourcesTableAnnotationComposer,
    $$SourcesTableCreateCompanionBuilder,
    $$SourcesTableUpdateCompanionBuilder,
    (Source, $$SourcesTableReferences),
    Source,
    PrefetchHooks Function({bool flashcardsRefs, bool questionsRefs})> {
  $$SourcesTableTableManager(_$AppDatabase db, $SourcesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> pdfPath = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
          }) =>
              SourcesCompanion(
            id: id,
            pdfPath: pdfPath,
            category: category,
            title: title,
            pageCount: pageCount,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String pdfPath,
            Value<String?> category = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<int?> pageCount = const Value.absent(),
          }) =>
              SourcesCompanion.insert(
            id: id,
            pdfPath: pdfPath,
            category: category,
            title: title,
            pageCount: pageCount,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SourcesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {flashcardsRefs = false, questionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (flashcardsRefs) db.flashcards,
                if (questionsRefs) db.questions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (flashcardsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SourcesTableReferences._flashcardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SourcesTableReferences(db, table, p0)
                                .flashcardsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sourceId == item.id),
                        typedResults: items),
                  if (questionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SourcesTableReferences._questionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SourcesTableReferences(db, table, p0)
                                .questionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.sourceId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SourcesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SourcesTable,
    Source,
    $$SourcesTableFilterComposer,
    $$SourcesTableOrderingComposer,
    $$SourcesTableAnnotationComposer,
    $$SourcesTableCreateCompanionBuilder,
    $$SourcesTableUpdateCompanionBuilder,
    (Source, $$SourcesTableReferences),
    Source,
    PrefetchHooks Function({bool flashcardsRefs, bool questionsRefs})>;
typedef $$FlashcardsTableCreateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  required int topicId,
  required String front,
  required String back,
  Value<String?> hint,
  Value<String> difficulty,
  Value<String> tagsJson,
  Value<int?> sourceId,
  Value<int?> sourcePage,
  Value<DateTime> createdAt,
});
typedef $$FlashcardsTableUpdateCompanionBuilder = FlashcardsCompanion Function({
  Value<int> id,
  Value<int> topicId,
  Value<String> front,
  Value<String> back,
  Value<String?> hint,
  Value<String> difficulty,
  Value<String> tagsJson,
  Value<int?> sourceId,
  Value<int?> sourcePage,
  Value<DateTime> createdAt,
});

final class $$FlashcardsTableReferences
    extends BaseReferences<_$AppDatabase, $FlashcardsTable, Flashcard> {
  $$FlashcardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TopicsTable _topicIdTable(_$AppDatabase db) => db.topics
      .createAlias($_aliasNameGenerator(db.flashcards.topicId, db.topics.id));

  $$TopicsTableProcessedTableManager get topicId {
    final manager = $$TopicsTableTableManager($_db, $_db.topics)
        .filter((f) => f.id($_item.topicId));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SourcesTable _sourceIdTable(_$AppDatabase db) => db.sources
      .createAlias($_aliasNameGenerator(db.flashcards.sourceId, db.sources.id));

  $$SourcesTableProcessedTableManager? get sourceId {
    if ($_item.sourceId == null) return null;
    final manager = $$SourcesTableTableManager($_db, $_db.sources)
        .filter((f) => f.id($_item.sourceId!));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$UserCardStateTable, List<UserCardStateData>>
      _userCardStateRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.userCardState,
              aliasName: $_aliasNameGenerator(
                  db.flashcards.id, db.userCardState.flashcardId));

  $$UserCardStateTableProcessedTableManager get userCardStateRefs {
    final manager = $$UserCardStateTableTableManager($_db, $_db.userCardState)
        .filter((f) => f.flashcardId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_userCardStateRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$FlashcardsTableFilterComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TopicsTableFilterComposer get topicId {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableFilterComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.sources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourcesTableFilterComposer(
              $db: $db,
              $table: $db.sources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> userCardStateRefs(
      Expression<bool> Function($$UserCardStateTableFilterComposer f) f) {
    final $$UserCardStateTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userCardState,
        getReferencedColumn: (t) => t.flashcardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserCardStateTableFilterComposer(
              $db: $db,
              $table: $db.userCardState,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FlashcardsTableOrderingComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get front => $composableBuilder(
      column: $table.front, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get back => $composableBuilder(
      column: $table.back, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hint => $composableBuilder(
      column: $table.hint, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TopicsTableOrderingComposer get topicId {
    final $$TopicsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableOrderingComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.sources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourcesTableOrderingComposer(
              $db: $db,
              $table: $db.sources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$FlashcardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FlashcardsTable> {
  $$FlashcardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get front =>
      $composableBuilder(column: $table.front, builder: (column) => column);

  GeneratedColumn<String> get back =>
      $composableBuilder(column: $table.back, builder: (column) => column);

  GeneratedColumn<String> get hint =>
      $composableBuilder(column: $table.hint, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TopicsTableAnnotationComposer get topicId {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableAnnotationComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.sources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourcesTableAnnotationComposer(
              $db: $db,
              $table: $db.sources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> userCardStateRefs<T extends Object>(
      Expression<T> Function($$UserCardStateTableAnnotationComposer a) f) {
    final $$UserCardStateTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userCardState,
        getReferencedColumn: (t) => t.flashcardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserCardStateTableAnnotationComposer(
              $db: $db,
              $table: $db.userCardState,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$FlashcardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    Flashcard,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (Flashcard, $$FlashcardsTableReferences),
    Flashcard,
    PrefetchHooks Function(
        {bool topicId, bool sourceId, bool userCardStateRefs})> {
  $$FlashcardsTableTableManager(_$AppDatabase db, $FlashcardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FlashcardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FlashcardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FlashcardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> topicId = const Value.absent(),
            Value<String> front = const Value.absent(),
            Value<String> back = const Value.absent(),
            Value<String?> hint = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<int?> sourceId = const Value.absent(),
            Value<int?> sourcePage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FlashcardsCompanion(
            id: id,
            topicId: topicId,
            front: front,
            back: back,
            hint: hint,
            difficulty: difficulty,
            tagsJson: tagsJson,
            sourceId: sourceId,
            sourcePage: sourcePage,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int topicId,
            required String front,
            required String back,
            Value<String?> hint = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<int?> sourceId = const Value.absent(),
            Value<int?> sourcePage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              FlashcardsCompanion.insert(
            id: id,
            topicId: topicId,
            front: front,
            back: back,
            hint: hint,
            difficulty: difficulty,
            tagsJson: tagsJson,
            sourceId: sourceId,
            sourcePage: sourcePage,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$FlashcardsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {topicId = false, sourceId = false, userCardStateRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userCardStateRefs) db.userCardState
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (topicId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.topicId,
                    referencedTable:
                        $$FlashcardsTableReferences._topicIdTable(db),
                    referencedColumn:
                        $$FlashcardsTableReferences._topicIdTable(db).id,
                  ) as T;
                }
                if (sourceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceId,
                    referencedTable:
                        $$FlashcardsTableReferences._sourceIdTable(db),
                    referencedColumn:
                        $$FlashcardsTableReferences._sourceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userCardStateRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$FlashcardsTableReferences
                            ._userCardStateRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$FlashcardsTableReferences(db, table, p0)
                                .userCardStateRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.flashcardId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$FlashcardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FlashcardsTable,
    Flashcard,
    $$FlashcardsTableFilterComposer,
    $$FlashcardsTableOrderingComposer,
    $$FlashcardsTableAnnotationComposer,
    $$FlashcardsTableCreateCompanionBuilder,
    $$FlashcardsTableUpdateCompanionBuilder,
    (Flashcard, $$FlashcardsTableReferences),
    Flashcard,
    PrefetchHooks Function(
        {bool topicId, bool sourceId, bool userCardStateRefs})>;
typedef $$QuestionsTableCreateCompanionBuilder = QuestionsCompanion Function({
  Value<int> id,
  required int topicId,
  Value<String> qtype,
  required String stem,
  Value<String?> explanation,
  Value<String> difficulty,
  Value<String> tagsJson,
  Value<int?> sourceId,
  Value<int?> sourcePage,
  Value<DateTime> createdAt,
});
typedef $$QuestionsTableUpdateCompanionBuilder = QuestionsCompanion Function({
  Value<int> id,
  Value<int> topicId,
  Value<String> qtype,
  Value<String> stem,
  Value<String?> explanation,
  Value<String> difficulty,
  Value<String> tagsJson,
  Value<int?> sourceId,
  Value<int?> sourcePage,
  Value<DateTime> createdAt,
});

final class $$QuestionsTableReferences
    extends BaseReferences<_$AppDatabase, $QuestionsTable, Question> {
  $$QuestionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TopicsTable _topicIdTable(_$AppDatabase db) => db.topics
      .createAlias($_aliasNameGenerator(db.questions.topicId, db.topics.id));

  $$TopicsTableProcessedTableManager get topicId {
    final manager = $$TopicsTableTableManager($_db, $_db.topics)
        .filter((f) => f.id($_item.topicId));
    final item = $_typedResult.readTableOrNull(_topicIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SourcesTable _sourceIdTable(_$AppDatabase db) => db.sources
      .createAlias($_aliasNameGenerator(db.questions.sourceId, db.sources.id));

  $$SourcesTableProcessedTableManager? get sourceId {
    if ($_item.sourceId == null) return null;
    final manager = $$SourcesTableTableManager($_db, $_db.sources)
        .filter((f) => f.id($_item.sourceId!));
    final item = $_typedResult.readTableOrNull(_sourceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$QuestionOptionsTable, List<QuestionOption>>
      _questionOptionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.questionOptions,
              aliasName: $_aliasNameGenerator(
                  db.questions.id, db.questionOptions.questionId));

  $$QuestionOptionsTableProcessedTableManager get questionOptionsRefs {
    final manager =
        $$QuestionOptionsTableTableManager($_db, $_db.questionOptions)
            .filter((f) => f.questionId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_questionOptionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$UserQuestionStateTable,
      List<UserQuestionStateData>> _userQuestionStateRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.userQuestionState,
          aliasName: $_aliasNameGenerator(
              db.questions.id, db.userQuestionState.questionId));

  $$UserQuestionStateTableProcessedTableManager get userQuestionStateRefs {
    final manager =
        $$UserQuestionStateTableTableManager($_db, $_db.userQuestionState)
            .filter((f) => f.questionId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_userQuestionStateRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$QuestionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qtype => $composableBuilder(
      column: $table.qtype, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stem => $composableBuilder(
      column: $table.stem, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$TopicsTableFilterComposer get topicId {
    final $$TopicsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableFilterComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SourcesTableFilterComposer get sourceId {
    final $$SourcesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.sources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourcesTableFilterComposer(
              $db: $db,
              $table: $db.sources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> questionOptionsRefs(
      Expression<bool> Function($$QuestionOptionsTableFilterComposer f) f) {
    final $$QuestionOptionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.questionOptions,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionOptionsTableFilterComposer(
              $db: $db,
              $table: $db.questionOptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> userQuestionStateRefs(
      Expression<bool> Function($$UserQuestionStateTableFilterComposer f) f) {
    final $$UserQuestionStateTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.userQuestionState,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$UserQuestionStateTableFilterComposer(
              $db: $db,
              $table: $db.userQuestionState,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qtype => $composableBuilder(
      column: $table.qtype, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stem => $composableBuilder(
      column: $table.stem, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tagsJson => $composableBuilder(
      column: $table.tagsJson, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$TopicsTableOrderingComposer get topicId {
    final $$TopicsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableOrderingComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SourcesTableOrderingComposer get sourceId {
    final $$SourcesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.sources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourcesTableOrderingComposer(
              $db: $db,
              $table: $db.sources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get qtype =>
      $composableBuilder(column: $table.qtype, builder: (column) => column);

  GeneratedColumn<String> get stem =>
      $composableBuilder(column: $table.stem, builder: (column) => column);

  GeneratedColumn<String> get explanation => $composableBuilder(
      column: $table.explanation, builder: (column) => column);

  GeneratedColumn<String> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<int> get sourcePage => $composableBuilder(
      column: $table.sourcePage, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$TopicsTableAnnotationComposer get topicId {
    final $$TopicsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.topicId,
        referencedTable: $db.topics,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$TopicsTableAnnotationComposer(
              $db: $db,
              $table: $db.topics,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SourcesTableAnnotationComposer get sourceId {
    final $$SourcesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.sourceId,
        referencedTable: $db.sources,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SourcesTableAnnotationComposer(
              $db: $db,
              $table: $db.sources,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> questionOptionsRefs<T extends Object>(
      Expression<T> Function($$QuestionOptionsTableAnnotationComposer a) f) {
    final $$QuestionOptionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.questionOptions,
        getReferencedColumn: (t) => t.questionId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionOptionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questionOptions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> userQuestionStateRefs<T extends Object>(
      Expression<T> Function($$UserQuestionStateTableAnnotationComposer a) f) {
    final $$UserQuestionStateTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.userQuestionState,
            getReferencedColumn: (t) => t.questionId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$UserQuestionStateTableAnnotationComposer(
                  $db: $db,
                  $table: $db.userQuestionState,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$QuestionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, $$QuestionsTableReferences),
    Question,
    PrefetchHooks Function(
        {bool topicId,
        bool sourceId,
        bool questionOptionsRefs,
        bool userQuestionStateRefs})> {
  $$QuestionsTableTableManager(_$AppDatabase db, $QuestionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> topicId = const Value.absent(),
            Value<String> qtype = const Value.absent(),
            Value<String> stem = const Value.absent(),
            Value<String?> explanation = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<int?> sourceId = const Value.absent(),
            Value<int?> sourcePage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              QuestionsCompanion(
            id: id,
            topicId: topicId,
            qtype: qtype,
            stem: stem,
            explanation: explanation,
            difficulty: difficulty,
            tagsJson: tagsJson,
            sourceId: sourceId,
            sourcePage: sourcePage,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int topicId,
            Value<String> qtype = const Value.absent(),
            required String stem,
            Value<String?> explanation = const Value.absent(),
            Value<String> difficulty = const Value.absent(),
            Value<String> tagsJson = const Value.absent(),
            Value<int?> sourceId = const Value.absent(),
            Value<int?> sourcePage = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              QuestionsCompanion.insert(
            id: id,
            topicId: topicId,
            qtype: qtype,
            stem: stem,
            explanation: explanation,
            difficulty: difficulty,
            tagsJson: tagsJson,
            sourceId: sourceId,
            sourcePage: sourcePage,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuestionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {topicId = false,
              sourceId = false,
              questionOptionsRefs = false,
              userQuestionStateRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (questionOptionsRefs) db.questionOptions,
                if (userQuestionStateRefs) db.userQuestionState
              ],
              addJoins: <
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
                      dynamic>>(state) {
                if (topicId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.topicId,
                    referencedTable:
                        $$QuestionsTableReferences._topicIdTable(db),
                    referencedColumn:
                        $$QuestionsTableReferences._topicIdTable(db).id,
                  ) as T;
                }
                if (sourceId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.sourceId,
                    referencedTable:
                        $$QuestionsTableReferences._sourceIdTable(db),
                    referencedColumn:
                        $$QuestionsTableReferences._sourceIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (questionOptionsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$QuestionsTableReferences
                            ._questionOptionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$QuestionsTableReferences(db, table, p0)
                                .questionOptionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.questionId == item.id),
                        typedResults: items),
                  if (userQuestionStateRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$QuestionsTableReferences
                            ._userQuestionStateRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$QuestionsTableReferences(db, table, p0)
                                .userQuestionStateRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.questionId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$QuestionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionsTable,
    Question,
    $$QuestionsTableFilterComposer,
    $$QuestionsTableOrderingComposer,
    $$QuestionsTableAnnotationComposer,
    $$QuestionsTableCreateCompanionBuilder,
    $$QuestionsTableUpdateCompanionBuilder,
    (Question, $$QuestionsTableReferences),
    Question,
    PrefetchHooks Function(
        {bool topicId,
        bool sourceId,
        bool questionOptionsRefs,
        bool userQuestionStateRefs})>;
typedef $$QuestionOptionsTableCreateCompanionBuilder = QuestionOptionsCompanion
    Function({
  Value<int> id,
  required int questionId,
  required String label,
  required String content,
  Value<bool> isCorrect,
  Value<int> orderIndex,
});
typedef $$QuestionOptionsTableUpdateCompanionBuilder = QuestionOptionsCompanion
    Function({
  Value<int> id,
  Value<int> questionId,
  Value<String> label,
  Value<String> content,
  Value<bool> isCorrect,
  Value<int> orderIndex,
});

final class $$QuestionOptionsTableReferences extends BaseReferences<
    _$AppDatabase, $QuestionOptionsTable, QuestionOption> {
  $$QuestionOptionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias(
          $_aliasNameGenerator(db.questionOptions.questionId, db.questions.id));

  $$QuestionsTableProcessedTableManager get questionId {
    final manager = $$QuestionsTableTableManager($_db, $_db.questions)
        .filter((f) => f.id($_item.questionId));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$QuestionOptionsTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionOptionsTable> {
  $$QuestionOptionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnFilters(column));

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableFilterComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuestionOptionsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionOptionsTable> {
  $$QuestionOptionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
      column: $table.isCorrect, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => ColumnOrderings(column));

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableOrderingComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuestionOptionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionOptionsTable> {
  $$QuestionOptionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
      column: $table.orderIndex, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$QuestionOptionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $QuestionOptionsTable,
    QuestionOption,
    $$QuestionOptionsTableFilterComposer,
    $$QuestionOptionsTableOrderingComposer,
    $$QuestionOptionsTableAnnotationComposer,
    $$QuestionOptionsTableCreateCompanionBuilder,
    $$QuestionOptionsTableUpdateCompanionBuilder,
    (QuestionOption, $$QuestionOptionsTableReferences),
    QuestionOption,
    PrefetchHooks Function({bool questionId})> {
  $$QuestionOptionsTableTableManager(
      _$AppDatabase db, $QuestionOptionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionOptionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionOptionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionOptionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> questionId = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<bool> isCorrect = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              QuestionOptionsCompanion(
            id: id,
            questionId: questionId,
            label: label,
            content: content,
            isCorrect: isCorrect,
            orderIndex: orderIndex,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int questionId,
            required String label,
            required String content,
            Value<bool> isCorrect = const Value.absent(),
            Value<int> orderIndex = const Value.absent(),
          }) =>
              QuestionOptionsCompanion.insert(
            id: id,
            questionId: questionId,
            label: label,
            content: content,
            isCorrect: isCorrect,
            orderIndex: orderIndex,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$QuestionOptionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (questionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.questionId,
                    referencedTable:
                        $$QuestionOptionsTableReferences._questionIdTable(db),
                    referencedColumn: $$QuestionOptionsTableReferences
                        ._questionIdTable(db)
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
        ));
}

typedef $$QuestionOptionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $QuestionOptionsTable,
    QuestionOption,
    $$QuestionOptionsTableFilterComposer,
    $$QuestionOptionsTableOrderingComposer,
    $$QuestionOptionsTableAnnotationComposer,
    $$QuestionOptionsTableCreateCompanionBuilder,
    $$QuestionOptionsTableUpdateCompanionBuilder,
    (QuestionOption, $$QuestionOptionsTableReferences),
    QuestionOption,
    PrefetchHooks Function({bool questionId})>;
typedef $$UserCardStateTableCreateCompanionBuilder = UserCardStateCompanion
    Function({
  Value<int> flashcardId,
  Value<double> ease,
  Value<int> intervalDays,
  Value<DateTime?> nextReview,
  Value<String?> lastResult,
  Value<int> reviewCount,
  Value<DateTime> updatedAt,
});
typedef $$UserCardStateTableUpdateCompanionBuilder = UserCardStateCompanion
    Function({
  Value<int> flashcardId,
  Value<double> ease,
  Value<int> intervalDays,
  Value<DateTime?> nextReview,
  Value<String?> lastResult,
  Value<int> reviewCount,
  Value<DateTime> updatedAt,
});

final class $$UserCardStateTableReferences extends BaseReferences<_$AppDatabase,
    $UserCardStateTable, UserCardStateData> {
  $$UserCardStateTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $FlashcardsTable _flashcardIdTable(_$AppDatabase db) =>
      db.flashcards.createAlias(
          $_aliasNameGenerator(db.userCardState.flashcardId, db.flashcards.id));

  $$FlashcardsTableProcessedTableManager get flashcardId {
    final manager = $$FlashcardsTableTableManager($_db, $_db.flashcards)
        .filter((f) => f.id($_item.flashcardId));
    final item = $_typedResult.readTableOrNull(_flashcardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserCardStateTableFilterComposer
    extends Composer<_$AppDatabase, $UserCardStateTable> {
  $$UserCardStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get ease => $composableBuilder(
      column: $table.ease, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastResult => $composableBuilder(
      column: $table.lastResult, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$FlashcardsTableFilterComposer get flashcardId {
    final $$FlashcardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.flashcardId,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableFilterComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserCardStateTableOrderingComposer
    extends Composer<_$AppDatabase, $UserCardStateTable> {
  $$UserCardStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get ease => $composableBuilder(
      column: $table.ease, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastResult => $composableBuilder(
      column: $table.lastResult, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$FlashcardsTableOrderingComposer get flashcardId {
    final $$FlashcardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.flashcardId,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableOrderingComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserCardStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserCardStateTable> {
  $$UserCardStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get ease =>
      $composableBuilder(column: $table.ease, builder: (column) => column);

  GeneratedColumn<int> get intervalDays => $composableBuilder(
      column: $table.intervalDays, builder: (column) => column);

  GeneratedColumn<DateTime> get nextReview => $composableBuilder(
      column: $table.nextReview, builder: (column) => column);

  GeneratedColumn<String> get lastResult => $composableBuilder(
      column: $table.lastResult, builder: (column) => column);

  GeneratedColumn<int> get reviewCount => $composableBuilder(
      column: $table.reviewCount, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$FlashcardsTableAnnotationComposer get flashcardId {
    final $$FlashcardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.flashcardId,
        referencedTable: $db.flashcards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$FlashcardsTableAnnotationComposer(
              $db: $db,
              $table: $db.flashcards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserCardStateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserCardStateTable,
    UserCardStateData,
    $$UserCardStateTableFilterComposer,
    $$UserCardStateTableOrderingComposer,
    $$UserCardStateTableAnnotationComposer,
    $$UserCardStateTableCreateCompanionBuilder,
    $$UserCardStateTableUpdateCompanionBuilder,
    (UserCardStateData, $$UserCardStateTableReferences),
    UserCardStateData,
    PrefetchHooks Function({bool flashcardId})> {
  $$UserCardStateTableTableManager(_$AppDatabase db, $UserCardStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserCardStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserCardStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserCardStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> flashcardId = const Value.absent(),
            Value<double> ease = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<DateTime?> nextReview = const Value.absent(),
            Value<String?> lastResult = const Value.absent(),
            Value<int> reviewCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserCardStateCompanion(
            flashcardId: flashcardId,
            ease: ease,
            intervalDays: intervalDays,
            nextReview: nextReview,
            lastResult: lastResult,
            reviewCount: reviewCount,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> flashcardId = const Value.absent(),
            Value<double> ease = const Value.absent(),
            Value<int> intervalDays = const Value.absent(),
            Value<DateTime?> nextReview = const Value.absent(),
            Value<String?> lastResult = const Value.absent(),
            Value<int> reviewCount = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserCardStateCompanion.insert(
            flashcardId: flashcardId,
            ease: ease,
            intervalDays: intervalDays,
            nextReview: nextReview,
            lastResult: lastResult,
            reviewCount: reviewCount,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserCardStateTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({flashcardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (flashcardId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.flashcardId,
                    referencedTable:
                        $$UserCardStateTableReferences._flashcardIdTable(db),
                    referencedColumn:
                        $$UserCardStateTableReferences._flashcardIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$UserCardStateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserCardStateTable,
    UserCardStateData,
    $$UserCardStateTableFilterComposer,
    $$UserCardStateTableOrderingComposer,
    $$UserCardStateTableAnnotationComposer,
    $$UserCardStateTableCreateCompanionBuilder,
    $$UserCardStateTableUpdateCompanionBuilder,
    (UserCardStateData, $$UserCardStateTableReferences),
    UserCardStateData,
    PrefetchHooks Function({bool flashcardId})>;
typedef $$UserQuestionStateTableCreateCompanionBuilder
    = UserQuestionStateCompanion Function({
  Value<int> questionId,
  Value<int> attempts,
  Value<int> correct,
  Value<DateTime?> lastAttempt,
  Value<String?> lastChoice,
  Value<DateTime> updatedAt,
});
typedef $$UserQuestionStateTableUpdateCompanionBuilder
    = UserQuestionStateCompanion Function({
  Value<int> questionId,
  Value<int> attempts,
  Value<int> correct,
  Value<DateTime?> lastAttempt,
  Value<String?> lastChoice,
  Value<DateTime> updatedAt,
});

final class $$UserQuestionStateTableReferences extends BaseReferences<
    _$AppDatabase, $UserQuestionStateTable, UserQuestionStateData> {
  $$UserQuestionStateTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $QuestionsTable _questionIdTable(_$AppDatabase db) =>
      db.questions.createAlias($_aliasNameGenerator(
          db.userQuestionState.questionId, db.questions.id));

  $$QuestionsTableProcessedTableManager get questionId {
    final manager = $$QuestionsTableTableManager($_db, $_db.questions)
        .filter((f) => f.id($_item.questionId));
    final item = $_typedResult.readTableOrNull(_questionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$UserQuestionStateTableFilterComposer
    extends Composer<_$AppDatabase, $UserQuestionStateTable> {
  $$UserQuestionStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastAttempt => $composableBuilder(
      column: $table.lastAttempt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastChoice => $composableBuilder(
      column: $table.lastChoice, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  $$QuestionsTableFilterComposer get questionId {
    final $$QuestionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableFilterComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserQuestionStateTableOrderingComposer
    extends Composer<_$AppDatabase, $UserQuestionStateTable> {
  $$UserQuestionStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get attempts => $composableBuilder(
      column: $table.attempts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get correct => $composableBuilder(
      column: $table.correct, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastAttempt => $composableBuilder(
      column: $table.lastAttempt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastChoice => $composableBuilder(
      column: $table.lastChoice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  $$QuestionsTableOrderingComposer get questionId {
    final $$QuestionsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableOrderingComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserQuestionStateTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserQuestionStateTable> {
  $$UserQuestionStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<int> get correct =>
      $composableBuilder(column: $table.correct, builder: (column) => column);

  GeneratedColumn<DateTime> get lastAttempt => $composableBuilder(
      column: $table.lastAttempt, builder: (column) => column);

  GeneratedColumn<String> get lastChoice => $composableBuilder(
      column: $table.lastChoice, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$QuestionsTableAnnotationComposer get questionId {
    final $$QuestionsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.questionId,
        referencedTable: $db.questions,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$QuestionsTableAnnotationComposer(
              $db: $db,
              $table: $db.questions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$UserQuestionStateTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserQuestionStateTable,
    UserQuestionStateData,
    $$UserQuestionStateTableFilterComposer,
    $$UserQuestionStateTableOrderingComposer,
    $$UserQuestionStateTableAnnotationComposer,
    $$UserQuestionStateTableCreateCompanionBuilder,
    $$UserQuestionStateTableUpdateCompanionBuilder,
    (UserQuestionStateData, $$UserQuestionStateTableReferences),
    UserQuestionStateData,
    PrefetchHooks Function({bool questionId})> {
  $$UserQuestionStateTableTableManager(
      _$AppDatabase db, $UserQuestionStateTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserQuestionStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserQuestionStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserQuestionStateTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> questionId = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> correct = const Value.absent(),
            Value<DateTime?> lastAttempt = const Value.absent(),
            Value<String?> lastChoice = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserQuestionStateCompanion(
            questionId: questionId,
            attempts: attempts,
            correct: correct,
            lastAttempt: lastAttempt,
            lastChoice: lastChoice,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> questionId = const Value.absent(),
            Value<int> attempts = const Value.absent(),
            Value<int> correct = const Value.absent(),
            Value<DateTime?> lastAttempt = const Value.absent(),
            Value<String?> lastChoice = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserQuestionStateCompanion.insert(
            questionId: questionId,
            attempts: attempts,
            correct: correct,
            lastAttempt: lastAttempt,
            lastChoice: lastChoice,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$UserQuestionStateTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({questionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (questionId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.questionId,
                    referencedTable:
                        $$UserQuestionStateTableReferences._questionIdTable(db),
                    referencedColumn: $$UserQuestionStateTableReferences
                        ._questionIdTable(db)
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
        ));
}

typedef $$UserQuestionStateTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserQuestionStateTable,
    UserQuestionStateData,
    $$UserQuestionStateTableFilterComposer,
    $$UserQuestionStateTableOrderingComposer,
    $$UserQuestionStateTableAnnotationComposer,
    $$UserQuestionStateTableCreateCompanionBuilder,
    $$UserQuestionStateTableUpdateCompanionBuilder,
    (UserQuestionStateData, $$UserQuestionStateTableReferences),
    UserQuestionStateData,
    PrefetchHooks Function({bool questionId})>;
typedef $$UserBookmarksTableCreateCompanionBuilder = UserBookmarksCompanion
    Function({
  required String itemKind,
  required int itemId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$UserBookmarksTableUpdateCompanionBuilder = UserBookmarksCompanion
    Function({
  Value<String> itemKind,
  Value<int> itemId,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UserBookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $UserBookmarksTable> {
  $$UserBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemKind => $composableBuilder(
      column: $table.itemKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UserBookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $UserBookmarksTable> {
  $$UserBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemKind => $composableBuilder(
      column: $table.itemKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UserBookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserBookmarksTable> {
  $$UserBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemKind =>
      $composableBuilder(column: $table.itemKind, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserBookmarksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserBookmarksTable,
    UserBookmark,
    $$UserBookmarksTableFilterComposer,
    $$UserBookmarksTableOrderingComposer,
    $$UserBookmarksTableAnnotationComposer,
    $$UserBookmarksTableCreateCompanionBuilder,
    $$UserBookmarksTableUpdateCompanionBuilder,
    (
      UserBookmark,
      BaseReferences<_$AppDatabase, $UserBookmarksTable, UserBookmark>
    ),
    UserBookmark,
    PrefetchHooks Function()> {
  $$UserBookmarksTableTableManager(_$AppDatabase db, $UserBookmarksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> itemKind = const Value.absent(),
            Value<int> itemId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserBookmarksCompanion(
            itemKind: itemKind,
            itemId: itemId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String itemKind,
            required int itemId,
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserBookmarksCompanion.insert(
            itemKind: itemKind,
            itemId: itemId,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserBookmarksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserBookmarksTable,
    UserBookmark,
    $$UserBookmarksTableFilterComposer,
    $$UserBookmarksTableOrderingComposer,
    $$UserBookmarksTableAnnotationComposer,
    $$UserBookmarksTableCreateCompanionBuilder,
    $$UserBookmarksTableUpdateCompanionBuilder,
    (
      UserBookmark,
      BaseReferences<_$AppDatabase, $UserBookmarksTable, UserBookmark>
    ),
    UserBookmark,
    PrefetchHooks Function()>;
typedef $$UserNotesTableCreateCompanionBuilder = UserNotesCompanion Function({
  Value<int> id,
  required String itemKind,
  required int itemId,
  required String body,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$UserNotesTableUpdateCompanionBuilder = UserNotesCompanion Function({
  Value<int> id,
  Value<String> itemKind,
  Value<int> itemId,
  Value<String> body,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$UserNotesTableFilterComposer
    extends Composer<_$AppDatabase, $UserNotesTable> {
  $$UserNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get itemKind => $composableBuilder(
      column: $table.itemKind, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserNotesTable> {
  $$UserNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get itemKind => $composableBuilder(
      column: $table.itemKind, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get itemId => $composableBuilder(
      column: $table.itemId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserNotesTable> {
  $$UserNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get itemKind =>
      $composableBuilder(column: $table.itemKind, builder: (column) => column);

  GeneratedColumn<int> get itemId =>
      $composableBuilder(column: $table.itemId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserNotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserNotesTable,
    UserNote,
    $$UserNotesTableFilterComposer,
    $$UserNotesTableOrderingComposer,
    $$UserNotesTableAnnotationComposer,
    $$UserNotesTableCreateCompanionBuilder,
    $$UserNotesTableUpdateCompanionBuilder,
    (UserNote, BaseReferences<_$AppDatabase, $UserNotesTable, UserNote>),
    UserNote,
    PrefetchHooks Function()> {
  $$UserNotesTableTableManager(_$AppDatabase db, $UserNotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> itemKind = const Value.absent(),
            Value<int> itemId = const Value.absent(),
            Value<String> body = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserNotesCompanion(
            id: id,
            itemKind: itemKind,
            itemId: itemId,
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String itemKind,
            required int itemId,
            required String body,
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              UserNotesCompanion.insert(
            id: id,
            itemKind: itemKind,
            itemId: itemId,
            body: body,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserNotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserNotesTable,
    UserNote,
    $$UserNotesTableFilterComposer,
    $$UserNotesTableOrderingComposer,
    $$UserNotesTableAnnotationComposer,
    $$UserNotesTableCreateCompanionBuilder,
    $$UserNotesTableUpdateCompanionBuilder,
    (UserNote, BaseReferences<_$AppDatabase, $UserNotesTable, UserNote>),
    UserNote,
    PrefetchHooks Function()>;
typedef $$UserSessionsTableCreateCompanionBuilder = UserSessionsCompanion
    Function({
  Value<int> id,
  required DateTime startedAt,
  Value<DateTime?> endedAt,
  Value<int> cardsReviewed,
  Value<int> questionsAnswered,
  Value<String> mode,
});
typedef $$UserSessionsTableUpdateCompanionBuilder = UserSessionsCompanion
    Function({
  Value<int> id,
  Value<DateTime> startedAt,
  Value<DateTime?> endedAt,
  Value<int> cardsReviewed,
  Value<int> questionsAnswered,
  Value<String> mode,
});

class $$UserSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $UserSessionsTable> {
  $$UserSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardsReviewed => $composableBuilder(
      column: $table.cardsReviewed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionsAnswered => $composableBuilder(
      column: $table.questionsAnswered,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnFilters(column));
}

class $$UserSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserSessionsTable> {
  $$UserSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardsReviewed => $composableBuilder(
      column: $table.cardsReviewed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionsAnswered => $composableBuilder(
      column: $table.questionsAnswered,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode, builder: (column) => ColumnOrderings(column));
}

class $$UserSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserSessionsTable> {
  $$UserSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get cardsReviewed => $composableBuilder(
      column: $table.cardsReviewed, builder: (column) => column);

  GeneratedColumn<int> get questionsAnswered => $composableBuilder(
      column: $table.questionsAnswered, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);
}

class $$UserSessionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserSessionsTable,
    UserSession,
    $$UserSessionsTableFilterComposer,
    $$UserSessionsTableOrderingComposer,
    $$UserSessionsTableAnnotationComposer,
    $$UserSessionsTableCreateCompanionBuilder,
    $$UserSessionsTableUpdateCompanionBuilder,
    (
      UserSession,
      BaseReferences<_$AppDatabase, $UserSessionsTable, UserSession>
    ),
    UserSession,
    PrefetchHooks Function()> {
  $$UserSessionsTableTableManager(_$AppDatabase db, $UserSessionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> cardsReviewed = const Value.absent(),
            Value<int> questionsAnswered = const Value.absent(),
            Value<String> mode = const Value.absent(),
          }) =>
              UserSessionsCompanion(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            cardsReviewed: cardsReviewed,
            questionsAnswered: questionsAnswered,
            mode: mode,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required DateTime startedAt,
            Value<DateTime?> endedAt = const Value.absent(),
            Value<int> cardsReviewed = const Value.absent(),
            Value<int> questionsAnswered = const Value.absent(),
            Value<String> mode = const Value.absent(),
          }) =>
              UserSessionsCompanion.insert(
            id: id,
            startedAt: startedAt,
            endedAt: endedAt,
            cardsReviewed: cardsReviewed,
            questionsAnswered: questionsAnswered,
            mode: mode,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserSessionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserSessionsTable,
    UserSession,
    $$UserSessionsTableFilterComposer,
    $$UserSessionsTableOrderingComposer,
    $$UserSessionsTableAnnotationComposer,
    $$UserSessionsTableCreateCompanionBuilder,
    $$UserSessionsTableUpdateCompanionBuilder,
    (
      UserSession,
      BaseReferences<_$AppDatabase, $UserSessionsTable, UserSession>
    ),
    UserSession,
    PrefetchHooks Function()>;
typedef $$UserStreakTableCreateCompanionBuilder = UserStreakCompanion Function({
  required DateTime day,
  Value<int> cardsReviewed,
  Value<int> questionsAnswered,
  Value<int> rowid,
});
typedef $$UserStreakTableUpdateCompanionBuilder = UserStreakCompanion Function({
  Value<DateTime> day,
  Value<int> cardsReviewed,
  Value<int> questionsAnswered,
  Value<int> rowid,
});

class $$UserStreakTableFilterComposer
    extends Composer<_$AppDatabase, $UserStreakTable> {
  $$UserStreakTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cardsReviewed => $composableBuilder(
      column: $table.cardsReviewed, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get questionsAnswered => $composableBuilder(
      column: $table.questionsAnswered,
      builder: (column) => ColumnFilters(column));
}

class $$UserStreakTableOrderingComposer
    extends Composer<_$AppDatabase, $UserStreakTable> {
  $$UserStreakTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get day => $composableBuilder(
      column: $table.day, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cardsReviewed => $composableBuilder(
      column: $table.cardsReviewed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get questionsAnswered => $composableBuilder(
      column: $table.questionsAnswered,
      builder: (column) => ColumnOrderings(column));
}

class $$UserStreakTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserStreakTable> {
  $$UserStreakTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get cardsReviewed => $composableBuilder(
      column: $table.cardsReviewed, builder: (column) => column);

  GeneratedColumn<int> get questionsAnswered => $composableBuilder(
      column: $table.questionsAnswered, builder: (column) => column);
}

class $$UserStreakTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserStreakTable,
    UserStreakData,
    $$UserStreakTableFilterComposer,
    $$UserStreakTableOrderingComposer,
    $$UserStreakTableAnnotationComposer,
    $$UserStreakTableCreateCompanionBuilder,
    $$UserStreakTableUpdateCompanionBuilder,
    (
      UserStreakData,
      BaseReferences<_$AppDatabase, $UserStreakTable, UserStreakData>
    ),
    UserStreakData,
    PrefetchHooks Function()> {
  $$UserStreakTableTableManager(_$AppDatabase db, $UserStreakTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserStreakTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserStreakTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserStreakTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> day = const Value.absent(),
            Value<int> cardsReviewed = const Value.absent(),
            Value<int> questionsAnswered = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStreakCompanion(
            day: day,
            cardsReviewed: cardsReviewed,
            questionsAnswered: questionsAnswered,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required DateTime day,
            Value<int> cardsReviewed = const Value.absent(),
            Value<int> questionsAnswered = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserStreakCompanion.insert(
            day: day,
            cardsReviewed: cardsReviewed,
            questionsAnswered: questionsAnswered,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserStreakTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserStreakTable,
    UserStreakData,
    $$UserStreakTableFilterComposer,
    $$UserStreakTableOrderingComposer,
    $$UserStreakTableAnnotationComposer,
    $$UserStreakTableCreateCompanionBuilder,
    $$UserStreakTableUpdateCompanionBuilder,
    (
      UserStreakData,
      BaseReferences<_$AppDatabase, $UserStreakTable, UserStreakData>
    ),
    UserStreakData,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$TopicsTableTableManager get topics =>
      $$TopicsTableTableManager(_db, _db.topics);
  $$SourcesTableTableManager get sources =>
      $$SourcesTableTableManager(_db, _db.sources);
  $$FlashcardsTableTableManager get flashcards =>
      $$FlashcardsTableTableManager(_db, _db.flashcards);
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$QuestionOptionsTableTableManager get questionOptions =>
      $$QuestionOptionsTableTableManager(_db, _db.questionOptions);
  $$UserCardStateTableTableManager get userCardState =>
      $$UserCardStateTableTableManager(_db, _db.userCardState);
  $$UserQuestionStateTableTableManager get userQuestionState =>
      $$UserQuestionStateTableTableManager(_db, _db.userQuestionState);
  $$UserBookmarksTableTableManager get userBookmarks =>
      $$UserBookmarksTableTableManager(_db, _db.userBookmarks);
  $$UserNotesTableTableManager get userNotes =>
      $$UserNotesTableTableManager(_db, _db.userNotes);
  $$UserSessionsTableTableManager get userSessions =>
      $$UserSessionsTableTableManager(_db, _db.userSessions);
  $$UserStreakTableTableManager get userStreak =>
      $$UserStreakTableTableManager(_db, _db.userStreak);
}

// Drift schema for SOCDaily.
//
// Mirrors `db/schema.sql` (the Python pipeline's SQLite schema) plus client-
// only user-state tables. The pipeline JSON seeds populate `subjects`,
// `chapters`, `topics`, `flashcards`, `questions`, `questionOptions`,
// `sources`; everything else is created and mutated by the app itself.

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

// ---- Content tables (mirror Python schema) -------------------------------

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

class Chapters extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get subjectId => integer().references(Subjects, #id)();
  TextColumn get code => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {subjectId, code},
      ];
}

class Topics extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get chapterId => integer().references(Chapters, #id)();
  TextColumn get code => text()();
  TextColumn get title => text()();
  TextColumn get summary => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
        {chapterId, code},
      ];
}

class Sources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get pdfPath => text().unique()();
  TextColumn get category => text().nullable()();
  TextColumn get title => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
}

class Flashcards extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get topicId => integer().references(Topics, #id)();
  TextColumn get front => text()();
  TextColumn get back => text()();
  TextColumn get hint => text().nullable()();
  TextColumn get difficulty =>
      text().withDefault(const Constant('medium'))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  IntColumn get sourceId => integer().nullable().references(Sources, #id)();
  IntColumn get sourcePage => integer().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class Questions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get topicId => integer().references(Topics, #id)();
  TextColumn get qtype => text().withDefault(const Constant('single'))();
  TextColumn get stem => text()();
  TextColumn get explanation => text().nullable()();
  TextColumn get difficulty =>
      text().withDefault(const Constant('medium'))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  IntColumn get sourceId => integer().nullable().references(Sources, #id)();
  IntColumn get sourcePage => integer().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class QuestionOptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get questionId => integer().references(Questions, #id)();
  TextColumn get label => text()();
  TextColumn get content => text()();
  BoolColumn get isCorrect => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();
}

// ---- User-state tables (app-only) ----------------------------------------

class UserCardState extends Table {
  IntColumn get flashcardId => integer().references(Flashcards, #id)();
  RealColumn get ease => real().withDefault(const Constant(2.5))();
  IntColumn get intervalDays => integer().withDefault(const Constant(1))();
  DateTimeColumn get nextReview => dateTime().nullable()();
  TextColumn get lastResult => text().nullable()();
  IntColumn get reviewCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {flashcardId};
}

class UserQuestionState extends Table {
  IntColumn get questionId => integer().references(Questions, #id)();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  IntColumn get correct => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttempt => dateTime().nullable()();
  TextColumn get lastChoice => text().nullable()();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {questionId};
}

class UserBookmarks extends Table {
  TextColumn get itemKind => text()();
  IntColumn get itemId => integer()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {itemKind, itemId};
}

class UserNotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get itemKind => text()();
  IntColumn get itemId => integer()();
  TextColumn get body => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
}

class UserSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get cardsReviewed => integer().withDefault(const Constant(0))();
  IntColumn get questionsAnswered =>
      integer().withDefault(const Constant(0))();
  TextColumn get mode => text().withDefault(const Constant('study'))();
}

class UserStreak extends Table {
  DateTimeColumn get day => dateTime()();
  IntColumn get cardsReviewed => integer().withDefault(const Constant(0))();
  IntColumn get questionsAnswered =>
      integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {day};
}

// --------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Subjects,
    Chapters,
    Topics,
    Sources,
    Flashcards,
    Questions,
    QuestionOptions,
    UserCardState,
    UserQuestionState,
    UserBookmarks,
    UserNotes,
    UserSessions,
    UserStreak,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Construct against an arbitrary [QueryExecutor] — used by tests so they
  /// can pump everything through an in-memory `NativeDatabase.memory()`.
  AppDatabase.forExecutor(super.executor);

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'socdaily.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // WAL mode: improves concurrent read/write performance.
        db.execute('PRAGMA journal_mode=WAL');
        // Synchronous NORMAL: safe with WAL, faster than FULL.
        db.execute('PRAGMA synchronous=NORMAL');
        // Increase cache size to 10 MB for better read performance.
        db.execute('PRAGMA cache_size=-10000');
        // Enable foreign keys.
        db.execute('PRAGMA foreign_keys=ON');
      },
    );
  });
}

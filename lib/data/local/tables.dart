import 'package:drift/drift.dart';

/// Cache locale du trombinoscope (§3.5/Lot 4) : permet à l'appel et au
/// signalement de lister les élèves sans réseau. Remplacée en bloc à chaque
/// lecture réussie en ligne — aucune écriture de Sandra ne passe par ici.
@DataClassName('LocalStudentRow')
class LocalStudents extends Table {
  TextColumn get id => text()();
  TextColumn get lastName => text().named('last_name')();
  TextColumn get firstName => text().named('first_name')();
  TextColumn get displayName => text().named('display_name')();
  TextColumn get pseudoCode => text().named('pseudo_code')();
  TextColumn get groupLabel => text().named('group_label').nullable()();
  TextColumn get firstLanguage => text().named('first_language').nullable()();
  IntColumn get flscoLevel => integer().named('flsco_level').nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isActive => boolean().named('is_active').withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Appel. Clé = ce que la contrainte `unique` de `attendance_records` impose
/// déjà côté serveur — `dirty` marque une ligne écrite hors ligne ou dont la
/// synchronisation a échoué, à repousser par `SyncService`.
@DataClassName('LocalAttendanceRow')
class LocalAttendance extends Table {
  TextColumn get studentId => text().named('student_id')();
  TextColumn get date => text()(); // 'yyyy-MM-dd', jamais de composante horaire
  TextColumn get halfDay => text().named('half_day')();
  TextColumn get status => text()();
  TextColumn get reason => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {studentId, date, halfDay};
}

/// Signalements. `id` est généré côté client (uuid) dès la saisie, pour que
/// la ligne créée hors ligne et la ligne poussée en base soient la même
/// (upsert idempotent, rejouable sans doublon si la synchronisation réessaie).
/// `studentIdsJson` évite une table de jointure locale séparée : le nombre de
/// signalements reste faible (dizaines/centaines), un filtrage en mémoire au
/// moment de la lecture suffit.
@DataClassName('LocalObservationRow')
class LocalObservations extends Table {
  TextColumn get id => text()();
  TextColumn get classId => text().named('class_id')();
  TextColumn get date => text()();
  DateTimeColumn get occurredAt => dateTime().named('occurred_at')();
  TextColumn get type => text()();
  IntColumn get severity => integer()();
  TextColumn get body => text().nullable()();
  TextColumn get studentIdsJson => text().named('student_ids_json')();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column> get primaryKey => {id};
}

/// Bilan du soir, indexé par `dayId` (jamais par l'id serveur du bilan, que
/// le client ne connaît pas forcément tant qu'il n'a pas pu synchroniser —
/// voir le commentaire dans `SyncService` sur pourquoi l'id n'est jamais
/// envoyé dans l'upsert `daily_reviews`).
@DataClassName('LocalDailyReviewRow')
class LocalDailyReviews extends Table {
  TextColumn get dayId => text().named('day_id')();
  TextColumn get generalNotes => text().named('general_notes').nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column> get primaryKey => {dayId};
}

@DataClassName('LocalDailyReviewEntryRow')
class LocalDailyReviewEntries extends Table {
  TextColumn get dayId => text().named('day_id')();
  TextColumn get journalEntryId => text().named('journal_entry_id')();
  TextColumn get status => text()();
  TextColumn get notes => text().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {dayId, journalEntryId};
}

/// Petites valeurs isolées à garder hors ligne (ex. l'id de la classe de
/// Sandra, sinon reperdu au redémarrage si l'app s'ouvre hors réseau).
@DataClassName('LocalMetaRow')
class LocalMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

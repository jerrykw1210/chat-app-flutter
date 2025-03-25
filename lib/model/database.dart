import 'package:drift/drift.dart';
import 'dart:io';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'message_status_enum.dart';

part 'database.g.dart';

@DataClassName('Conversation')
class Conversations extends Table {
  TextColumn get id =>
      text().withLength(min: 1, max: 255)(); // UUIDs or other string IDs
  TextColumn get title => text().withLength(min: 1, max: 50)();
  TextColumn get members => text().withLength(min: 1, max: 255)();
  TextColumn get targetId => text().withLength(min: 1, max: 255).nullable()();
  TextColumn get ownerId => text().withLength(min: 1, max: 255).nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  TextColumn get avatar => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isMuted => boolean().withDefault(const Constant(false))();
  TextColumn get extraInfo => text().nullable()();
  TextColumn get settings => text().nullable()();
  DateTimeColumn get lastMessageDate => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Message')
class Messages extends Table {
  IntColumn get messageId => integer().autoIncrement()();
  TextColumn get id => text()
      .withLength(min: 1, max: 255)
      .nullable()
      .unique()(); // UUIDs or other string IDs
  TextColumn get conversationId => text().customConstraint(
      'REFERENCES conversations(id) ON DELETE CASCADE NOT NULL')(); // Foreign key
  TextColumn get content => text().withLength(min: 0, max: 3000)();
  TextColumn get attachment => text().nullable()();
  DateTimeColumn get sentAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get receiverId => text().withLength(min: 1, max: 36)();
  TextColumn get senderId => text().withLength(min: 1, max: 36)();
  TextColumn get parentMessageId => text().withLength(min: 1, max: 36)();
  TextColumn get parentMessage => text().nullable()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  TextColumn get type => text().withLength(min: 1, max: 20)();
  TextColumn get url => text().nullable()();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isFavourite => boolean().withDefault(const Constant(false))();
  TextColumn get extraInfo => text().nullable()();
  IntColumn get status =>
      integer().withDefault(Constant(MessageStatusEnum.sent.value))();
}

@DataClassName('ConversationSetting')
class ConversationSettings extends Table {
  TextColumn get conversationId => text().customConstraint(
      'REFERENCES conversations(id) ON DELETE CASCADE NOT NULL ')(); // Foreign key
  BoolColumn get canEditGroupName =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get canChangeGroupProfilePhoto =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get canPostGroupAnnouncement =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get enableGroupEntryVerification =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get enableScreenCaptureProhibited =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get hideNotification =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get muteGroupMember =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get enableGroupMemberInvisibility =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get restrictSendingNameCard =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get forbidSendingPictures =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get forbidSendingVideos =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get forbidSendingFiles =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get enableVisibilityOfGroupMemberList =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get enableModifyName =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get enableAddNewMember =>
      boolean().withDefault(const Constant(true))();
  BoolColumn get enableReminderManagement =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {conversationId};
}

@DataClassName('Contact')
class Contacts extends Table {
  TextColumn get id =>
      text().withLength(min: 1, max: 255)(); // UUIDs or other string IDs
  TextColumn get name => text()();
  TextColumn get intro => text().nullable()();
  TextColumn get profilePicture => text().nullable()();
  TextColumn get profileAccessStrategy => text().nullable()();
  DateTimeColumn get registrationDate => dateTime().nullable()();
  DateTimeColumn get lastUpdatedDate => dateTime().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  TextColumn get userDefinedAttributes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Sticker')
class Stickers extends Table {
  TextColumn get id =>
      text().withLength(min: 1, max: 255)(); // UUIDs or other string IDs
  TextColumn get name => text()();
  TextColumn get userId => text()();
  TextColumn get path => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UserRelationship')
class UserRelationships extends Table {
  TextColumn get id => text().withLength(min: 1, max: 255)(); // Unique ID
  TextColumn get userId => text()();
  TextColumn get relatedUserId => text()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // Relationship status

  @override
  Set<Column> get primaryKey => {id}; // Primary key on the `id` column
}

@DriftDatabase(tables: [
  Conversations,
  Messages,
  ConversationSettings,
  Contacts,
  Stickers,
  UserRelationships
])
class AppDatabase extends _$AppDatabase {
  // After generating code, this class needs to define a schemaVersion getter
  // and a constructor telling drift where the database should be stored.
  // These are described in the getting started guide: https://drift.simonbinder.eu/getting-started/#open
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      beforeOpen: (details) async {
        await customStatement('PRAGMA foreign_keys = ON');
      },
      onCreate: (m) async => await m.createAll(),
    );
  }

  static LazyDatabase _openConnection() {
    // the LazyDatabase util lets us find the right location for the file async.
    return LazyDatabase(() async {
      // put the database file, called db.sqlite here, into the documents folder
      // for your app.
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));

      // Also work around limitations on old Android versions
      if (Platform.isAndroid) {
        await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
      }

      // Make sqlite3 pick a more suitable location for temporary files - the
      // one from the system may be inaccessible due to sandboxing.
      final cachebase = (await getTemporaryDirectory()).path;
      // We can't access /tmp on Android, which sqlite3 would try by default.
      // Explicitly tell it about the correct temporary directory.
      sqlite3.tempDirectory = cachebase;

      return NativeDatabase.createInBackground(file);
    });
  }
}

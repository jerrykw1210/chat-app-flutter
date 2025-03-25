// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ConversationsTable extends Conversations
    with TableInfo<$ConversationsTable, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 50),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _membersMeta =
      const VerificationMeta('members');
  @override
  late final GeneratedColumn<String> members = GeneratedColumn<String>(
      'members', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _targetIdMeta =
      const VerificationMeta('targetId');
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
      'target_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _ownerIdMeta =
      const VerificationMeta('ownerId');
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
      'owner_id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _isGroupMeta =
      const VerificationMeta('isGroup');
  @override
  late final GeneratedColumn<bool> isGroup = GeneratedColumn<bool>(
      'is_group', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_group" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _avatarMeta = const VerificationMeta('avatar');
  @override
  late final GeneratedColumn<String> avatar = GeneratedColumn<String>(
      'avatar', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isMutedMeta =
      const VerificationMeta('isMuted');
  @override
  late final GeneratedColumn<bool> isMuted = GeneratedColumn<bool>(
      'is_muted', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_muted" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _extraInfoMeta =
      const VerificationMeta('extraInfo');
  @override
  late final GeneratedColumn<String> extraInfo = GeneratedColumn<String>(
      'extra_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _settingsMeta =
      const VerificationMeta('settings');
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
      'settings', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastMessageDateMeta =
      const VerificationMeta('lastMessageDate');
  @override
  late final GeneratedColumn<DateTime> lastMessageDate =
      GeneratedColumn<DateTime>('last_message_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        members,
        targetId,
        ownerId,
        createdAt,
        isGroup,
        avatar,
        isPinned,
        isMuted,
        extraInfo,
        settings,
        lastMessageDate
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(Insertable<Conversation> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('members')) {
      context.handle(_membersMeta,
          members.isAcceptableOrUnknown(data['members']!, _membersMeta));
    } else if (isInserting) {
      context.missing(_membersMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(_targetIdMeta,
          targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta));
    }
    if (data.containsKey('owner_id')) {
      context.handle(_ownerIdMeta,
          ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('is_group')) {
      context.handle(_isGroupMeta,
          isGroup.isAcceptableOrUnknown(data['is_group']!, _isGroupMeta));
    }
    if (data.containsKey('avatar')) {
      context.handle(_avatarMeta,
          avatar.isAcceptableOrUnknown(data['avatar']!, _avatarMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('is_muted')) {
      context.handle(_isMutedMeta,
          isMuted.isAcceptableOrUnknown(data['is_muted']!, _isMutedMeta));
    }
    if (data.containsKey('extra_info')) {
      context.handle(_extraInfoMeta,
          extraInfo.isAcceptableOrUnknown(data['extra_info']!, _extraInfoMeta));
    }
    if (data.containsKey('settings')) {
      context.handle(_settingsMeta,
          settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta));
    }
    if (data.containsKey('last_message_date')) {
      context.handle(
          _lastMessageDateMeta,
          lastMessageDate.isAcceptableOrUnknown(
              data['last_message_date']!, _lastMessageDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      members: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}members'])!,
      targetId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}target_id']),
      ownerId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}owner_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      isGroup: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_group'])!,
      avatar: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar']),
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      isMuted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_muted'])!,
      extraInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extra_info']),
      settings: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settings']),
      lastMessageDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_message_date']),
    );
  }

  @override
  $ConversationsTable createAlias(String alias) {
    return $ConversationsTable(attachedDatabase, alias);
  }
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String title;
  final String members;
  final String? targetId;
  final String? ownerId;
  final DateTime createdAt;
  final bool isGroup;
  final String? avatar;
  final bool isPinned;
  final bool isMuted;
  final String? extraInfo;
  final String? settings;
  final DateTime? lastMessageDate;
  const Conversation(
      {required this.id,
      required this.title,
      required this.members,
      this.targetId,
      this.ownerId,
      required this.createdAt,
      required this.isGroup,
      this.avatar,
      required this.isPinned,
      required this.isMuted,
      this.extraInfo,
      this.settings,
      this.lastMessageDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['members'] = Variable<String>(members);
    if (!nullToAbsent || targetId != null) {
      map['target_id'] = Variable<String>(targetId);
    }
    if (!nullToAbsent || ownerId != null) {
      map['owner_id'] = Variable<String>(ownerId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['is_group'] = Variable<bool>(isGroup);
    if (!nullToAbsent || avatar != null) {
      map['avatar'] = Variable<String>(avatar);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_muted'] = Variable<bool>(isMuted);
    if (!nullToAbsent || extraInfo != null) {
      map['extra_info'] = Variable<String>(extraInfo);
    }
    if (!nullToAbsent || settings != null) {
      map['settings'] = Variable<String>(settings);
    }
    if (!nullToAbsent || lastMessageDate != null) {
      map['last_message_date'] = Variable<DateTime>(lastMessageDate);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      members: Value(members),
      targetId: targetId == null && nullToAbsent
          ? const Value.absent()
          : Value(targetId),
      ownerId: ownerId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerId),
      createdAt: Value(createdAt),
      isGroup: Value(isGroup),
      avatar:
          avatar == null && nullToAbsent ? const Value.absent() : Value(avatar),
      isPinned: Value(isPinned),
      isMuted: Value(isMuted),
      extraInfo: extraInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(extraInfo),
      settings: settings == null && nullToAbsent
          ? const Value.absent()
          : Value(settings),
      lastMessageDate: lastMessageDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessageDate),
    );
  }

  factory Conversation.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      members: serializer.fromJson<String>(json['members']),
      targetId: serializer.fromJson<String?>(json['targetId']),
      ownerId: serializer.fromJson<String?>(json['ownerId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      isGroup: serializer.fromJson<bool>(json['isGroup']),
      avatar: serializer.fromJson<String?>(json['avatar']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isMuted: serializer.fromJson<bool>(json['isMuted']),
      extraInfo: serializer.fromJson<String?>(json['extraInfo']),
      settings: serializer.fromJson<String?>(json['settings']),
      lastMessageDate: serializer.fromJson<DateTime?>(json['lastMessageDate']),
    );
  }
  factory Conversation.fromJsonString(String encodedJson,
          {ValueSerializer? serializer}) =>
      Conversation.fromJson(
          DataClass.parseJson(encodedJson) as Map<String, dynamic>,
          serializer: serializer);
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'members': serializer.toJson<String>(members),
      'targetId': serializer.toJson<String?>(targetId),
      'ownerId': serializer.toJson<String?>(ownerId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'isGroup': serializer.toJson<bool>(isGroup),
      'avatar': serializer.toJson<String?>(avatar),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isMuted': serializer.toJson<bool>(isMuted),
      'extraInfo': serializer.toJson<String?>(extraInfo),
      'settings': serializer.toJson<String?>(settings),
      'lastMessageDate': serializer.toJson<DateTime?>(lastMessageDate),
    };
  }

  Conversation copyWith(
          {String? id,
          String? title,
          String? members,
          Value<String?> targetId = const Value.absent(),
          Value<String?> ownerId = const Value.absent(),
          DateTime? createdAt,
          bool? isGroup,
          Value<String?> avatar = const Value.absent(),
          bool? isPinned,
          bool? isMuted,
          Value<String?> extraInfo = const Value.absent(),
          Value<String?> settings = const Value.absent(),
          Value<DateTime?> lastMessageDate = const Value.absent()}) =>
      Conversation(
        id: id ?? this.id,
        title: title ?? this.title,
        members: members ?? this.members,
        targetId: targetId.present ? targetId.value : this.targetId,
        ownerId: ownerId.present ? ownerId.value : this.ownerId,
        createdAt: createdAt ?? this.createdAt,
        isGroup: isGroup ?? this.isGroup,
        avatar: avatar.present ? avatar.value : this.avatar,
        isPinned: isPinned ?? this.isPinned,
        isMuted: isMuted ?? this.isMuted,
        extraInfo: extraInfo.present ? extraInfo.value : this.extraInfo,
        settings: settings.present ? settings.value : this.settings,
        lastMessageDate: lastMessageDate.present
            ? lastMessageDate.value
            : this.lastMessageDate,
      );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      members: data.members.present ? data.members.value : this.members,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      isGroup: data.isGroup.present ? data.isGroup.value : this.isGroup,
      avatar: data.avatar.present ? data.avatar.value : this.avatar,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isMuted: data.isMuted.present ? data.isMuted.value : this.isMuted,
      extraInfo: data.extraInfo.present ? data.extraInfo.value : this.extraInfo,
      settings: data.settings.present ? data.settings.value : this.settings,
      lastMessageDate: data.lastMessageDate.present
          ? data.lastMessageDate.value
          : this.lastMessageDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('members: $members, ')
          ..write('targetId: $targetId, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isGroup: $isGroup, ')
          ..write('avatar: $avatar, ')
          ..write('isPinned: $isPinned, ')
          ..write('isMuted: $isMuted, ')
          ..write('extraInfo: $extraInfo, ')
          ..write('settings: $settings, ')
          ..write('lastMessageDate: $lastMessageDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      members,
      targetId,
      ownerId,
      createdAt,
      isGroup,
      avatar,
      isPinned,
      isMuted,
      extraInfo,
      settings,
      lastMessageDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.members == this.members &&
          other.targetId == this.targetId &&
          other.ownerId == this.ownerId &&
          other.createdAt == this.createdAt &&
          other.isGroup == this.isGroup &&
          other.avatar == this.avatar &&
          other.isPinned == this.isPinned &&
          other.isMuted == this.isMuted &&
          other.extraInfo == this.extraInfo &&
          other.settings == this.settings &&
          other.lastMessageDate == this.lastMessageDate);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> members;
  final Value<String?> targetId;
  final Value<String?> ownerId;
  final Value<DateTime> createdAt;
  final Value<bool> isGroup;
  final Value<String?> avatar;
  final Value<bool> isPinned;
  final Value<bool> isMuted;
  final Value<String?> extraInfo;
  final Value<String?> settings;
  final Value<DateTime?> lastMessageDate;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.members = const Value.absent(),
    this.targetId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.avatar = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.extraInfo = const Value.absent(),
    this.settings = const Value.absent(),
    this.lastMessageDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    required String title,
    required String members,
    this.targetId = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.isGroup = const Value.absent(),
    this.avatar = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isMuted = const Value.absent(),
    this.extraInfo = const Value.absent(),
    this.settings = const Value.absent(),
    this.lastMessageDate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        members = Value(members);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? members,
    Expression<String>? targetId,
    Expression<String>? ownerId,
    Expression<DateTime>? createdAt,
    Expression<bool>? isGroup,
    Expression<String>? avatar,
    Expression<bool>? isPinned,
    Expression<bool>? isMuted,
    Expression<String>? extraInfo,
    Expression<String>? settings,
    Expression<DateTime>? lastMessageDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (members != null) 'members': members,
      if (targetId != null) 'target_id': targetId,
      if (ownerId != null) 'owner_id': ownerId,
      if (createdAt != null) 'created_at': createdAt,
      if (isGroup != null) 'is_group': isGroup,
      if (avatar != null) 'avatar': avatar,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isMuted != null) 'is_muted': isMuted,
      if (extraInfo != null) 'extra_info': extraInfo,
      if (settings != null) 'settings': settings,
      if (lastMessageDate != null) 'last_message_date': lastMessageDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? members,
      Value<String?>? targetId,
      Value<String?>? ownerId,
      Value<DateTime>? createdAt,
      Value<bool>? isGroup,
      Value<String?>? avatar,
      Value<bool>? isPinned,
      Value<bool>? isMuted,
      Value<String?>? extraInfo,
      Value<String?>? settings,
      Value<DateTime?>? lastMessageDate,
      Value<int>? rowid}) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      members: members ?? this.members,
      targetId: targetId ?? this.targetId,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      isGroup: isGroup ?? this.isGroup,
      avatar: avatar ?? this.avatar,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      extraInfo: extraInfo ?? this.extraInfo,
      settings: settings ?? this.settings,
      lastMessageDate: lastMessageDate ?? this.lastMessageDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (members.present) {
      map['members'] = Variable<String>(members.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (isGroup.present) {
      map['is_group'] = Variable<bool>(isGroup.value);
    }
    if (avatar.present) {
      map['avatar'] = Variable<String>(avatar.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isMuted.present) {
      map['is_muted'] = Variable<bool>(isMuted.value);
    }
    if (extraInfo.present) {
      map['extra_info'] = Variable<String>(extraInfo.value);
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (lastMessageDate.present) {
      map['last_message_date'] = Variable<DateTime>(lastMessageDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('members: $members, ')
          ..write('targetId: $targetId, ')
          ..write('ownerId: $ownerId, ')
          ..write('createdAt: $createdAt, ')
          ..write('isGroup: $isGroup, ')
          ..write('avatar: $avatar, ')
          ..write('isPinned: $isPinned, ')
          ..write('isMuted: $isMuted, ')
          ..write('extraInfo: $extraInfo, ')
          ..write('settings: $settings, ')
          ..write('lastMessageDate: $lastMessageDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _messageIdMeta =
      const VerificationMeta('messageId');
  @override
  late final GeneratedColumn<int> messageId = GeneratedColumn<int>(
      'message_id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, true,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'REFERENCES conversations(id) ON DELETE CASCADE NOT NULL');
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      additionalChecks: GeneratedColumn.checkTextLength(
          minTextLength: 0, maxTextLength: 3000),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _attachmentMeta =
      const VerificationMeta('attachment');
  @override
  late final GeneratedColumn<String> attachment = GeneratedColumn<String>(
      'attachment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
      'sent_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _receiverIdMeta =
      const VerificationMeta('receiverId');
  @override
  late final GeneratedColumn<String> receiverId = GeneratedColumn<String>(
      'receiver_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _senderIdMeta =
      const VerificationMeta('senderId');
  @override
  late final GeneratedColumn<String> senderId = GeneratedColumn<String>(
      'sender_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _parentMessageIdMeta =
      const VerificationMeta('parentMessageId');
  @override
  late final GeneratedColumn<String> parentMessageId = GeneratedColumn<String>(
      'parent_message_id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 36),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _parentMessageMeta =
      const VerificationMeta('parentMessage');
  @override
  late final GeneratedColumn<String> parentMessage = GeneratedColumn<String>(
      'parent_message', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 20),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isFavouriteMeta =
      const VerificationMeta('isFavourite');
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
      'is_favourite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_favourite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _extraInfoMeta =
      const VerificationMeta('extraInfo');
  @override
  late final GeneratedColumn<String> extraInfo = GeneratedColumn<String>(
      'extra_info', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: Constant(MessageStatusEnum.sent.value));
  @override
  List<GeneratedColumn> get $columns => [
        messageId,
        id,
        conversationId,
        content,
        attachment,
        sentAt,
        receiverId,
        senderId,
        parentMessageId,
        parentMessage,
        isRead,
        type,
        url,
        isPinned,
        isFavourite,
        extraInfo,
        status
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(Insertable<Message> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('message_id')) {
      context.handle(_messageIdMeta,
          messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta));
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('attachment')) {
      context.handle(
          _attachmentMeta,
          attachment.isAcceptableOrUnknown(
              data['attachment']!, _attachmentMeta));
    }
    if (data.containsKey('sent_at')) {
      context.handle(_sentAtMeta,
          sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta));
    }
    if (data.containsKey('receiver_id')) {
      context.handle(
          _receiverIdMeta,
          receiverId.isAcceptableOrUnknown(
              data['receiver_id']!, _receiverIdMeta));
    } else if (isInserting) {
      context.missing(_receiverIdMeta);
    }
    if (data.containsKey('sender_id')) {
      context.handle(_senderIdMeta,
          senderId.isAcceptableOrUnknown(data['sender_id']!, _senderIdMeta));
    } else if (isInserting) {
      context.missing(_senderIdMeta);
    }
    if (data.containsKey('parent_message_id')) {
      context.handle(
          _parentMessageIdMeta,
          parentMessageId.isAcceptableOrUnknown(
              data['parent_message_id']!, _parentMessageIdMeta));
    } else if (isInserting) {
      context.missing(_parentMessageIdMeta);
    }
    if (data.containsKey('parent_message')) {
      context.handle(
          _parentMessageMeta,
          parentMessage.isAcceptableOrUnknown(
              data['parent_message']!, _parentMessageMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
          _isFavouriteMeta,
          isFavourite.isAcceptableOrUnknown(
              data['is_favourite']!, _isFavouriteMeta));
    }
    if (data.containsKey('extra_info')) {
      context.handle(_extraInfoMeta,
          extraInfo.isAcceptableOrUnknown(data['extra_info']!, _extraInfoMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {messageId};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      messageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}message_id'])!,
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id']),
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      attachment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}attachment']),
      sentAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sent_at'])!,
      receiverId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}receiver_id'])!,
      senderId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sender_id'])!,
      parentMessageId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}parent_message_id'])!,
      parentMessage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_message']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url']),
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      isFavourite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favourite'])!,
      extraInfo: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}extra_info']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int messageId;
  final String? id;
  final String conversationId;
  final String content;
  final String? attachment;
  final DateTime sentAt;
  final String receiverId;
  final String senderId;
  final String parentMessageId;
  final String? parentMessage;
  final bool isRead;
  final String type;
  final String? url;
  final bool isPinned;
  final bool isFavourite;
  final String? extraInfo;
  final int status;
  const Message(
      {required this.messageId,
      this.id,
      required this.conversationId,
      required this.content,
      this.attachment,
      required this.sentAt,
      required this.receiverId,
      required this.senderId,
      required this.parentMessageId,
      this.parentMessage,
      required this.isRead,
      required this.type,
      this.url,
      required this.isPinned,
      required this.isFavourite,
      this.extraInfo,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['message_id'] = Variable<int>(messageId);
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['conversation_id'] = Variable<String>(conversationId);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || attachment != null) {
      map['attachment'] = Variable<String>(attachment);
    }
    map['sent_at'] = Variable<DateTime>(sentAt);
    map['receiver_id'] = Variable<String>(receiverId);
    map['sender_id'] = Variable<String>(senderId);
    map['parent_message_id'] = Variable<String>(parentMessageId);
    if (!nullToAbsent || parentMessage != null) {
      map['parent_message'] = Variable<String>(parentMessage);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || url != null) {
      map['url'] = Variable<String>(url);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_favourite'] = Variable<bool>(isFavourite);
    if (!nullToAbsent || extraInfo != null) {
      map['extra_info'] = Variable<String>(extraInfo);
    }
    map['status'] = Variable<int>(status);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      messageId: Value(messageId),
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      conversationId: Value(conversationId),
      content: Value(content),
      attachment: attachment == null && nullToAbsent
          ? const Value.absent()
          : Value(attachment),
      sentAt: Value(sentAt),
      receiverId: Value(receiverId),
      senderId: Value(senderId),
      parentMessageId: Value(parentMessageId),
      parentMessage: parentMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(parentMessage),
      isRead: Value(isRead),
      type: Value(type),
      url: url == null && nullToAbsent ? const Value.absent() : Value(url),
      isPinned: Value(isPinned),
      isFavourite: Value(isFavourite),
      extraInfo: extraInfo == null && nullToAbsent
          ? const Value.absent()
          : Value(extraInfo),
      status: Value(status),
    );
  }

  factory Message.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      messageId: serializer.fromJson<int>(json['messageId']),
      id: serializer.fromJson<String?>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversationId']),
      content: serializer.fromJson<String>(json['content']),
      attachment: serializer.fromJson<String?>(json['attachment']),
      sentAt: serializer.fromJson<DateTime>(json['sentAt']),
      receiverId: serializer.fromJson<String>(json['receiverId']),
      senderId: serializer.fromJson<String>(json['senderId']),
      parentMessageId: serializer.fromJson<String>(json['parentMessageId']),
      parentMessage: serializer.fromJson<String?>(json['parentMessage']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      type: serializer.fromJson<String>(json['type']),
      url: serializer.fromJson<String?>(json['url']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
      extraInfo: serializer.fromJson<String?>(json['extraInfo']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  factory Message.fromJsonString(String encodedJson,
          {ValueSerializer? serializer}) =>
      Message.fromJson(DataClass.parseJson(encodedJson) as Map<String, dynamic>,
          serializer: serializer);
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'messageId': serializer.toJson<int>(messageId),
      'id': serializer.toJson<String?>(id),
      'conversationId': serializer.toJson<String>(conversationId),
      'content': serializer.toJson<String>(content),
      'attachment': serializer.toJson<String?>(attachment),
      'sentAt': serializer.toJson<DateTime>(sentAt),
      'receiverId': serializer.toJson<String>(receiverId),
      'senderId': serializer.toJson<String>(senderId),
      'parentMessageId': serializer.toJson<String>(parentMessageId),
      'parentMessage': serializer.toJson<String?>(parentMessage),
      'isRead': serializer.toJson<bool>(isRead),
      'type': serializer.toJson<String>(type),
      'url': serializer.toJson<String?>(url),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isFavourite': serializer.toJson<bool>(isFavourite),
      'extraInfo': serializer.toJson<String?>(extraInfo),
      'status': serializer.toJson<int>(status),
    };
  }

  Message copyWith(
          {int? messageId,
          Value<String?> id = const Value.absent(),
          String? conversationId,
          String? content,
          Value<String?> attachment = const Value.absent(),
          DateTime? sentAt,
          String? receiverId,
          String? senderId,
          String? parentMessageId,
          Value<String?> parentMessage = const Value.absent(),
          bool? isRead,
          String? type,
          Value<String?> url = const Value.absent(),
          bool? isPinned,
          bool? isFavourite,
          Value<String?> extraInfo = const Value.absent(),
          int? status}) =>
      Message(
        messageId: messageId ?? this.messageId,
        id: id.present ? id.value : this.id,
        conversationId: conversationId ?? this.conversationId,
        content: content ?? this.content,
        attachment: attachment.present ? attachment.value : this.attachment,
        sentAt: sentAt ?? this.sentAt,
        receiverId: receiverId ?? this.receiverId,
        senderId: senderId ?? this.senderId,
        parentMessageId: parentMessageId ?? this.parentMessageId,
        parentMessage:
            parentMessage.present ? parentMessage.value : this.parentMessage,
        isRead: isRead ?? this.isRead,
        type: type ?? this.type,
        url: url.present ? url.value : this.url,
        isPinned: isPinned ?? this.isPinned,
        isFavourite: isFavourite ?? this.isFavourite,
        extraInfo: extraInfo.present ? extraInfo.value : this.extraInfo,
        status: status ?? this.status,
      );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      content: data.content.present ? data.content.value : this.content,
      attachment:
          data.attachment.present ? data.attachment.value : this.attachment,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      receiverId:
          data.receiverId.present ? data.receiverId.value : this.receiverId,
      senderId: data.senderId.present ? data.senderId.value : this.senderId,
      parentMessageId: data.parentMessageId.present
          ? data.parentMessageId.value
          : this.parentMessageId,
      parentMessage: data.parentMessage.present
          ? data.parentMessage.value
          : this.parentMessage,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      type: data.type.present ? data.type.value : this.type,
      url: data.url.present ? data.url.value : this.url,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isFavourite:
          data.isFavourite.present ? data.isFavourite.value : this.isFavourite,
      extraInfo: data.extraInfo.present ? data.extraInfo.value : this.extraInfo,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('messageId: $messageId, ')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('content: $content, ')
          ..write('attachment: $attachment, ')
          ..write('sentAt: $sentAt, ')
          ..write('receiverId: $receiverId, ')
          ..write('senderId: $senderId, ')
          ..write('parentMessageId: $parentMessageId, ')
          ..write('parentMessage: $parentMessage, ')
          ..write('isRead: $isRead, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('extraInfo: $extraInfo, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      messageId,
      id,
      conversationId,
      content,
      attachment,
      sentAt,
      receiverId,
      senderId,
      parentMessageId,
      parentMessage,
      isRead,
      type,
      url,
      isPinned,
      isFavourite,
      extraInfo,
      status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.messageId == this.messageId &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.content == this.content &&
          other.attachment == this.attachment &&
          other.sentAt == this.sentAt &&
          other.receiverId == this.receiverId &&
          other.senderId == this.senderId &&
          other.parentMessageId == this.parentMessageId &&
          other.parentMessage == this.parentMessage &&
          other.isRead == this.isRead &&
          other.type == this.type &&
          other.url == this.url &&
          other.isPinned == this.isPinned &&
          other.isFavourite == this.isFavourite &&
          other.extraInfo == this.extraInfo &&
          other.status == this.status);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> messageId;
  final Value<String?> id;
  final Value<String> conversationId;
  final Value<String> content;
  final Value<String?> attachment;
  final Value<DateTime> sentAt;
  final Value<String> receiverId;
  final Value<String> senderId;
  final Value<String> parentMessageId;
  final Value<String?> parentMessage;
  final Value<bool> isRead;
  final Value<String> type;
  final Value<String?> url;
  final Value<bool> isPinned;
  final Value<bool> isFavourite;
  final Value<String?> extraInfo;
  final Value<int> status;
  const MessagesCompanion({
    this.messageId = const Value.absent(),
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.content = const Value.absent(),
    this.attachment = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.receiverId = const Value.absent(),
    this.senderId = const Value.absent(),
    this.parentMessageId = const Value.absent(),
    this.parentMessage = const Value.absent(),
    this.isRead = const Value.absent(),
    this.type = const Value.absent(),
    this.url = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.extraInfo = const Value.absent(),
    this.status = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.messageId = const Value.absent(),
    this.id = const Value.absent(),
    required String conversationId,
    required String content,
    this.attachment = const Value.absent(),
    this.sentAt = const Value.absent(),
    required String receiverId,
    required String senderId,
    required String parentMessageId,
    this.parentMessage = const Value.absent(),
    this.isRead = const Value.absent(),
    required String type,
    this.url = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.extraInfo = const Value.absent(),
    this.status = const Value.absent(),
  })  : conversationId = Value(conversationId),
        content = Value(content),
        receiverId = Value(receiverId),
        senderId = Value(senderId),
        parentMessageId = Value(parentMessageId),
        type = Value(type);
  static Insertable<Message> custom({
    Expression<int>? messageId,
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? content,
    Expression<String>? attachment,
    Expression<DateTime>? sentAt,
    Expression<String>? receiverId,
    Expression<String>? senderId,
    Expression<String>? parentMessageId,
    Expression<String>? parentMessage,
    Expression<bool>? isRead,
    Expression<String>? type,
    Expression<String>? url,
    Expression<bool>? isPinned,
    Expression<bool>? isFavourite,
    Expression<String>? extraInfo,
    Expression<int>? status,
  }) {
    return RawValuesInsertable({
      if (messageId != null) 'message_id': messageId,
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (content != null) 'content': content,
      if (attachment != null) 'attachment': attachment,
      if (sentAt != null) 'sent_at': sentAt,
      if (receiverId != null) 'receiver_id': receiverId,
      if (senderId != null) 'sender_id': senderId,
      if (parentMessageId != null) 'parent_message_id': parentMessageId,
      if (parentMessage != null) 'parent_message': parentMessage,
      if (isRead != null) 'is_read': isRead,
      if (type != null) 'type': type,
      if (url != null) 'url': url,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (extraInfo != null) 'extra_info': extraInfo,
      if (status != null) 'status': status,
    });
  }

  MessagesCompanion copyWith(
      {Value<int>? messageId,
      Value<String?>? id,
      Value<String>? conversationId,
      Value<String>? content,
      Value<String?>? attachment,
      Value<DateTime>? sentAt,
      Value<String>? receiverId,
      Value<String>? senderId,
      Value<String>? parentMessageId,
      Value<String?>? parentMessage,
      Value<bool>? isRead,
      Value<String>? type,
      Value<String?>? url,
      Value<bool>? isPinned,
      Value<bool>? isFavourite,
      Value<String?>? extraInfo,
      Value<int>? status}) {
    return MessagesCompanion(
      messageId: messageId ?? this.messageId,
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      content: content ?? this.content,
      attachment: attachment ?? this.attachment,
      sentAt: sentAt ?? this.sentAt,
      receiverId: receiverId ?? this.receiverId,
      senderId: senderId ?? this.senderId,
      parentMessageId: parentMessageId ?? this.parentMessageId,
      parentMessage: parentMessage ?? this.parentMessage,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      url: url ?? this.url,
      isPinned: isPinned ?? this.isPinned,
      isFavourite: isFavourite ?? this.isFavourite,
      extraInfo: extraInfo ?? this.extraInfo,
      status: status ?? this.status,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (messageId.present) {
      map['message_id'] = Variable<int>(messageId.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (attachment.present) {
      map['attachment'] = Variable<String>(attachment.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (receiverId.present) {
      map['receiver_id'] = Variable<String>(receiverId.value);
    }
    if (senderId.present) {
      map['sender_id'] = Variable<String>(senderId.value);
    }
    if (parentMessageId.present) {
      map['parent_message_id'] = Variable<String>(parentMessageId.value);
    }
    if (parentMessage.present) {
      map['parent_message'] = Variable<String>(parentMessage.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (extraInfo.present) {
      map['extra_info'] = Variable<String>(extraInfo.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('messageId: $messageId, ')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('content: $content, ')
          ..write('attachment: $attachment, ')
          ..write('sentAt: $sentAt, ')
          ..write('receiverId: $receiverId, ')
          ..write('senderId: $senderId, ')
          ..write('parentMessageId: $parentMessageId, ')
          ..write('parentMessage: $parentMessage, ')
          ..write('isRead: $isRead, ')
          ..write('type: $type, ')
          ..write('url: $url, ')
          ..write('isPinned: $isPinned, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('extraInfo: $extraInfo, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }
}

class $ConversationSettingsTable extends ConversationSettings
    with TableInfo<$ConversationSettingsTable, ConversationSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConversationSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _conversationIdMeta =
      const VerificationMeta('conversationId');
  @override
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
      'conversation_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints:
          'REFERENCES conversations(id) ON DELETE CASCADE NOT NULL ');
  static const VerificationMeta _canEditGroupNameMeta =
      const VerificationMeta('canEditGroupName');
  @override
  late final GeneratedColumn<bool> canEditGroupName = GeneratedColumn<bool>(
      'can_edit_group_name', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("can_edit_group_name" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _canChangeGroupProfilePhotoMeta =
      const VerificationMeta('canChangeGroupProfilePhoto');
  @override
  late final GeneratedColumn<bool> canChangeGroupProfilePhoto =
      GeneratedColumn<bool>(
          'can_change_group_profile_photo', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("can_change_group_profile_photo" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _canPostGroupAnnouncementMeta =
      const VerificationMeta('canPostGroupAnnouncement');
  @override
  late final GeneratedColumn<bool> canPostGroupAnnouncement =
      GeneratedColumn<bool>(
          'can_post_group_announcement', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("can_post_group_announcement" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _enableGroupEntryVerificationMeta =
      const VerificationMeta('enableGroupEntryVerification');
  @override
  late final GeneratedColumn<bool> enableGroupEntryVerification =
      GeneratedColumn<bool>(
          'enable_group_entry_verification', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_group_entry_verification" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _enableScreenCaptureProhibitedMeta =
      const VerificationMeta('enableScreenCaptureProhibited');
  @override
  late final GeneratedColumn<bool> enableScreenCaptureProhibited =
      GeneratedColumn<bool>(
          'enable_screen_capture_prohibited', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_screen_capture_prohibited" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _hideNotificationMeta =
      const VerificationMeta('hideNotification');
  @override
  late final GeneratedColumn<bool> hideNotification = GeneratedColumn<bool>(
      'hide_notification', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("hide_notification" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _muteGroupMemberMeta =
      const VerificationMeta('muteGroupMember');
  @override
  late final GeneratedColumn<bool> muteGroupMember = GeneratedColumn<bool>(
      'mute_group_member', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("mute_group_member" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enableGroupMemberInvisibilityMeta =
      const VerificationMeta('enableGroupMemberInvisibility');
  @override
  late final GeneratedColumn<bool> enableGroupMemberInvisibility =
      GeneratedColumn<bool>(
          'enable_group_member_invisibility', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_group_member_invisibility" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _restrictSendingNameCardMeta =
      const VerificationMeta('restrictSendingNameCard');
  @override
  late final GeneratedColumn<bool> restrictSendingNameCard =
      GeneratedColumn<bool>('restrict_sending_name_card', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("restrict_sending_name_card" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _forbidSendingPicturesMeta =
      const VerificationMeta('forbidSendingPictures');
  @override
  late final GeneratedColumn<bool> forbidSendingPictures =
      GeneratedColumn<bool>('forbid_sending_pictures', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("forbid_sending_pictures" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _forbidSendingVideosMeta =
      const VerificationMeta('forbidSendingVideos');
  @override
  late final GeneratedColumn<bool> forbidSendingVideos = GeneratedColumn<bool>(
      'forbid_sending_videos', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("forbid_sending_videos" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _forbidSendingFilesMeta =
      const VerificationMeta('forbidSendingFiles');
  @override
  late final GeneratedColumn<bool> forbidSendingFiles = GeneratedColumn<bool>(
      'forbid_sending_files', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("forbid_sending_files" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enableVisibilityOfGroupMemberListMeta =
      const VerificationMeta('enableVisibilityOfGroupMemberList');
  @override
  late final GeneratedColumn<bool> enableVisibilityOfGroupMemberList =
      GeneratedColumn<bool>(
          'enable_visibility_of_group_member_list', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_visibility_of_group_member_list" IN (0, 1))'),
          defaultValue: const Constant(true));
  static const VerificationMeta _enableModifyNameMeta =
      const VerificationMeta('enableModifyName');
  @override
  late final GeneratedColumn<bool> enableModifyName = GeneratedColumn<bool>(
      'enable_modify_name', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_modify_name" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _enableAddNewMemberMeta =
      const VerificationMeta('enableAddNewMember');
  @override
  late final GeneratedColumn<bool> enableAddNewMember = GeneratedColumn<bool>(
      'enable_add_new_member', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("enable_add_new_member" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _enableReminderManagementMeta =
      const VerificationMeta('enableReminderManagement');
  @override
  late final GeneratedColumn<bool> enableReminderManagement =
      GeneratedColumn<bool>(
          'enable_reminder_management', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("enable_reminder_management" IN (0, 1))'),
          defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        conversationId,
        canEditGroupName,
        canChangeGroupProfilePhoto,
        canPostGroupAnnouncement,
        enableGroupEntryVerification,
        enableScreenCaptureProhibited,
        hideNotification,
        muteGroupMember,
        enableGroupMemberInvisibility,
        restrictSendingNameCard,
        forbidSendingPictures,
        forbidSendingVideos,
        forbidSendingFiles,
        enableVisibilityOfGroupMemberList,
        enableModifyName,
        enableAddNewMember,
        enableReminderManagement
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversation_settings';
  @override
  VerificationContext validateIntegrity(
      Insertable<ConversationSetting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('conversation_id')) {
      context.handle(
          _conversationIdMeta,
          conversationId.isAcceptableOrUnknown(
              data['conversation_id']!, _conversationIdMeta));
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('can_edit_group_name')) {
      context.handle(
          _canEditGroupNameMeta,
          canEditGroupName.isAcceptableOrUnknown(
              data['can_edit_group_name']!, _canEditGroupNameMeta));
    }
    if (data.containsKey('can_change_group_profile_photo')) {
      context.handle(
          _canChangeGroupProfilePhotoMeta,
          canChangeGroupProfilePhoto.isAcceptableOrUnknown(
              data['can_change_group_profile_photo']!,
              _canChangeGroupProfilePhotoMeta));
    }
    if (data.containsKey('can_post_group_announcement')) {
      context.handle(
          _canPostGroupAnnouncementMeta,
          canPostGroupAnnouncement.isAcceptableOrUnknown(
              data['can_post_group_announcement']!,
              _canPostGroupAnnouncementMeta));
    }
    if (data.containsKey('enable_group_entry_verification')) {
      context.handle(
          _enableGroupEntryVerificationMeta,
          enableGroupEntryVerification.isAcceptableOrUnknown(
              data['enable_group_entry_verification']!,
              _enableGroupEntryVerificationMeta));
    }
    if (data.containsKey('enable_screen_capture_prohibited')) {
      context.handle(
          _enableScreenCaptureProhibitedMeta,
          enableScreenCaptureProhibited.isAcceptableOrUnknown(
              data['enable_screen_capture_prohibited']!,
              _enableScreenCaptureProhibitedMeta));
    }
    if (data.containsKey('hide_notification')) {
      context.handle(
          _hideNotificationMeta,
          hideNotification.isAcceptableOrUnknown(
              data['hide_notification']!, _hideNotificationMeta));
    }
    if (data.containsKey('mute_group_member')) {
      context.handle(
          _muteGroupMemberMeta,
          muteGroupMember.isAcceptableOrUnknown(
              data['mute_group_member']!, _muteGroupMemberMeta));
    }
    if (data.containsKey('enable_group_member_invisibility')) {
      context.handle(
          _enableGroupMemberInvisibilityMeta,
          enableGroupMemberInvisibility.isAcceptableOrUnknown(
              data['enable_group_member_invisibility']!,
              _enableGroupMemberInvisibilityMeta));
    }
    if (data.containsKey('restrict_sending_name_card')) {
      context.handle(
          _restrictSendingNameCardMeta,
          restrictSendingNameCard.isAcceptableOrUnknown(
              data['restrict_sending_name_card']!,
              _restrictSendingNameCardMeta));
    }
    if (data.containsKey('forbid_sending_pictures')) {
      context.handle(
          _forbidSendingPicturesMeta,
          forbidSendingPictures.isAcceptableOrUnknown(
              data['forbid_sending_pictures']!, _forbidSendingPicturesMeta));
    }
    if (data.containsKey('forbid_sending_videos')) {
      context.handle(
          _forbidSendingVideosMeta,
          forbidSendingVideos.isAcceptableOrUnknown(
              data['forbid_sending_videos']!, _forbidSendingVideosMeta));
    }
    if (data.containsKey('forbid_sending_files')) {
      context.handle(
          _forbidSendingFilesMeta,
          forbidSendingFiles.isAcceptableOrUnknown(
              data['forbid_sending_files']!, _forbidSendingFilesMeta));
    }
    if (data.containsKey('enable_visibility_of_group_member_list')) {
      context.handle(
          _enableVisibilityOfGroupMemberListMeta,
          enableVisibilityOfGroupMemberList.isAcceptableOrUnknown(
              data['enable_visibility_of_group_member_list']!,
              _enableVisibilityOfGroupMemberListMeta));
    }
    if (data.containsKey('enable_modify_name')) {
      context.handle(
          _enableModifyNameMeta,
          enableModifyName.isAcceptableOrUnknown(
              data['enable_modify_name']!, _enableModifyNameMeta));
    }
    if (data.containsKey('enable_add_new_member')) {
      context.handle(
          _enableAddNewMemberMeta,
          enableAddNewMember.isAcceptableOrUnknown(
              data['enable_add_new_member']!, _enableAddNewMemberMeta));
    }
    if (data.containsKey('enable_reminder_management')) {
      context.handle(
          _enableReminderManagementMeta,
          enableReminderManagement.isAcceptableOrUnknown(
              data['enable_reminder_management']!,
              _enableReminderManagementMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {conversationId};
  @override
  ConversationSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConversationSetting(
      conversationId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}conversation_id'])!,
      canEditGroupName: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}can_edit_group_name'])!,
      canChangeGroupProfilePhoto: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}can_change_group_profile_photo'])!,
      canPostGroupAnnouncement: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}can_post_group_announcement'])!,
      enableGroupEntryVerification: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_group_entry_verification'])!,
      enableScreenCaptureProhibited: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_screen_capture_prohibited'])!,
      hideNotification: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}hide_notification'])!,
      muteGroupMember: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}mute_group_member'])!,
      enableGroupMemberInvisibility: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_group_member_invisibility'])!,
      restrictSendingNameCard: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}restrict_sending_name_card'])!,
      forbidSendingPictures: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}forbid_sending_pictures'])!,
      forbidSendingVideos: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}forbid_sending_videos'])!,
      forbidSendingFiles: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}forbid_sending_files'])!,
      enableVisibilityOfGroupMemberList: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_visibility_of_group_member_list'])!,
      enableModifyName: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}enable_modify_name'])!,
      enableAddNewMember: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}enable_add_new_member'])!,
      enableReminderManagement: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}enable_reminder_management'])!,
    );
  }

  @override
  $ConversationSettingsTable createAlias(String alias) {
    return $ConversationSettingsTable(attachedDatabase, alias);
  }
}

class ConversationSetting extends DataClass
    implements Insertable<ConversationSetting> {
  final String conversationId;
  final bool canEditGroupName;
  final bool canChangeGroupProfilePhoto;
  final bool canPostGroupAnnouncement;
  final bool enableGroupEntryVerification;
  final bool enableScreenCaptureProhibited;
  final bool hideNotification;
  final bool muteGroupMember;
  final bool enableGroupMemberInvisibility;
  final bool restrictSendingNameCard;
  final bool forbidSendingPictures;
  final bool forbidSendingVideos;
  final bool forbidSendingFiles;
  final bool enableVisibilityOfGroupMemberList;
  final bool enableModifyName;
  final bool enableAddNewMember;
  final bool enableReminderManagement;
  const ConversationSetting(
      {required this.conversationId,
      required this.canEditGroupName,
      required this.canChangeGroupProfilePhoto,
      required this.canPostGroupAnnouncement,
      required this.enableGroupEntryVerification,
      required this.enableScreenCaptureProhibited,
      required this.hideNotification,
      required this.muteGroupMember,
      required this.enableGroupMemberInvisibility,
      required this.restrictSendingNameCard,
      required this.forbidSendingPictures,
      required this.forbidSendingVideos,
      required this.forbidSendingFiles,
      required this.enableVisibilityOfGroupMemberList,
      required this.enableModifyName,
      required this.enableAddNewMember,
      required this.enableReminderManagement});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['conversation_id'] = Variable<String>(conversationId);
    map['can_edit_group_name'] = Variable<bool>(canEditGroupName);
    map['can_change_group_profile_photo'] =
        Variable<bool>(canChangeGroupProfilePhoto);
    map['can_post_group_announcement'] =
        Variable<bool>(canPostGroupAnnouncement);
    map['enable_group_entry_verification'] =
        Variable<bool>(enableGroupEntryVerification);
    map['enable_screen_capture_prohibited'] =
        Variable<bool>(enableScreenCaptureProhibited);
    map['hide_notification'] = Variable<bool>(hideNotification);
    map['mute_group_member'] = Variable<bool>(muteGroupMember);
    map['enable_group_member_invisibility'] =
        Variable<bool>(enableGroupMemberInvisibility);
    map['restrict_sending_name_card'] = Variable<bool>(restrictSendingNameCard);
    map['forbid_sending_pictures'] = Variable<bool>(forbidSendingPictures);
    map['forbid_sending_videos'] = Variable<bool>(forbidSendingVideos);
    map['forbid_sending_files'] = Variable<bool>(forbidSendingFiles);
    map['enable_visibility_of_group_member_list'] =
        Variable<bool>(enableVisibilityOfGroupMemberList);
    map['enable_modify_name'] = Variable<bool>(enableModifyName);
    map['enable_add_new_member'] = Variable<bool>(enableAddNewMember);
    map['enable_reminder_management'] =
        Variable<bool>(enableReminderManagement);
    return map;
  }

  ConversationSettingsCompanion toCompanion(bool nullToAbsent) {
    return ConversationSettingsCompanion(
      conversationId: Value(conversationId),
      canEditGroupName: Value(canEditGroupName),
      canChangeGroupProfilePhoto: Value(canChangeGroupProfilePhoto),
      canPostGroupAnnouncement: Value(canPostGroupAnnouncement),
      enableGroupEntryVerification: Value(enableGroupEntryVerification),
      enableScreenCaptureProhibited: Value(enableScreenCaptureProhibited),
      hideNotification: Value(hideNotification),
      muteGroupMember: Value(muteGroupMember),
      enableGroupMemberInvisibility: Value(enableGroupMemberInvisibility),
      restrictSendingNameCard: Value(restrictSendingNameCard),
      forbidSendingPictures: Value(forbidSendingPictures),
      forbidSendingVideos: Value(forbidSendingVideos),
      forbidSendingFiles: Value(forbidSendingFiles),
      enableVisibilityOfGroupMemberList:
          Value(enableVisibilityOfGroupMemberList),
      enableModifyName: Value(enableModifyName),
      enableAddNewMember: Value(enableAddNewMember),
      enableReminderManagement: Value(enableReminderManagement),
    );
  }

  factory ConversationSetting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConversationSetting(
      conversationId: serializer.fromJson<String>(json['conversationId']),
      canEditGroupName: serializer.fromJson<bool>(json['canEditGroupName']),
      canChangeGroupProfilePhoto:
          serializer.fromJson<bool>(json['canChangeGroupProfilePhoto']),
      canPostGroupAnnouncement:
          serializer.fromJson<bool>(json['canPostGroupAnnouncement']),
      enableGroupEntryVerification:
          serializer.fromJson<bool>(json['enableGroupEntryVerification']),
      enableScreenCaptureProhibited:
          serializer.fromJson<bool>(json['enableScreenCaptureProhibited']),
      hideNotification: serializer.fromJson<bool>(json['hideNotification']),
      muteGroupMember: serializer.fromJson<bool>(json['muteGroupMember']),
      enableGroupMemberInvisibility:
          serializer.fromJson<bool>(json['enableGroupMemberInvisibility']),
      restrictSendingNameCard:
          serializer.fromJson<bool>(json['restrictSendingNameCard']),
      forbidSendingPictures:
          serializer.fromJson<bool>(json['forbidSendingPictures']),
      forbidSendingVideos:
          serializer.fromJson<bool>(json['forbidSendingVideos']),
      forbidSendingFiles: serializer.fromJson<bool>(json['forbidSendingFiles']),
      enableVisibilityOfGroupMemberList:
          serializer.fromJson<bool>(json['enableVisibilityOfGroupMemberList']),
      enableModifyName: serializer.fromJson<bool>(json['enableModifyName']),
      enableAddNewMember: serializer.fromJson<bool>(json['enableAddNewMember']),
      enableReminderManagement:
          serializer.fromJson<bool>(json['enableReminderManagement']),
    );
  }
  factory ConversationSetting.fromJsonString(String encodedJson,
          {ValueSerializer? serializer}) =>
      ConversationSetting.fromJson(
          DataClass.parseJson(encodedJson) as Map<String, dynamic>,
          serializer: serializer);
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'conversationId': serializer.toJson<String>(conversationId),
      'canEditGroupName': serializer.toJson<bool>(canEditGroupName),
      'canChangeGroupProfilePhoto':
          serializer.toJson<bool>(canChangeGroupProfilePhoto),
      'canPostGroupAnnouncement':
          serializer.toJson<bool>(canPostGroupAnnouncement),
      'enableGroupEntryVerification':
          serializer.toJson<bool>(enableGroupEntryVerification),
      'enableScreenCaptureProhibited':
          serializer.toJson<bool>(enableScreenCaptureProhibited),
      'hideNotification': serializer.toJson<bool>(hideNotification),
      'muteGroupMember': serializer.toJson<bool>(muteGroupMember),
      'enableGroupMemberInvisibility':
          serializer.toJson<bool>(enableGroupMemberInvisibility),
      'restrictSendingNameCard':
          serializer.toJson<bool>(restrictSendingNameCard),
      'forbidSendingPictures': serializer.toJson<bool>(forbidSendingPictures),
      'forbidSendingVideos': serializer.toJson<bool>(forbidSendingVideos),
      'forbidSendingFiles': serializer.toJson<bool>(forbidSendingFiles),
      'enableVisibilityOfGroupMemberList':
          serializer.toJson<bool>(enableVisibilityOfGroupMemberList),
      'enableModifyName': serializer.toJson<bool>(enableModifyName),
      'enableAddNewMember': serializer.toJson<bool>(enableAddNewMember),
      'enableReminderManagement':
          serializer.toJson<bool>(enableReminderManagement),
    };
  }

  ConversationSetting copyWith(
          {String? conversationId,
          bool? canEditGroupName,
          bool? canChangeGroupProfilePhoto,
          bool? canPostGroupAnnouncement,
          bool? enableGroupEntryVerification,
          bool? enableScreenCaptureProhibited,
          bool? hideNotification,
          bool? muteGroupMember,
          bool? enableGroupMemberInvisibility,
          bool? restrictSendingNameCard,
          bool? forbidSendingPictures,
          bool? forbidSendingVideos,
          bool? forbidSendingFiles,
          bool? enableVisibilityOfGroupMemberList,
          bool? enableModifyName,
          bool? enableAddNewMember,
          bool? enableReminderManagement}) =>
      ConversationSetting(
        conversationId: conversationId ?? this.conversationId,
        canEditGroupName: canEditGroupName ?? this.canEditGroupName,
        canChangeGroupProfilePhoto:
            canChangeGroupProfilePhoto ?? this.canChangeGroupProfilePhoto,
        canPostGroupAnnouncement:
            canPostGroupAnnouncement ?? this.canPostGroupAnnouncement,
        enableGroupEntryVerification:
            enableGroupEntryVerification ?? this.enableGroupEntryVerification,
        enableScreenCaptureProhibited:
            enableScreenCaptureProhibited ?? this.enableScreenCaptureProhibited,
        hideNotification: hideNotification ?? this.hideNotification,
        muteGroupMember: muteGroupMember ?? this.muteGroupMember,
        enableGroupMemberInvisibility:
            enableGroupMemberInvisibility ?? this.enableGroupMemberInvisibility,
        restrictSendingNameCard:
            restrictSendingNameCard ?? this.restrictSendingNameCard,
        forbidSendingPictures:
            forbidSendingPictures ?? this.forbidSendingPictures,
        forbidSendingVideos: forbidSendingVideos ?? this.forbidSendingVideos,
        forbidSendingFiles: forbidSendingFiles ?? this.forbidSendingFiles,
        enableVisibilityOfGroupMemberList: enableVisibilityOfGroupMemberList ??
            this.enableVisibilityOfGroupMemberList,
        enableModifyName: enableModifyName ?? this.enableModifyName,
        enableAddNewMember: enableAddNewMember ?? this.enableAddNewMember,
        enableReminderManagement:
            enableReminderManagement ?? this.enableReminderManagement,
      );
  ConversationSetting copyWithCompanion(ConversationSettingsCompanion data) {
    return ConversationSetting(
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      canEditGroupName: data.canEditGroupName.present
          ? data.canEditGroupName.value
          : this.canEditGroupName,
      canChangeGroupProfilePhoto: data.canChangeGroupProfilePhoto.present
          ? data.canChangeGroupProfilePhoto.value
          : this.canChangeGroupProfilePhoto,
      canPostGroupAnnouncement: data.canPostGroupAnnouncement.present
          ? data.canPostGroupAnnouncement.value
          : this.canPostGroupAnnouncement,
      enableGroupEntryVerification: data.enableGroupEntryVerification.present
          ? data.enableGroupEntryVerification.value
          : this.enableGroupEntryVerification,
      enableScreenCaptureProhibited: data.enableScreenCaptureProhibited.present
          ? data.enableScreenCaptureProhibited.value
          : this.enableScreenCaptureProhibited,
      hideNotification: data.hideNotification.present
          ? data.hideNotification.value
          : this.hideNotification,
      muteGroupMember: data.muteGroupMember.present
          ? data.muteGroupMember.value
          : this.muteGroupMember,
      enableGroupMemberInvisibility: data.enableGroupMemberInvisibility.present
          ? data.enableGroupMemberInvisibility.value
          : this.enableGroupMemberInvisibility,
      restrictSendingNameCard: data.restrictSendingNameCard.present
          ? data.restrictSendingNameCard.value
          : this.restrictSendingNameCard,
      forbidSendingPictures: data.forbidSendingPictures.present
          ? data.forbidSendingPictures.value
          : this.forbidSendingPictures,
      forbidSendingVideos: data.forbidSendingVideos.present
          ? data.forbidSendingVideos.value
          : this.forbidSendingVideos,
      forbidSendingFiles: data.forbidSendingFiles.present
          ? data.forbidSendingFiles.value
          : this.forbidSendingFiles,
      enableVisibilityOfGroupMemberList:
          data.enableVisibilityOfGroupMemberList.present
              ? data.enableVisibilityOfGroupMemberList.value
              : this.enableVisibilityOfGroupMemberList,
      enableModifyName: data.enableModifyName.present
          ? data.enableModifyName.value
          : this.enableModifyName,
      enableAddNewMember: data.enableAddNewMember.present
          ? data.enableAddNewMember.value
          : this.enableAddNewMember,
      enableReminderManagement: data.enableReminderManagement.present
          ? data.enableReminderManagement.value
          : this.enableReminderManagement,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConversationSetting(')
          ..write('conversationId: $conversationId, ')
          ..write('canEditGroupName: $canEditGroupName, ')
          ..write('canChangeGroupProfilePhoto: $canChangeGroupProfilePhoto, ')
          ..write('canPostGroupAnnouncement: $canPostGroupAnnouncement, ')
          ..write(
              'enableGroupEntryVerification: $enableGroupEntryVerification, ')
          ..write(
              'enableScreenCaptureProhibited: $enableScreenCaptureProhibited, ')
          ..write('hideNotification: $hideNotification, ')
          ..write('muteGroupMember: $muteGroupMember, ')
          ..write(
              'enableGroupMemberInvisibility: $enableGroupMemberInvisibility, ')
          ..write('restrictSendingNameCard: $restrictSendingNameCard, ')
          ..write('forbidSendingPictures: $forbidSendingPictures, ')
          ..write('forbidSendingVideos: $forbidSendingVideos, ')
          ..write('forbidSendingFiles: $forbidSendingFiles, ')
          ..write(
              'enableVisibilityOfGroupMemberList: $enableVisibilityOfGroupMemberList, ')
          ..write('enableModifyName: $enableModifyName, ')
          ..write('enableAddNewMember: $enableAddNewMember, ')
          ..write('enableReminderManagement: $enableReminderManagement')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      conversationId,
      canEditGroupName,
      canChangeGroupProfilePhoto,
      canPostGroupAnnouncement,
      enableGroupEntryVerification,
      enableScreenCaptureProhibited,
      hideNotification,
      muteGroupMember,
      enableGroupMemberInvisibility,
      restrictSendingNameCard,
      forbidSendingPictures,
      forbidSendingVideos,
      forbidSendingFiles,
      enableVisibilityOfGroupMemberList,
      enableModifyName,
      enableAddNewMember,
      enableReminderManagement);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConversationSetting &&
          other.conversationId == this.conversationId &&
          other.canEditGroupName == this.canEditGroupName &&
          other.canChangeGroupProfilePhoto == this.canChangeGroupProfilePhoto &&
          other.canPostGroupAnnouncement == this.canPostGroupAnnouncement &&
          other.enableGroupEntryVerification ==
              this.enableGroupEntryVerification &&
          other.enableScreenCaptureProhibited ==
              this.enableScreenCaptureProhibited &&
          other.hideNotification == this.hideNotification &&
          other.muteGroupMember == this.muteGroupMember &&
          other.enableGroupMemberInvisibility ==
              this.enableGroupMemberInvisibility &&
          other.restrictSendingNameCard == this.restrictSendingNameCard &&
          other.forbidSendingPictures == this.forbidSendingPictures &&
          other.forbidSendingVideos == this.forbidSendingVideos &&
          other.forbidSendingFiles == this.forbidSendingFiles &&
          other.enableVisibilityOfGroupMemberList ==
              this.enableVisibilityOfGroupMemberList &&
          other.enableModifyName == this.enableModifyName &&
          other.enableAddNewMember == this.enableAddNewMember &&
          other.enableReminderManagement == this.enableReminderManagement);
}

class ConversationSettingsCompanion
    extends UpdateCompanion<ConversationSetting> {
  final Value<String> conversationId;
  final Value<bool> canEditGroupName;
  final Value<bool> canChangeGroupProfilePhoto;
  final Value<bool> canPostGroupAnnouncement;
  final Value<bool> enableGroupEntryVerification;
  final Value<bool> enableScreenCaptureProhibited;
  final Value<bool> hideNotification;
  final Value<bool> muteGroupMember;
  final Value<bool> enableGroupMemberInvisibility;
  final Value<bool> restrictSendingNameCard;
  final Value<bool> forbidSendingPictures;
  final Value<bool> forbidSendingVideos;
  final Value<bool> forbidSendingFiles;
  final Value<bool> enableVisibilityOfGroupMemberList;
  final Value<bool> enableModifyName;
  final Value<bool> enableAddNewMember;
  final Value<bool> enableReminderManagement;
  final Value<int> rowid;
  const ConversationSettingsCompanion({
    this.conversationId = const Value.absent(),
    this.canEditGroupName = const Value.absent(),
    this.canChangeGroupProfilePhoto = const Value.absent(),
    this.canPostGroupAnnouncement = const Value.absent(),
    this.enableGroupEntryVerification = const Value.absent(),
    this.enableScreenCaptureProhibited = const Value.absent(),
    this.hideNotification = const Value.absent(),
    this.muteGroupMember = const Value.absent(),
    this.enableGroupMemberInvisibility = const Value.absent(),
    this.restrictSendingNameCard = const Value.absent(),
    this.forbidSendingPictures = const Value.absent(),
    this.forbidSendingVideos = const Value.absent(),
    this.forbidSendingFiles = const Value.absent(),
    this.enableVisibilityOfGroupMemberList = const Value.absent(),
    this.enableModifyName = const Value.absent(),
    this.enableAddNewMember = const Value.absent(),
    this.enableReminderManagement = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationSettingsCompanion.insert({
    required String conversationId,
    this.canEditGroupName = const Value.absent(),
    this.canChangeGroupProfilePhoto = const Value.absent(),
    this.canPostGroupAnnouncement = const Value.absent(),
    this.enableGroupEntryVerification = const Value.absent(),
    this.enableScreenCaptureProhibited = const Value.absent(),
    this.hideNotification = const Value.absent(),
    this.muteGroupMember = const Value.absent(),
    this.enableGroupMemberInvisibility = const Value.absent(),
    this.restrictSendingNameCard = const Value.absent(),
    this.forbidSendingPictures = const Value.absent(),
    this.forbidSendingVideos = const Value.absent(),
    this.forbidSendingFiles = const Value.absent(),
    this.enableVisibilityOfGroupMemberList = const Value.absent(),
    this.enableModifyName = const Value.absent(),
    this.enableAddNewMember = const Value.absent(),
    this.enableReminderManagement = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : conversationId = Value(conversationId);
  static Insertable<ConversationSetting> custom({
    Expression<String>? conversationId,
    Expression<bool>? canEditGroupName,
    Expression<bool>? canChangeGroupProfilePhoto,
    Expression<bool>? canPostGroupAnnouncement,
    Expression<bool>? enableGroupEntryVerification,
    Expression<bool>? enableScreenCaptureProhibited,
    Expression<bool>? hideNotification,
    Expression<bool>? muteGroupMember,
    Expression<bool>? enableGroupMemberInvisibility,
    Expression<bool>? restrictSendingNameCard,
    Expression<bool>? forbidSendingPictures,
    Expression<bool>? forbidSendingVideos,
    Expression<bool>? forbidSendingFiles,
    Expression<bool>? enableVisibilityOfGroupMemberList,
    Expression<bool>? enableModifyName,
    Expression<bool>? enableAddNewMember,
    Expression<bool>? enableReminderManagement,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (conversationId != null) 'conversation_id': conversationId,
      if (canEditGroupName != null) 'can_edit_group_name': canEditGroupName,
      if (canChangeGroupProfilePhoto != null)
        'can_change_group_profile_photo': canChangeGroupProfilePhoto,
      if (canPostGroupAnnouncement != null)
        'can_post_group_announcement': canPostGroupAnnouncement,
      if (enableGroupEntryVerification != null)
        'enable_group_entry_verification': enableGroupEntryVerification,
      if (enableScreenCaptureProhibited != null)
        'enable_screen_capture_prohibited': enableScreenCaptureProhibited,
      if (hideNotification != null) 'hide_notification': hideNotification,
      if (muteGroupMember != null) 'mute_group_member': muteGroupMember,
      if (enableGroupMemberInvisibility != null)
        'enable_group_member_invisibility': enableGroupMemberInvisibility,
      if (restrictSendingNameCard != null)
        'restrict_sending_name_card': restrictSendingNameCard,
      if (forbidSendingPictures != null)
        'forbid_sending_pictures': forbidSendingPictures,
      if (forbidSendingVideos != null)
        'forbid_sending_videos': forbidSendingVideos,
      if (forbidSendingFiles != null)
        'forbid_sending_files': forbidSendingFiles,
      if (enableVisibilityOfGroupMemberList != null)
        'enable_visibility_of_group_member_list':
            enableVisibilityOfGroupMemberList,
      if (enableModifyName != null) 'enable_modify_name': enableModifyName,
      if (enableAddNewMember != null)
        'enable_add_new_member': enableAddNewMember,
      if (enableReminderManagement != null)
        'enable_reminder_management': enableReminderManagement,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationSettingsCompanion copyWith(
      {Value<String>? conversationId,
      Value<bool>? canEditGroupName,
      Value<bool>? canChangeGroupProfilePhoto,
      Value<bool>? canPostGroupAnnouncement,
      Value<bool>? enableGroupEntryVerification,
      Value<bool>? enableScreenCaptureProhibited,
      Value<bool>? hideNotification,
      Value<bool>? muteGroupMember,
      Value<bool>? enableGroupMemberInvisibility,
      Value<bool>? restrictSendingNameCard,
      Value<bool>? forbidSendingPictures,
      Value<bool>? forbidSendingVideos,
      Value<bool>? forbidSendingFiles,
      Value<bool>? enableVisibilityOfGroupMemberList,
      Value<bool>? enableModifyName,
      Value<bool>? enableAddNewMember,
      Value<bool>? enableReminderManagement,
      Value<int>? rowid}) {
    return ConversationSettingsCompanion(
      conversationId: conversationId ?? this.conversationId,
      canEditGroupName: canEditGroupName ?? this.canEditGroupName,
      canChangeGroupProfilePhoto:
          canChangeGroupProfilePhoto ?? this.canChangeGroupProfilePhoto,
      canPostGroupAnnouncement:
          canPostGroupAnnouncement ?? this.canPostGroupAnnouncement,
      enableGroupEntryVerification:
          enableGroupEntryVerification ?? this.enableGroupEntryVerification,
      enableScreenCaptureProhibited:
          enableScreenCaptureProhibited ?? this.enableScreenCaptureProhibited,
      hideNotification: hideNotification ?? this.hideNotification,
      muteGroupMember: muteGroupMember ?? this.muteGroupMember,
      enableGroupMemberInvisibility:
          enableGroupMemberInvisibility ?? this.enableGroupMemberInvisibility,
      restrictSendingNameCard:
          restrictSendingNameCard ?? this.restrictSendingNameCard,
      forbidSendingPictures:
          forbidSendingPictures ?? this.forbidSendingPictures,
      forbidSendingVideos: forbidSendingVideos ?? this.forbidSendingVideos,
      forbidSendingFiles: forbidSendingFiles ?? this.forbidSendingFiles,
      enableVisibilityOfGroupMemberList: enableVisibilityOfGroupMemberList ??
          this.enableVisibilityOfGroupMemberList,
      enableModifyName: enableModifyName ?? this.enableModifyName,
      enableAddNewMember: enableAddNewMember ?? this.enableAddNewMember,
      enableReminderManagement:
          enableReminderManagement ?? this.enableReminderManagement,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (canEditGroupName.present) {
      map['can_edit_group_name'] = Variable<bool>(canEditGroupName.value);
    }
    if (canChangeGroupProfilePhoto.present) {
      map['can_change_group_profile_photo'] =
          Variable<bool>(canChangeGroupProfilePhoto.value);
    }
    if (canPostGroupAnnouncement.present) {
      map['can_post_group_announcement'] =
          Variable<bool>(canPostGroupAnnouncement.value);
    }
    if (enableGroupEntryVerification.present) {
      map['enable_group_entry_verification'] =
          Variable<bool>(enableGroupEntryVerification.value);
    }
    if (enableScreenCaptureProhibited.present) {
      map['enable_screen_capture_prohibited'] =
          Variable<bool>(enableScreenCaptureProhibited.value);
    }
    if (hideNotification.present) {
      map['hide_notification'] = Variable<bool>(hideNotification.value);
    }
    if (muteGroupMember.present) {
      map['mute_group_member'] = Variable<bool>(muteGroupMember.value);
    }
    if (enableGroupMemberInvisibility.present) {
      map['enable_group_member_invisibility'] =
          Variable<bool>(enableGroupMemberInvisibility.value);
    }
    if (restrictSendingNameCard.present) {
      map['restrict_sending_name_card'] =
          Variable<bool>(restrictSendingNameCard.value);
    }
    if (forbidSendingPictures.present) {
      map['forbid_sending_pictures'] =
          Variable<bool>(forbidSendingPictures.value);
    }
    if (forbidSendingVideos.present) {
      map['forbid_sending_videos'] = Variable<bool>(forbidSendingVideos.value);
    }
    if (forbidSendingFiles.present) {
      map['forbid_sending_files'] = Variable<bool>(forbidSendingFiles.value);
    }
    if (enableVisibilityOfGroupMemberList.present) {
      map['enable_visibility_of_group_member_list'] =
          Variable<bool>(enableVisibilityOfGroupMemberList.value);
    }
    if (enableModifyName.present) {
      map['enable_modify_name'] = Variable<bool>(enableModifyName.value);
    }
    if (enableAddNewMember.present) {
      map['enable_add_new_member'] = Variable<bool>(enableAddNewMember.value);
    }
    if (enableReminderManagement.present) {
      map['enable_reminder_management'] =
          Variable<bool>(enableReminderManagement.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationSettingsCompanion(')
          ..write('conversationId: $conversationId, ')
          ..write('canEditGroupName: $canEditGroupName, ')
          ..write('canChangeGroupProfilePhoto: $canChangeGroupProfilePhoto, ')
          ..write('canPostGroupAnnouncement: $canPostGroupAnnouncement, ')
          ..write(
              'enableGroupEntryVerification: $enableGroupEntryVerification, ')
          ..write(
              'enableScreenCaptureProhibited: $enableScreenCaptureProhibited, ')
          ..write('hideNotification: $hideNotification, ')
          ..write('muteGroupMember: $muteGroupMember, ')
          ..write(
              'enableGroupMemberInvisibility: $enableGroupMemberInvisibility, ')
          ..write('restrictSendingNameCard: $restrictSendingNameCard, ')
          ..write('forbidSendingPictures: $forbidSendingPictures, ')
          ..write('forbidSendingVideos: $forbidSendingVideos, ')
          ..write('forbidSendingFiles: $forbidSendingFiles, ')
          ..write(
              'enableVisibilityOfGroupMemberList: $enableVisibilityOfGroupMemberList, ')
          ..write('enableModifyName: $enableModifyName, ')
          ..write('enableAddNewMember: $enableAddNewMember, ')
          ..write('enableReminderManagement: $enableReminderManagement, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContactsTable extends Contacts with TableInfo<$ContactsTable, Contact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContactsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _introMeta = const VerificationMeta('intro');
  @override
  late final GeneratedColumn<String> intro = GeneratedColumn<String>(
      'intro', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _profilePictureMeta =
      const VerificationMeta('profilePicture');
  @override
  late final GeneratedColumn<String> profilePicture = GeneratedColumn<String>(
      'profile_picture', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _profileAccessStrategyMeta =
      const VerificationMeta('profileAccessStrategy');
  @override
  late final GeneratedColumn<String> profileAccessStrategy =
      GeneratedColumn<String>('profile_access_strategy', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _registrationDateMeta =
      const VerificationMeta('registrationDate');
  @override
  late final GeneratedColumn<DateTime> registrationDate =
      GeneratedColumn<DateTime>('registration_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _lastUpdatedDateMeta =
      const VerificationMeta('lastUpdatedDate');
  @override
  late final GeneratedColumn<DateTime> lastUpdatedDate =
      GeneratedColumn<DateTime>('last_updated_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _userDefinedAttributesMeta =
      const VerificationMeta('userDefinedAttributes');
  @override
  late final GeneratedColumn<String> userDefinedAttributes =
      GeneratedColumn<String>('user_defined_attributes', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        intro,
        profilePicture,
        profileAccessStrategy,
        registrationDate,
        lastUpdatedDate,
        active,
        userDefinedAttributes
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'contacts';
  @override
  VerificationContext validateIntegrity(Insertable<Contact> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('intro')) {
      context.handle(
          _introMeta, intro.isAcceptableOrUnknown(data['intro']!, _introMeta));
    }
    if (data.containsKey('profile_picture')) {
      context.handle(
          _profilePictureMeta,
          profilePicture.isAcceptableOrUnknown(
              data['profile_picture']!, _profilePictureMeta));
    }
    if (data.containsKey('profile_access_strategy')) {
      context.handle(
          _profileAccessStrategyMeta,
          profileAccessStrategy.isAcceptableOrUnknown(
              data['profile_access_strategy']!, _profileAccessStrategyMeta));
    }
    if (data.containsKey('registration_date')) {
      context.handle(
          _registrationDateMeta,
          registrationDate.isAcceptableOrUnknown(
              data['registration_date']!, _registrationDateMeta));
    }
    if (data.containsKey('last_updated_date')) {
      context.handle(
          _lastUpdatedDateMeta,
          lastUpdatedDate.isAcceptableOrUnknown(
              data['last_updated_date']!, _lastUpdatedDateMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    if (data.containsKey('user_defined_attributes')) {
      context.handle(
          _userDefinedAttributesMeta,
          userDefinedAttributes.isAcceptableOrUnknown(
              data['user_defined_attributes']!, _userDefinedAttributesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Contact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Contact(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      intro: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}intro']),
      profilePicture: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_picture']),
      profileAccessStrategy: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}profile_access_strategy']),
      registrationDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}registration_date']),
      lastUpdatedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_updated_date']),
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
      userDefinedAttributes: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}user_defined_attributes']),
    );
  }

  @override
  $ContactsTable createAlias(String alias) {
    return $ContactsTable(attachedDatabase, alias);
  }
}

class Contact extends DataClass implements Insertable<Contact> {
  final String id;
  final String name;
  final String? intro;
  final String? profilePicture;
  final String? profileAccessStrategy;
  final DateTime? registrationDate;
  final DateTime? lastUpdatedDate;
  final bool active;
  final String? userDefinedAttributes;
  const Contact(
      {required this.id,
      required this.name,
      this.intro,
      this.profilePicture,
      this.profileAccessStrategy,
      this.registrationDate,
      this.lastUpdatedDate,
      required this.active,
      this.userDefinedAttributes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || intro != null) {
      map['intro'] = Variable<String>(intro);
    }
    if (!nullToAbsent || profilePicture != null) {
      map['profile_picture'] = Variable<String>(profilePicture);
    }
    if (!nullToAbsent || profileAccessStrategy != null) {
      map['profile_access_strategy'] = Variable<String>(profileAccessStrategy);
    }
    if (!nullToAbsent || registrationDate != null) {
      map['registration_date'] = Variable<DateTime>(registrationDate);
    }
    if (!nullToAbsent || lastUpdatedDate != null) {
      map['last_updated_date'] = Variable<DateTime>(lastUpdatedDate);
    }
    map['active'] = Variable<bool>(active);
    if (!nullToAbsent || userDefinedAttributes != null) {
      map['user_defined_attributes'] = Variable<String>(userDefinedAttributes);
    }
    return map;
  }

  ContactsCompanion toCompanion(bool nullToAbsent) {
    return ContactsCompanion(
      id: Value(id),
      name: Value(name),
      intro:
          intro == null && nullToAbsent ? const Value.absent() : Value(intro),
      profilePicture: profilePicture == null && nullToAbsent
          ? const Value.absent()
          : Value(profilePicture),
      profileAccessStrategy: profileAccessStrategy == null && nullToAbsent
          ? const Value.absent()
          : Value(profileAccessStrategy),
      registrationDate: registrationDate == null && nullToAbsent
          ? const Value.absent()
          : Value(registrationDate),
      lastUpdatedDate: lastUpdatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastUpdatedDate),
      active: Value(active),
      userDefinedAttributes: userDefinedAttributes == null && nullToAbsent
          ? const Value.absent()
          : Value(userDefinedAttributes),
    );
  }

  factory Contact.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Contact(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      intro: serializer.fromJson<String?>(json['intro']),
      profilePicture: serializer.fromJson<String?>(json['profilePicture']),
      profileAccessStrategy:
          serializer.fromJson<String?>(json['profileAccessStrategy']),
      registrationDate:
          serializer.fromJson<DateTime?>(json['registrationDate']),
      lastUpdatedDate: serializer.fromJson<DateTime?>(json['lastUpdatedDate']),
      active: serializer.fromJson<bool>(json['active']),
      userDefinedAttributes:
          serializer.fromJson<String?>(json['userDefinedAttributes']),
    );
  }
  factory Contact.fromJsonString(String encodedJson,
          {ValueSerializer? serializer}) =>
      Contact.fromJson(DataClass.parseJson(encodedJson) as Map<String, dynamic>,
          serializer: serializer);
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'intro': serializer.toJson<String?>(intro),
      'profilePicture': serializer.toJson<String?>(profilePicture),
      'profileAccessStrategy':
          serializer.toJson<String?>(profileAccessStrategy),
      'registrationDate': serializer.toJson<DateTime?>(registrationDate),
      'lastUpdatedDate': serializer.toJson<DateTime?>(lastUpdatedDate),
      'active': serializer.toJson<bool>(active),
      'userDefinedAttributes':
          serializer.toJson<String?>(userDefinedAttributes),
    };
  }

  Contact copyWith(
          {String? id,
          String? name,
          Value<String?> intro = const Value.absent(),
          Value<String?> profilePicture = const Value.absent(),
          Value<String?> profileAccessStrategy = const Value.absent(),
          Value<DateTime?> registrationDate = const Value.absent(),
          Value<DateTime?> lastUpdatedDate = const Value.absent(),
          bool? active,
          Value<String?> userDefinedAttributes = const Value.absent()}) =>
      Contact(
        id: id ?? this.id,
        name: name ?? this.name,
        intro: intro.present ? intro.value : this.intro,
        profilePicture:
            profilePicture.present ? profilePicture.value : this.profilePicture,
        profileAccessStrategy: profileAccessStrategy.present
            ? profileAccessStrategy.value
            : this.profileAccessStrategy,
        registrationDate: registrationDate.present
            ? registrationDate.value
            : this.registrationDate,
        lastUpdatedDate: lastUpdatedDate.present
            ? lastUpdatedDate.value
            : this.lastUpdatedDate,
        active: active ?? this.active,
        userDefinedAttributes: userDefinedAttributes.present
            ? userDefinedAttributes.value
            : this.userDefinedAttributes,
      );
  Contact copyWithCompanion(ContactsCompanion data) {
    return Contact(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      intro: data.intro.present ? data.intro.value : this.intro,
      profilePicture: data.profilePicture.present
          ? data.profilePicture.value
          : this.profilePicture,
      profileAccessStrategy: data.profileAccessStrategy.present
          ? data.profileAccessStrategy.value
          : this.profileAccessStrategy,
      registrationDate: data.registrationDate.present
          ? data.registrationDate.value
          : this.registrationDate,
      lastUpdatedDate: data.lastUpdatedDate.present
          ? data.lastUpdatedDate.value
          : this.lastUpdatedDate,
      active: data.active.present ? data.active.value : this.active,
      userDefinedAttributes: data.userDefinedAttributes.present
          ? data.userDefinedAttributes.value
          : this.userDefinedAttributes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Contact(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('intro: $intro, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('profileAccessStrategy: $profileAccessStrategy, ')
          ..write('registrationDate: $registrationDate, ')
          ..write('lastUpdatedDate: $lastUpdatedDate, ')
          ..write('active: $active, ')
          ..write('userDefinedAttributes: $userDefinedAttributes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      intro,
      profilePicture,
      profileAccessStrategy,
      registrationDate,
      lastUpdatedDate,
      active,
      userDefinedAttributes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Contact &&
          other.id == this.id &&
          other.name == this.name &&
          other.intro == this.intro &&
          other.profilePicture == this.profilePicture &&
          other.profileAccessStrategy == this.profileAccessStrategy &&
          other.registrationDate == this.registrationDate &&
          other.lastUpdatedDate == this.lastUpdatedDate &&
          other.active == this.active &&
          other.userDefinedAttributes == this.userDefinedAttributes);
}

class ContactsCompanion extends UpdateCompanion<Contact> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> intro;
  final Value<String?> profilePicture;
  final Value<String?> profileAccessStrategy;
  final Value<DateTime?> registrationDate;
  final Value<DateTime?> lastUpdatedDate;
  final Value<bool> active;
  final Value<String?> userDefinedAttributes;
  final Value<int> rowid;
  const ContactsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.intro = const Value.absent(),
    this.profilePicture = const Value.absent(),
    this.profileAccessStrategy = const Value.absent(),
    this.registrationDate = const Value.absent(),
    this.lastUpdatedDate = const Value.absent(),
    this.active = const Value.absent(),
    this.userDefinedAttributes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContactsCompanion.insert({
    required String id,
    required String name,
    this.intro = const Value.absent(),
    this.profilePicture = const Value.absent(),
    this.profileAccessStrategy = const Value.absent(),
    this.registrationDate = const Value.absent(),
    this.lastUpdatedDate = const Value.absent(),
    this.active = const Value.absent(),
    this.userDefinedAttributes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<Contact> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? intro,
    Expression<String>? profilePicture,
    Expression<String>? profileAccessStrategy,
    Expression<DateTime>? registrationDate,
    Expression<DateTime>? lastUpdatedDate,
    Expression<bool>? active,
    Expression<String>? userDefinedAttributes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (intro != null) 'intro': intro,
      if (profilePicture != null) 'profile_picture': profilePicture,
      if (profileAccessStrategy != null)
        'profile_access_strategy': profileAccessStrategy,
      if (registrationDate != null) 'registration_date': registrationDate,
      if (lastUpdatedDate != null) 'last_updated_date': lastUpdatedDate,
      if (active != null) 'active': active,
      if (userDefinedAttributes != null)
        'user_defined_attributes': userDefinedAttributes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContactsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? intro,
      Value<String?>? profilePicture,
      Value<String?>? profileAccessStrategy,
      Value<DateTime?>? registrationDate,
      Value<DateTime?>? lastUpdatedDate,
      Value<bool>? active,
      Value<String?>? userDefinedAttributes,
      Value<int>? rowid}) {
    return ContactsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      intro: intro ?? this.intro,
      profilePicture: profilePicture ?? this.profilePicture,
      profileAccessStrategy:
          profileAccessStrategy ?? this.profileAccessStrategy,
      registrationDate: registrationDate ?? this.registrationDate,
      lastUpdatedDate: lastUpdatedDate ?? this.lastUpdatedDate,
      active: active ?? this.active,
      userDefinedAttributes:
          userDefinedAttributes ?? this.userDefinedAttributes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (intro.present) {
      map['intro'] = Variable<String>(intro.value);
    }
    if (profilePicture.present) {
      map['profile_picture'] = Variable<String>(profilePicture.value);
    }
    if (profileAccessStrategy.present) {
      map['profile_access_strategy'] =
          Variable<String>(profileAccessStrategy.value);
    }
    if (registrationDate.present) {
      map['registration_date'] = Variable<DateTime>(registrationDate.value);
    }
    if (lastUpdatedDate.present) {
      map['last_updated_date'] = Variable<DateTime>(lastUpdatedDate.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    if (userDefinedAttributes.present) {
      map['user_defined_attributes'] =
          Variable<String>(userDefinedAttributes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContactsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('intro: $intro, ')
          ..write('profilePicture: $profilePicture, ')
          ..write('profileAccessStrategy: $profileAccessStrategy, ')
          ..write('registrationDate: $registrationDate, ')
          ..write('lastUpdatedDate: $lastUpdatedDate, ')
          ..write('active: $active, ')
          ..write('userDefinedAttributes: $userDefinedAttributes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StickersTable extends Stickers with TableInfo<$StickersTable, Sticker> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StickersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
      'path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, userId, path];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stickers';
  @override
  VerificationContext validateIntegrity(Insertable<Sticker> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('path')) {
      context.handle(
          _pathMeta, path.isAcceptableOrUnknown(data['path']!, _pathMeta));
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sticker map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sticker(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      path: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}path'])!,
    );
  }

  @override
  $StickersTable createAlias(String alias) {
    return $StickersTable(attachedDatabase, alias);
  }
}

class Sticker extends DataClass implements Insertable<Sticker> {
  final String id;
  final String name;
  final String userId;
  final String path;
  const Sticker(
      {required this.id,
      required this.name,
      required this.userId,
      required this.path});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['user_id'] = Variable<String>(userId);
    map['path'] = Variable<String>(path);
    return map;
  }

  StickersCompanion toCompanion(bool nullToAbsent) {
    return StickersCompanion(
      id: Value(id),
      name: Value(name),
      userId: Value(userId),
      path: Value(path),
    );
  }

  factory Sticker.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sticker(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      userId: serializer.fromJson<String>(json['userId']),
      path: serializer.fromJson<String>(json['path']),
    );
  }
  factory Sticker.fromJsonString(String encodedJson,
          {ValueSerializer? serializer}) =>
      Sticker.fromJson(DataClass.parseJson(encodedJson) as Map<String, dynamic>,
          serializer: serializer);
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'userId': serializer.toJson<String>(userId),
      'path': serializer.toJson<String>(path),
    };
  }

  Sticker copyWith({String? id, String? name, String? userId, String? path}) =>
      Sticker(
        id: id ?? this.id,
        name: name ?? this.name,
        userId: userId ?? this.userId,
        path: path ?? this.path,
      );
  Sticker copyWithCompanion(StickersCompanion data) {
    return Sticker(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      userId: data.userId.present ? data.userId.value : this.userId,
      path: data.path.present ? data.path.value : this.path,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sticker(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('path: $path')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, userId, path);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sticker &&
          other.id == this.id &&
          other.name == this.name &&
          other.userId == this.userId &&
          other.path == this.path);
}

class StickersCompanion extends UpdateCompanion<Sticker> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> userId;
  final Value<String> path;
  final Value<int> rowid;
  const StickersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.userId = const Value.absent(),
    this.path = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StickersCompanion.insert({
    required String id,
    required String name,
    required String userId,
    required String path,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        userId = Value(userId),
        path = Value(path);
  static Insertable<Sticker> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? userId,
    Expression<String>? path,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (userId != null) 'user_id': userId,
      if (path != null) 'path': path,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StickersCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? userId,
      Value<String>? path,
      Value<int>? rowid}) {
    return StickersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      path: path ?? this.path,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StickersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('userId: $userId, ')
          ..write('path: $path, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserRelationshipsTable extends UserRelationships
    with TableInfo<$UserRelationshipsTable, UserRelationship> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserRelationshipsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      additionalChecks:
          GeneratedColumn.checkTextLength(minTextLength: 1, maxTextLength: 255),
      type: DriftSqlType.string,
      requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _relatedUserIdMeta =
      const VerificationMeta('relatedUserId');
  @override
  late final GeneratedColumn<String> relatedUserId = GeneratedColumn<String>(
      'related_user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending'));
  @override
  List<GeneratedColumn> get $columns => [id, userId, relatedUserId, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_relationships';
  @override
  VerificationContext validateIntegrity(Insertable<UserRelationship> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('related_user_id')) {
      context.handle(
          _relatedUserIdMeta,
          relatedUserId.isAcceptableOrUnknown(
              data['related_user_id']!, _relatedUserIdMeta));
    } else if (isInserting) {
      context.missing(_relatedUserIdMeta);
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserRelationship map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserRelationship(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      relatedUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}related_user_id'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $UserRelationshipsTable createAlias(String alias) {
    return $UserRelationshipsTable(attachedDatabase, alias);
  }
}

class UserRelationship extends DataClass
    implements Insertable<UserRelationship> {
  final String id;
  final String userId;
  final String relatedUserId;
  final String status;
  const UserRelationship(
      {required this.id,
      required this.userId,
      required this.relatedUserId,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['related_user_id'] = Variable<String>(relatedUserId);
    map['status'] = Variable<String>(status);
    return map;
  }

  UserRelationshipsCompanion toCompanion(bool nullToAbsent) {
    return UserRelationshipsCompanion(
      id: Value(id),
      userId: Value(userId),
      relatedUserId: Value(relatedUserId),
      status: Value(status),
    );
  }

  factory UserRelationship.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserRelationship(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      relatedUserId: serializer.fromJson<String>(json['relatedUserId']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  factory UserRelationship.fromJsonString(String encodedJson,
          {ValueSerializer? serializer}) =>
      UserRelationship.fromJson(
          DataClass.parseJson(encodedJson) as Map<String, dynamic>,
          serializer: serializer);
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'relatedUserId': serializer.toJson<String>(relatedUserId),
      'status': serializer.toJson<String>(status),
    };
  }

  UserRelationship copyWith(
          {String? id,
          String? userId,
          String? relatedUserId,
          String? status}) =>
      UserRelationship(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        relatedUserId: relatedUserId ?? this.relatedUserId,
        status: status ?? this.status,
      );
  UserRelationship copyWithCompanion(UserRelationshipsCompanion data) {
    return UserRelationship(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      relatedUserId: data.relatedUserId.present
          ? data.relatedUserId.value
          : this.relatedUserId,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserRelationship(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('relatedUserId: $relatedUserId, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, relatedUserId, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserRelationship &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.relatedUserId == this.relatedUserId &&
          other.status == this.status);
}

class UserRelationshipsCompanion extends UpdateCompanion<UserRelationship> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> relatedUserId;
  final Value<String> status;
  final Value<int> rowid;
  const UserRelationshipsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.relatedUserId = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserRelationshipsCompanion.insert({
    required String id,
    required String userId,
    required String relatedUserId,
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        relatedUserId = Value(relatedUserId);
  static Insertable<UserRelationship> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? relatedUserId,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (relatedUserId != null) 'related_user_id': relatedUserId,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserRelationshipsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? relatedUserId,
      Value<String>? status,
      Value<int>? rowid}) {
    return UserRelationshipsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      relatedUserId: relatedUserId ?? this.relatedUserId,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (relatedUserId.present) {
      map['related_user_id'] = Variable<String>(relatedUserId.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserRelationshipsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('relatedUserId: $relatedUserId, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ConversationsTable conversations = $ConversationsTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ConversationSettingsTable conversationSettings =
      $ConversationSettingsTable(this);
  late final $ContactsTable contacts = $ContactsTable(this);
  late final $StickersTable stickers = $StickersTable(this);
  late final $UserRelationshipsTable userRelationships =
      $UserRelationshipsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        conversations,
        messages,
        conversationSettings,
        contacts,
        stickers,
        userRelationships
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('conversations',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('messages', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('conversations',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('conversation_settings', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$ConversationsTableCreateCompanionBuilder = ConversationsCompanion
    Function({
  required String id,
  required String title,
  required String members,
  Value<String?> targetId,
  Value<String?> ownerId,
  Value<DateTime> createdAt,
  Value<bool> isGroup,
  Value<String?> avatar,
  Value<bool> isPinned,
  Value<bool> isMuted,
  Value<String?> extraInfo,
  Value<String?> settings,
  Value<DateTime?> lastMessageDate,
  Value<int> rowid,
});
typedef $$ConversationsTableUpdateCompanionBuilder = ConversationsCompanion
    Function({
  Value<String> id,
  Value<String> title,
  Value<String> members,
  Value<String?> targetId,
  Value<String?> ownerId,
  Value<DateTime> createdAt,
  Value<bool> isGroup,
  Value<String?> avatar,
  Value<bool> isPinned,
  Value<bool> isMuted,
  Value<String?> extraInfo,
  Value<String?> settings,
  Value<DateTime?> lastMessageDate,
  Value<int> rowid,
});

final class $$ConversationsTableReferences
    extends BaseReferences<_$AppDatabase, $ConversationsTable, Conversation> {
  $$ConversationsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.messages,
          aliasName: $_aliasNameGenerator(
              db.conversations.id, db.messages.conversationId));

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager($_db, $_db.messages)
        .filter((f) => f.conversationId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ConversationSettingsTable,
      List<ConversationSetting>> _conversationSettingsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.conversationSettings,
          aliasName: $_aliasNameGenerator(
              db.conversations.id, db.conversationSettings.conversationId));

  $$ConversationSettingsTableProcessedTableManager
      get conversationSettingsRefs {
    final manager =
        $$ConversationSettingsTableTableManager($_db, $_db.conversationSettings)
            .filter((f) => f.conversationId.id($_item.id));

    final cache =
        $_typedResult.readTableOrNull(_conversationSettingsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ConversationsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get members => $composableBuilder(
      column: $table.members, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGroup => $composableBuilder(
      column: $table.isGroup, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMuted => $composableBuilder(
      column: $table.isMuted, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extraInfo => $composableBuilder(
      column: $table.extraInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastMessageDate => $composableBuilder(
      column: $table.lastMessageDate,
      builder: (column) => ColumnFilters(column));

  Expression<bool> messagesRefs(
      Expression<bool> Function($$MessagesTableFilterComposer f) f) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableFilterComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> conversationSettingsRefs(
      Expression<bool> Function($$ConversationSettingsTableFilterComposer f)
          f) {
    final $$ConversationSettingsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.conversationSettings,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationSettingsTableFilterComposer(
              $db: $db,
              $table: $db.conversationSettings,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ConversationsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get members => $composableBuilder(
      column: $table.members, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get targetId => $composableBuilder(
      column: $table.targetId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ownerId => $composableBuilder(
      column: $table.ownerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGroup => $composableBuilder(
      column: $table.isGroup, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatar => $composableBuilder(
      column: $table.avatar, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMuted => $composableBuilder(
      column: $table.isMuted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extraInfo => $composableBuilder(
      column: $table.extraInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settings => $composableBuilder(
      column: $table.settings, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastMessageDate => $composableBuilder(
      column: $table.lastMessageDate,
      builder: (column) => ColumnOrderings(column));
}

class $$ConversationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationsTable> {
  $$ConversationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get members =>
      $composableBuilder(column: $table.members, builder: (column) => column);

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<bool> get isGroup =>
      $composableBuilder(column: $table.isGroup, builder: (column) => column);

  GeneratedColumn<String> get avatar =>
      $composableBuilder(column: $table.avatar, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isMuted =>
      $composableBuilder(column: $table.isMuted, builder: (column) => column);

  GeneratedColumn<String> get extraInfo =>
      $composableBuilder(column: $table.extraInfo, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);

  GeneratedColumn<DateTime> get lastMessageDate => $composableBuilder(
      column: $table.lastMessageDate, builder: (column) => column);

  Expression<T> messagesRefs<T extends Object>(
      Expression<T> Function($$MessagesTableAnnotationComposer a) f) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.messages,
        getReferencedColumn: (t) => t.conversationId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MessagesTableAnnotationComposer(
              $db: $db,
              $table: $db.messages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> conversationSettingsRefs<T extends Object>(
      Expression<T> Function($$ConversationSettingsTableAnnotationComposer a)
          f) {
    final $$ConversationSettingsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.conversationSettings,
            getReferencedColumn: (t) => t.conversationId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ConversationSettingsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.conversationSettings,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ConversationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (Conversation, $$ConversationsTableReferences),
    Conversation,
    PrefetchHooks Function(
        {bool messagesRefs, bool conversationSettingsRefs})> {
  $$ConversationsTableTableManager(_$AppDatabase db, $ConversationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> members = const Value.absent(),
            Value<String?> targetId = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isGroup = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isMuted = const Value.absent(),
            Value<String?> extraInfo = const Value.absent(),
            Value<String?> settings = const Value.absent(),
            Value<DateTime?> lastMessageDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion(
            id: id,
            title: title,
            members: members,
            targetId: targetId,
            ownerId: ownerId,
            createdAt: createdAt,
            isGroup: isGroup,
            avatar: avatar,
            isPinned: isPinned,
            isMuted: isMuted,
            extraInfo: extraInfo,
            settings: settings,
            lastMessageDate: lastMessageDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String members,
            Value<String?> targetId = const Value.absent(),
            Value<String?> ownerId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<bool> isGroup = const Value.absent(),
            Value<String?> avatar = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isMuted = const Value.absent(),
            Value<String?> extraInfo = const Value.absent(),
            Value<String?> settings = const Value.absent(),
            Value<DateTime?> lastMessageDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationsCompanion.insert(
            id: id,
            title: title,
            members: members,
            targetId: targetId,
            ownerId: ownerId,
            createdAt: createdAt,
            isGroup: isGroup,
            avatar: avatar,
            isPinned: isPinned,
            isMuted: isMuted,
            extraInfo: extraInfo,
            settings: settings,
            lastMessageDate: lastMessageDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConversationsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {messagesRefs = false, conversationSettingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (messagesRefs) db.messages,
                if (conversationSettingsRefs) db.conversationSettings
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (messagesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ConversationsTableReferences
                            ._messagesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConversationsTableReferences(db, table, p0)
                                .messagesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.conversationId == item.id),
                        typedResults: items),
                  if (conversationSettingsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable: $$ConversationsTableReferences
                            ._conversationSettingsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ConversationsTableReferences(db, table, p0)
                                .conversationSettingsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.conversationId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ConversationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ConversationsTable,
    Conversation,
    $$ConversationsTableFilterComposer,
    $$ConversationsTableOrderingComposer,
    $$ConversationsTableAnnotationComposer,
    $$ConversationsTableCreateCompanionBuilder,
    $$ConversationsTableUpdateCompanionBuilder,
    (Conversation, $$ConversationsTableReferences),
    Conversation,
    PrefetchHooks Function({bool messagesRefs, bool conversationSettingsRefs})>;
typedef $$MessagesTableCreateCompanionBuilder = MessagesCompanion Function({
  Value<int> messageId,
  Value<String?> id,
  required String conversationId,
  required String content,
  Value<String?> attachment,
  Value<DateTime> sentAt,
  required String receiverId,
  required String senderId,
  required String parentMessageId,
  Value<String?> parentMessage,
  Value<bool> isRead,
  required String type,
  Value<String?> url,
  Value<bool> isPinned,
  Value<bool> isFavourite,
  Value<String?> extraInfo,
  Value<int> status,
});
typedef $$MessagesTableUpdateCompanionBuilder = MessagesCompanion Function({
  Value<int> messageId,
  Value<String?> id,
  Value<String> conversationId,
  Value<String> content,
  Value<String?> attachment,
  Value<DateTime> sentAt,
  Value<String> receiverId,
  Value<String> senderId,
  Value<String> parentMessageId,
  Value<String?> parentMessage,
  Value<bool> isRead,
  Value<String> type,
  Value<String?> url,
  Value<bool> isPinned,
  Value<bool> isFavourite,
  Value<String?> extraInfo,
  Value<int> status,
});

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias($_aliasNameGenerator(
          db.messages.conversationId, db.conversations.id));

  $$ConversationsTableProcessedTableManager get conversationId {
    final manager = $$ConversationsTableTableManager($_db, $_db.conversations)
        .filter((f) => f.id($_item.conversationId));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get attachment => $composableBuilder(
      column: $table.attachment, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentMessageId => $composableBuilder(
      column: $table.parentMessageId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentMessage => $composableBuilder(
      column: $table.parentMessage, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavourite => $composableBuilder(
      column: $table.isFavourite, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get extraInfo => $composableBuilder(
      column: $table.extraInfo, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableFilterComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get messageId => $composableBuilder(
      column: $table.messageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get attachment => $composableBuilder(
      column: $table.attachment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
      column: $table.sentAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get senderId => $composableBuilder(
      column: $table.senderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentMessageId => $composableBuilder(
      column: $table.parentMessageId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentMessage => $composableBuilder(
      column: $table.parentMessage,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
      column: $table.isFavourite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get extraInfo => $composableBuilder(
      column: $table.extraInfo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableOrderingComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get attachment => $composableBuilder(
      column: $table.attachment, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<String> get receiverId => $composableBuilder(
      column: $table.receiverId, builder: (column) => column);

  GeneratedColumn<String> get senderId =>
      $composableBuilder(column: $table.senderId, builder: (column) => column);

  GeneratedColumn<String> get parentMessageId => $composableBuilder(
      column: $table.parentMessageId, builder: (column) => column);

  GeneratedColumn<String> get parentMessage => $composableBuilder(
      column: $table.parentMessage, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
      column: $table.isFavourite, builder: (column) => column);

  GeneratedColumn<String> get extraInfo =>
      $composableBuilder(column: $table.extraInfo, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableAnnotationComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool conversationId})> {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> messageId = const Value.absent(),
            Value<String?> id = const Value.absent(),
            Value<String> conversationId = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> attachment = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            Value<String> receiverId = const Value.absent(),
            Value<String> senderId = const Value.absent(),
            Value<String> parentMessageId = const Value.absent(),
            Value<String?> parentMessage = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> url = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isFavourite = const Value.absent(),
            Value<String?> extraInfo = const Value.absent(),
            Value<int> status = const Value.absent(),
          }) =>
              MessagesCompanion(
            messageId: messageId,
            id: id,
            conversationId: conversationId,
            content: content,
            attachment: attachment,
            sentAt: sentAt,
            receiverId: receiverId,
            senderId: senderId,
            parentMessageId: parentMessageId,
            parentMessage: parentMessage,
            isRead: isRead,
            type: type,
            url: url,
            isPinned: isPinned,
            isFavourite: isFavourite,
            extraInfo: extraInfo,
            status: status,
          ),
          createCompanionCallback: ({
            Value<int> messageId = const Value.absent(),
            Value<String?> id = const Value.absent(),
            required String conversationId,
            required String content,
            Value<String?> attachment = const Value.absent(),
            Value<DateTime> sentAt = const Value.absent(),
            required String receiverId,
            required String senderId,
            required String parentMessageId,
            Value<String?> parentMessage = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            required String type,
            Value<String?> url = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<bool> isFavourite = const Value.absent(),
            Value<String?> extraInfo = const Value.absent(),
            Value<int> status = const Value.absent(),
          }) =>
              MessagesCompanion.insert(
            messageId: messageId,
            id: id,
            conversationId: conversationId,
            content: content,
            attachment: attachment,
            sentAt: sentAt,
            receiverId: receiverId,
            senderId: senderId,
            parentMessageId: parentMessageId,
            parentMessage: parentMessage,
            isRead: isRead,
            type: type,
            url: url,
            isPinned: isPinned,
            isFavourite: isFavourite,
            extraInfo: extraInfo,
            status: status,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$MessagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
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
                if (conversationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.conversationId,
                    referencedTable:
                        $$MessagesTableReferences._conversationIdTable(db),
                    referencedColumn:
                        $$MessagesTableReferences._conversationIdTable(db).id,
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

typedef $$MessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MessagesTable,
    Message,
    $$MessagesTableFilterComposer,
    $$MessagesTableOrderingComposer,
    $$MessagesTableAnnotationComposer,
    $$MessagesTableCreateCompanionBuilder,
    $$MessagesTableUpdateCompanionBuilder,
    (Message, $$MessagesTableReferences),
    Message,
    PrefetchHooks Function({bool conversationId})>;
typedef $$ConversationSettingsTableCreateCompanionBuilder
    = ConversationSettingsCompanion Function({
  required String conversationId,
  Value<bool> canEditGroupName,
  Value<bool> canChangeGroupProfilePhoto,
  Value<bool> canPostGroupAnnouncement,
  Value<bool> enableGroupEntryVerification,
  Value<bool> enableScreenCaptureProhibited,
  Value<bool> hideNotification,
  Value<bool> muteGroupMember,
  Value<bool> enableGroupMemberInvisibility,
  Value<bool> restrictSendingNameCard,
  Value<bool> forbidSendingPictures,
  Value<bool> forbidSendingVideos,
  Value<bool> forbidSendingFiles,
  Value<bool> enableVisibilityOfGroupMemberList,
  Value<bool> enableModifyName,
  Value<bool> enableAddNewMember,
  Value<bool> enableReminderManagement,
  Value<int> rowid,
});
typedef $$ConversationSettingsTableUpdateCompanionBuilder
    = ConversationSettingsCompanion Function({
  Value<String> conversationId,
  Value<bool> canEditGroupName,
  Value<bool> canChangeGroupProfilePhoto,
  Value<bool> canPostGroupAnnouncement,
  Value<bool> enableGroupEntryVerification,
  Value<bool> enableScreenCaptureProhibited,
  Value<bool> hideNotification,
  Value<bool> muteGroupMember,
  Value<bool> enableGroupMemberInvisibility,
  Value<bool> restrictSendingNameCard,
  Value<bool> forbidSendingPictures,
  Value<bool> forbidSendingVideos,
  Value<bool> forbidSendingFiles,
  Value<bool> enableVisibilityOfGroupMemberList,
  Value<bool> enableModifyName,
  Value<bool> enableAddNewMember,
  Value<bool> enableReminderManagement,
  Value<int> rowid,
});

final class $$ConversationSettingsTableReferences extends BaseReferences<
    _$AppDatabase, $ConversationSettingsTable, ConversationSetting> {
  $$ConversationSettingsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ConversationsTable _conversationIdTable(_$AppDatabase db) =>
      db.conversations.createAlias($_aliasNameGenerator(
          db.conversationSettings.conversationId, db.conversations.id));

  $$ConversationsTableProcessedTableManager get conversationId {
    final manager = $$ConversationsTableTableManager($_db, $_db.conversations)
        .filter((f) => f.id($_item.conversationId));
    final item = $_typedResult.readTableOrNull(_conversationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ConversationSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ConversationSettingsTable> {
  $$ConversationSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get canEditGroupName => $composableBuilder(
      column: $table.canEditGroupName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canChangeGroupProfilePhoto => $composableBuilder(
      column: $table.canChangeGroupProfilePhoto,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get canPostGroupAnnouncement => $composableBuilder(
      column: $table.canPostGroupAnnouncement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableGroupEntryVerification => $composableBuilder(
      column: $table.enableGroupEntryVerification,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableScreenCaptureProhibited => $composableBuilder(
      column: $table.enableScreenCaptureProhibited,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hideNotification => $composableBuilder(
      column: $table.hideNotification,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get muteGroupMember => $composableBuilder(
      column: $table.muteGroupMember,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableGroupMemberInvisibility => $composableBuilder(
      column: $table.enableGroupMemberInvisibility,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get restrictSendingNameCard => $composableBuilder(
      column: $table.restrictSendingNameCard,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get forbidSendingPictures => $composableBuilder(
      column: $table.forbidSendingPictures,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get forbidSendingVideos => $composableBuilder(
      column: $table.forbidSendingVideos,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get forbidSendingFiles => $composableBuilder(
      column: $table.forbidSendingFiles,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableVisibilityOfGroupMemberList =>
      $composableBuilder(
          column: $table.enableVisibilityOfGroupMemberList,
          builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableModifyName => $composableBuilder(
      column: $table.enableModifyName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableAddNewMember => $composableBuilder(
      column: $table.enableAddNewMember,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enableReminderManagement => $composableBuilder(
      column: $table.enableReminderManagement,
      builder: (column) => ColumnFilters(column));

  $$ConversationsTableFilterComposer get conversationId {
    final $$ConversationsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableFilterComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConversationSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConversationSettingsTable> {
  $$ConversationSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get canEditGroupName => $composableBuilder(
      column: $table.canEditGroupName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canChangeGroupProfilePhoto => $composableBuilder(
      column: $table.canChangeGroupProfilePhoto,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get canPostGroupAnnouncement => $composableBuilder(
      column: $table.canPostGroupAnnouncement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableGroupEntryVerification => $composableBuilder(
      column: $table.enableGroupEntryVerification,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableScreenCaptureProhibited => $composableBuilder(
      column: $table.enableScreenCaptureProhibited,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hideNotification => $composableBuilder(
      column: $table.hideNotification,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get muteGroupMember => $composableBuilder(
      column: $table.muteGroupMember,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableGroupMemberInvisibility => $composableBuilder(
      column: $table.enableGroupMemberInvisibility,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get restrictSendingNameCard => $composableBuilder(
      column: $table.restrictSendingNameCard,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get forbidSendingPictures => $composableBuilder(
      column: $table.forbidSendingPictures,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get forbidSendingVideos => $composableBuilder(
      column: $table.forbidSendingVideos,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get forbidSendingFiles => $composableBuilder(
      column: $table.forbidSendingFiles,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableVisibilityOfGroupMemberList =>
      $composableBuilder(
          column: $table.enableVisibilityOfGroupMemberList,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableModifyName => $composableBuilder(
      column: $table.enableModifyName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableAddNewMember => $composableBuilder(
      column: $table.enableAddNewMember,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enableReminderManagement => $composableBuilder(
      column: $table.enableReminderManagement,
      builder: (column) => ColumnOrderings(column));

  $$ConversationsTableOrderingComposer get conversationId {
    final $$ConversationsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableOrderingComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConversationSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConversationSettingsTable> {
  $$ConversationSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get canEditGroupName => $composableBuilder(
      column: $table.canEditGroupName, builder: (column) => column);

  GeneratedColumn<bool> get canChangeGroupProfilePhoto => $composableBuilder(
      column: $table.canChangeGroupProfilePhoto, builder: (column) => column);

  GeneratedColumn<bool> get canPostGroupAnnouncement => $composableBuilder(
      column: $table.canPostGroupAnnouncement, builder: (column) => column);

  GeneratedColumn<bool> get enableGroupEntryVerification => $composableBuilder(
      column: $table.enableGroupEntryVerification, builder: (column) => column);

  GeneratedColumn<bool> get enableScreenCaptureProhibited => $composableBuilder(
      column: $table.enableScreenCaptureProhibited,
      builder: (column) => column);

  GeneratedColumn<bool> get hideNotification => $composableBuilder(
      column: $table.hideNotification, builder: (column) => column);

  GeneratedColumn<bool> get muteGroupMember => $composableBuilder(
      column: $table.muteGroupMember, builder: (column) => column);

  GeneratedColumn<bool> get enableGroupMemberInvisibility => $composableBuilder(
      column: $table.enableGroupMemberInvisibility,
      builder: (column) => column);

  GeneratedColumn<bool> get restrictSendingNameCard => $composableBuilder(
      column: $table.restrictSendingNameCard, builder: (column) => column);

  GeneratedColumn<bool> get forbidSendingPictures => $composableBuilder(
      column: $table.forbidSendingPictures, builder: (column) => column);

  GeneratedColumn<bool> get forbidSendingVideos => $composableBuilder(
      column: $table.forbidSendingVideos, builder: (column) => column);

  GeneratedColumn<bool> get forbidSendingFiles => $composableBuilder(
      column: $table.forbidSendingFiles, builder: (column) => column);

  GeneratedColumn<bool> get enableVisibilityOfGroupMemberList =>
      $composableBuilder(
          column: $table.enableVisibilityOfGroupMemberList,
          builder: (column) => column);

  GeneratedColumn<bool> get enableModifyName => $composableBuilder(
      column: $table.enableModifyName, builder: (column) => column);

  GeneratedColumn<bool> get enableAddNewMember => $composableBuilder(
      column: $table.enableAddNewMember, builder: (column) => column);

  GeneratedColumn<bool> get enableReminderManagement => $composableBuilder(
      column: $table.enableReminderManagement, builder: (column) => column);

  $$ConversationsTableAnnotationComposer get conversationId {
    final $$ConversationsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.conversationId,
        referencedTable: $db.conversations,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConversationsTableAnnotationComposer(
              $db: $db,
              $table: $db.conversations,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ConversationSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ConversationSettingsTable,
    ConversationSetting,
    $$ConversationSettingsTableFilterComposer,
    $$ConversationSettingsTableOrderingComposer,
    $$ConversationSettingsTableAnnotationComposer,
    $$ConversationSettingsTableCreateCompanionBuilder,
    $$ConversationSettingsTableUpdateCompanionBuilder,
    (ConversationSetting, $$ConversationSettingsTableReferences),
    ConversationSetting,
    PrefetchHooks Function({bool conversationId})> {
  $$ConversationSettingsTableTableManager(
      _$AppDatabase db, $ConversationSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConversationSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConversationSettingsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConversationSettingsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> conversationId = const Value.absent(),
            Value<bool> canEditGroupName = const Value.absent(),
            Value<bool> canChangeGroupProfilePhoto = const Value.absent(),
            Value<bool> canPostGroupAnnouncement = const Value.absent(),
            Value<bool> enableGroupEntryVerification = const Value.absent(),
            Value<bool> enableScreenCaptureProhibited = const Value.absent(),
            Value<bool> hideNotification = const Value.absent(),
            Value<bool> muteGroupMember = const Value.absent(),
            Value<bool> enableGroupMemberInvisibility = const Value.absent(),
            Value<bool> restrictSendingNameCard = const Value.absent(),
            Value<bool> forbidSendingPictures = const Value.absent(),
            Value<bool> forbidSendingVideos = const Value.absent(),
            Value<bool> forbidSendingFiles = const Value.absent(),
            Value<bool> enableVisibilityOfGroupMemberList =
                const Value.absent(),
            Value<bool> enableModifyName = const Value.absent(),
            Value<bool> enableAddNewMember = const Value.absent(),
            Value<bool> enableReminderManagement = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationSettingsCompanion(
            conversationId: conversationId,
            canEditGroupName: canEditGroupName,
            canChangeGroupProfilePhoto: canChangeGroupProfilePhoto,
            canPostGroupAnnouncement: canPostGroupAnnouncement,
            enableGroupEntryVerification: enableGroupEntryVerification,
            enableScreenCaptureProhibited: enableScreenCaptureProhibited,
            hideNotification: hideNotification,
            muteGroupMember: muteGroupMember,
            enableGroupMemberInvisibility: enableGroupMemberInvisibility,
            restrictSendingNameCard: restrictSendingNameCard,
            forbidSendingPictures: forbidSendingPictures,
            forbidSendingVideos: forbidSendingVideos,
            forbidSendingFiles: forbidSendingFiles,
            enableVisibilityOfGroupMemberList:
                enableVisibilityOfGroupMemberList,
            enableModifyName: enableModifyName,
            enableAddNewMember: enableAddNewMember,
            enableReminderManagement: enableReminderManagement,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String conversationId,
            Value<bool> canEditGroupName = const Value.absent(),
            Value<bool> canChangeGroupProfilePhoto = const Value.absent(),
            Value<bool> canPostGroupAnnouncement = const Value.absent(),
            Value<bool> enableGroupEntryVerification = const Value.absent(),
            Value<bool> enableScreenCaptureProhibited = const Value.absent(),
            Value<bool> hideNotification = const Value.absent(),
            Value<bool> muteGroupMember = const Value.absent(),
            Value<bool> enableGroupMemberInvisibility = const Value.absent(),
            Value<bool> restrictSendingNameCard = const Value.absent(),
            Value<bool> forbidSendingPictures = const Value.absent(),
            Value<bool> forbidSendingVideos = const Value.absent(),
            Value<bool> forbidSendingFiles = const Value.absent(),
            Value<bool> enableVisibilityOfGroupMemberList =
                const Value.absent(),
            Value<bool> enableModifyName = const Value.absent(),
            Value<bool> enableAddNewMember = const Value.absent(),
            Value<bool> enableReminderManagement = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConversationSettingsCompanion.insert(
            conversationId: conversationId,
            canEditGroupName: canEditGroupName,
            canChangeGroupProfilePhoto: canChangeGroupProfilePhoto,
            canPostGroupAnnouncement: canPostGroupAnnouncement,
            enableGroupEntryVerification: enableGroupEntryVerification,
            enableScreenCaptureProhibited: enableScreenCaptureProhibited,
            hideNotification: hideNotification,
            muteGroupMember: muteGroupMember,
            enableGroupMemberInvisibility: enableGroupMemberInvisibility,
            restrictSendingNameCard: restrictSendingNameCard,
            forbidSendingPictures: forbidSendingPictures,
            forbidSendingVideos: forbidSendingVideos,
            forbidSendingFiles: forbidSendingFiles,
            enableVisibilityOfGroupMemberList:
                enableVisibilityOfGroupMemberList,
            enableModifyName: enableModifyName,
            enableAddNewMember: enableAddNewMember,
            enableReminderManagement: enableReminderManagement,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConversationSettingsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({conversationId = false}) {
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
                if (conversationId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.conversationId,
                    referencedTable: $$ConversationSettingsTableReferences
                        ._conversationIdTable(db),
                    referencedColumn: $$ConversationSettingsTableReferences
                        ._conversationIdTable(db)
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

typedef $$ConversationSettingsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ConversationSettingsTable,
        ConversationSetting,
        $$ConversationSettingsTableFilterComposer,
        $$ConversationSettingsTableOrderingComposer,
        $$ConversationSettingsTableAnnotationComposer,
        $$ConversationSettingsTableCreateCompanionBuilder,
        $$ConversationSettingsTableUpdateCompanionBuilder,
        (ConversationSetting, $$ConversationSettingsTableReferences),
        ConversationSetting,
        PrefetchHooks Function({bool conversationId})>;
typedef $$ContactsTableCreateCompanionBuilder = ContactsCompanion Function({
  required String id,
  required String name,
  Value<String?> intro,
  Value<String?> profilePicture,
  Value<String?> profileAccessStrategy,
  Value<DateTime?> registrationDate,
  Value<DateTime?> lastUpdatedDate,
  Value<bool> active,
  Value<String?> userDefinedAttributes,
  Value<int> rowid,
});
typedef $$ContactsTableUpdateCompanionBuilder = ContactsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> intro,
  Value<String?> profilePicture,
  Value<String?> profileAccessStrategy,
  Value<DateTime?> registrationDate,
  Value<DateTime?> lastUpdatedDate,
  Value<bool> active,
  Value<String?> userDefinedAttributes,
  Value<int> rowid,
});

class $$ContactsTableFilterComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get profileAccessStrategy => $composableBuilder(
      column: $table.profileAccessStrategy,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get registrationDate => $composableBuilder(
      column: $table.registrationDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdatedDate => $composableBuilder(
      column: $table.lastUpdatedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userDefinedAttributes => $composableBuilder(
      column: $table.userDefinedAttributes,
      builder: (column) => ColumnFilters(column));
}

class $$ContactsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get intro => $composableBuilder(
      column: $table.intro, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get profileAccessStrategy => $composableBuilder(
      column: $table.profileAccessStrategy,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get registrationDate => $composableBuilder(
      column: $table.registrationDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdatedDate => $composableBuilder(
      column: $table.lastUpdatedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userDefinedAttributes => $composableBuilder(
      column: $table.userDefinedAttributes,
      builder: (column) => ColumnOrderings(column));
}

class $$ContactsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContactsTable> {
  $$ContactsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get intro =>
      $composableBuilder(column: $table.intro, builder: (column) => column);

  GeneratedColumn<String> get profilePicture => $composableBuilder(
      column: $table.profilePicture, builder: (column) => column);

  GeneratedColumn<String> get profileAccessStrategy => $composableBuilder(
      column: $table.profileAccessStrategy, builder: (column) => column);

  GeneratedColumn<DateTime> get registrationDate => $composableBuilder(
      column: $table.registrationDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdatedDate => $composableBuilder(
      column: $table.lastUpdatedDate, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<String> get userDefinedAttributes => $composableBuilder(
      column: $table.userDefinedAttributes, builder: (column) => column);
}

class $$ContactsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
    Contact,
    PrefetchHooks Function()> {
  $$ContactsTableTableManager(_$AppDatabase db, $ContactsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContactsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContactsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContactsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> intro = const Value.absent(),
            Value<String?> profilePicture = const Value.absent(),
            Value<String?> profileAccessStrategy = const Value.absent(),
            Value<DateTime?> registrationDate = const Value.absent(),
            Value<DateTime?> lastUpdatedDate = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<String?> userDefinedAttributes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion(
            id: id,
            name: name,
            intro: intro,
            profilePicture: profilePicture,
            profileAccessStrategy: profileAccessStrategy,
            registrationDate: registrationDate,
            lastUpdatedDate: lastUpdatedDate,
            active: active,
            userDefinedAttributes: userDefinedAttributes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> intro = const Value.absent(),
            Value<String?> profilePicture = const Value.absent(),
            Value<String?> profileAccessStrategy = const Value.absent(),
            Value<DateTime?> registrationDate = const Value.absent(),
            Value<DateTime?> lastUpdatedDate = const Value.absent(),
            Value<bool> active = const Value.absent(),
            Value<String?> userDefinedAttributes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ContactsCompanion.insert(
            id: id,
            name: name,
            intro: intro,
            profilePicture: profilePicture,
            profileAccessStrategy: profileAccessStrategy,
            registrationDate: registrationDate,
            lastUpdatedDate: lastUpdatedDate,
            active: active,
            userDefinedAttributes: userDefinedAttributes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ContactsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ContactsTable,
    Contact,
    $$ContactsTableFilterComposer,
    $$ContactsTableOrderingComposer,
    $$ContactsTableAnnotationComposer,
    $$ContactsTableCreateCompanionBuilder,
    $$ContactsTableUpdateCompanionBuilder,
    (Contact, BaseReferences<_$AppDatabase, $ContactsTable, Contact>),
    Contact,
    PrefetchHooks Function()>;
typedef $$StickersTableCreateCompanionBuilder = StickersCompanion Function({
  required String id,
  required String name,
  required String userId,
  required String path,
  Value<int> rowid,
});
typedef $$StickersTableUpdateCompanionBuilder = StickersCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> userId,
  Value<String> path,
  Value<int> rowid,
});

class $$StickersTableFilterComposer
    extends Composer<_$AppDatabase, $StickersTable> {
  $$StickersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnFilters(column));
}

class $$StickersTableOrderingComposer
    extends Composer<_$AppDatabase, $StickersTable> {
  $$StickersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get path => $composableBuilder(
      column: $table.path, builder: (column) => ColumnOrderings(column));
}

class $$StickersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StickersTable> {
  $$StickersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);
}

class $$StickersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StickersTable,
    Sticker,
    $$StickersTableFilterComposer,
    $$StickersTableOrderingComposer,
    $$StickersTableAnnotationComposer,
    $$StickersTableCreateCompanionBuilder,
    $$StickersTableUpdateCompanionBuilder,
    (Sticker, BaseReferences<_$AppDatabase, $StickersTable, Sticker>),
    Sticker,
    PrefetchHooks Function()> {
  $$StickersTableTableManager(_$AppDatabase db, $StickersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StickersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StickersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StickersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> path = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StickersCompanion(
            id: id,
            name: name,
            userId: userId,
            path: path,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String userId,
            required String path,
            Value<int> rowid = const Value.absent(),
          }) =>
              StickersCompanion.insert(
            id: id,
            name: name,
            userId: userId,
            path: path,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StickersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StickersTable,
    Sticker,
    $$StickersTableFilterComposer,
    $$StickersTableOrderingComposer,
    $$StickersTableAnnotationComposer,
    $$StickersTableCreateCompanionBuilder,
    $$StickersTableUpdateCompanionBuilder,
    (Sticker, BaseReferences<_$AppDatabase, $StickersTable, Sticker>),
    Sticker,
    PrefetchHooks Function()>;
typedef $$UserRelationshipsTableCreateCompanionBuilder
    = UserRelationshipsCompanion Function({
  required String id,
  required String userId,
  required String relatedUserId,
  Value<String> status,
  Value<int> rowid,
});
typedef $$UserRelationshipsTableUpdateCompanionBuilder
    = UserRelationshipsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> relatedUserId,
  Value<String> status,
  Value<int> rowid,
});

class $$UserRelationshipsTableFilterComposer
    extends Composer<_$AppDatabase, $UserRelationshipsTable> {
  $$UserRelationshipsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get relatedUserId => $composableBuilder(
      column: $table.relatedUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));
}

class $$UserRelationshipsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserRelationshipsTable> {
  $$UserRelationshipsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get relatedUserId => $composableBuilder(
      column: $table.relatedUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$UserRelationshipsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserRelationshipsTable> {
  $$UserRelationshipsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get relatedUserId => $composableBuilder(
      column: $table.relatedUserId, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$UserRelationshipsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserRelationshipsTable,
    UserRelationship,
    $$UserRelationshipsTableFilterComposer,
    $$UserRelationshipsTableOrderingComposer,
    $$UserRelationshipsTableAnnotationComposer,
    $$UserRelationshipsTableCreateCompanionBuilder,
    $$UserRelationshipsTableUpdateCompanionBuilder,
    (
      UserRelationship,
      BaseReferences<_$AppDatabase, $UserRelationshipsTable, UserRelationship>
    ),
    UserRelationship,
    PrefetchHooks Function()> {
  $$UserRelationshipsTableTableManager(
      _$AppDatabase db, $UserRelationshipsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserRelationshipsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserRelationshipsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserRelationshipsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> relatedUserId = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserRelationshipsCompanion(
            id: id,
            userId: userId,
            relatedUserId: relatedUserId,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String relatedUserId,
            Value<String> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserRelationshipsCompanion.insert(
            id: id,
            userId: userId,
            relatedUserId: relatedUserId,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserRelationshipsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserRelationshipsTable,
    UserRelationship,
    $$UserRelationshipsTableFilterComposer,
    $$UserRelationshipsTableOrderingComposer,
    $$UserRelationshipsTableAnnotationComposer,
    $$UserRelationshipsTableCreateCompanionBuilder,
    $$UserRelationshipsTableUpdateCompanionBuilder,
    (
      UserRelationship,
      BaseReferences<_$AppDatabase, $UserRelationshipsTable, UserRelationship>
    ),
    UserRelationship,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ConversationsTableTableManager get conversations =>
      $$ConversationsTableTableManager(_db, _db.conversations);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ConversationSettingsTableTableManager get conversationSettings =>
      $$ConversationSettingsTableTableManager(_db, _db.conversationSettings);
  $$ContactsTableTableManager get contacts =>
      $$ContactsTableTableManager(_db, _db.contacts);
  $$StickersTableTableManager get stickers =>
      $$StickersTableTableManager(_db, _db.stickers);
  $$UserRelationshipsTableTableManager get userRelationships =>
      $$UserRelationshipsTableTableManager(_db, _db.userRelationships);
}

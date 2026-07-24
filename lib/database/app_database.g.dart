// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $InstalledAppsTable extends InstalledApps
    with TableInfo<$InstalledAppsTable, InstalledApp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstalledAppsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionNameMeta = const VerificationMeta(
    'versionName',
  );
  @override
  late final GeneratedColumn<String> versionName = GeneratedColumn<String>(
    'version_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionCodeMeta = const VerificationMeta(
    'versionCode',
  );
  @override
  late final GeneratedColumn<int> versionCode = GeneratedColumn<int>(
    'version_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _isSystemAppMeta = const VerificationMeta(
    'isSystemApp',
  );
  @override
  late final GeneratedColumn<bool> isSystemApp = GeneratedColumn<bool>(
    'is_system_app',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system_app" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isPinnedMeta = const VerificationMeta(
    'isPinned',
  );
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
    'is_pinned',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pinned" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isHiddenMeta = const VerificationMeta(
    'isHidden',
  );
  @override
  late final GeneratedColumn<bool> isHidden = GeneratedColumn<bool>(
    'is_hidden',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_hidden" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _iconCacheKeyMeta = const VerificationMeta(
    'iconCacheKey',
  );
  @override
  late final GeneratedColumn<String> iconCacheKey = GeneratedColumn<String>(
    'icon_cache_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _installTimeMeta = const VerificationMeta(
    'installTime',
  );
  @override
  late final GeneratedColumn<DateTime> installTime = GeneratedColumn<DateTime>(
    'install_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updateTimeMeta = const VerificationMeta(
    'updateTime',
  );
  @override
  late final GeneratedColumn<DateTime> updateTime = GeneratedColumn<DateTime>(
    'update_time',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageName,
    appName,
    versionName,
    versionCode,
    category,
    isSystemApp,
    isFavorite,
    isPinned,
    isHidden,
    iconCacheKey,
    installTime,
    updateTime,
    lastOpenedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installed_apps';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstalledApp> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('version_name')) {
      context.handle(
        _versionNameMeta,
        versionName.isAcceptableOrUnknown(
          data['version_name']!,
          _versionNameMeta,
        ),
      );
    }
    if (data.containsKey('version_code')) {
      context.handle(
        _versionCodeMeta,
        versionCode.isAcceptableOrUnknown(
          data['version_code']!,
          _versionCodeMeta,
        ),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_system_app')) {
      context.handle(
        _isSystemAppMeta,
        isSystemApp.isAcceptableOrUnknown(
          data['is_system_app']!,
          _isSystemAppMeta,
        ),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_pinned')) {
      context.handle(
        _isPinnedMeta,
        isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta),
      );
    }
    if (data.containsKey('is_hidden')) {
      context.handle(
        _isHiddenMeta,
        isHidden.isAcceptableOrUnknown(data['is_hidden']!, _isHiddenMeta),
      );
    }
    if (data.containsKey('icon_cache_key')) {
      context.handle(
        _iconCacheKeyMeta,
        iconCacheKey.isAcceptableOrUnknown(
          data['icon_cache_key']!,
          _iconCacheKeyMeta,
        ),
      );
    }
    if (data.containsKey('install_time')) {
      context.handle(
        _installTimeMeta,
        installTime.isAcceptableOrUnknown(
          data['install_time']!,
          _installTimeMeta,
        ),
      );
    }
    if (data.containsKey('update_time')) {
      context.handle(
        _updateTimeMeta,
        updateTime.isAcceptableOrUnknown(data['update_time']!, _updateTimeMeta),
      );
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  InstalledApp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstalledApp(
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      versionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_name'],
      ),
      versionCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version_code'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      isSystemApp: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system_app'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isPinned: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pinned'],
      )!,
      isHidden: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_hidden'],
      )!,
      iconCacheKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_cache_key'],
      ),
      installTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}install_time'],
      ),
      updateTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}update_time'],
      ),
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InstalledAppsTable createAlias(String alias) {
    return $InstalledAppsTable(attachedDatabase, alias);
  }
}

class InstalledApp extends DataClass implements Insertable<InstalledApp> {
  final String packageName;
  final String appName;
  final String? versionName;
  final int? versionCode;
  final String category;
  final bool isSystemApp;
  final bool isFavorite;
  final bool isPinned;
  final bool isHidden;

  /// Optional local file path / cache key for icon bytes stored separately.
  final String? iconCacheKey;
  final DateTime? installTime;
  final DateTime? updateTime;
  final DateTime? lastOpenedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const InstalledApp({
    required this.packageName,
    required this.appName,
    this.versionName,
    this.versionCode,
    required this.category,
    required this.isSystemApp,
    required this.isFavorite,
    required this.isPinned,
    required this.isHidden,
    this.iconCacheKey,
    this.installTime,
    this.updateTime,
    this.lastOpenedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    if (!nullToAbsent || versionName != null) {
      map['version_name'] = Variable<String>(versionName);
    }
    if (!nullToAbsent || versionCode != null) {
      map['version_code'] = Variable<int>(versionCode);
    }
    map['category'] = Variable<String>(category);
    map['is_system_app'] = Variable<bool>(isSystemApp);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_pinned'] = Variable<bool>(isPinned);
    map['is_hidden'] = Variable<bool>(isHidden);
    if (!nullToAbsent || iconCacheKey != null) {
      map['icon_cache_key'] = Variable<String>(iconCacheKey);
    }
    if (!nullToAbsent || installTime != null) {
      map['install_time'] = Variable<DateTime>(installTime);
    }
    if (!nullToAbsent || updateTime != null) {
      map['update_time'] = Variable<DateTime>(updateTime);
    }
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InstalledAppsCompanion toCompanion(bool nullToAbsent) {
    return InstalledAppsCompanion(
      packageName: Value(packageName),
      appName: Value(appName),
      versionName: versionName == null && nullToAbsent
          ? const Value.absent()
          : Value(versionName),
      versionCode: versionCode == null && nullToAbsent
          ? const Value.absent()
          : Value(versionCode),
      category: Value(category),
      isSystemApp: Value(isSystemApp),
      isFavorite: Value(isFavorite),
      isPinned: Value(isPinned),
      isHidden: Value(isHidden),
      iconCacheKey: iconCacheKey == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCacheKey),
      installTime: installTime == null && nullToAbsent
          ? const Value.absent()
          : Value(installTime),
      updateTime: updateTime == null && nullToAbsent
          ? const Value.absent()
          : Value(updateTime),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory InstalledApp.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstalledApp(
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      versionName: serializer.fromJson<String?>(json['versionName']),
      versionCode: serializer.fromJson<int?>(json['versionCode']),
      category: serializer.fromJson<String>(json['category']),
      isSystemApp: serializer.fromJson<bool>(json['isSystemApp']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      isHidden: serializer.fromJson<bool>(json['isHidden']),
      iconCacheKey: serializer.fromJson<String?>(json['iconCacheKey']),
      installTime: serializer.fromJson<DateTime?>(json['installTime']),
      updateTime: serializer.fromJson<DateTime?>(json['updateTime']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'versionName': serializer.toJson<String?>(versionName),
      'versionCode': serializer.toJson<int?>(versionCode),
      'category': serializer.toJson<String>(category),
      'isSystemApp': serializer.toJson<bool>(isSystemApp),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isPinned': serializer.toJson<bool>(isPinned),
      'isHidden': serializer.toJson<bool>(isHidden),
      'iconCacheKey': serializer.toJson<String?>(iconCacheKey),
      'installTime': serializer.toJson<DateTime?>(installTime),
      'updateTime': serializer.toJson<DateTime?>(updateTime),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  InstalledApp copyWith({
    String? packageName,
    String? appName,
    Value<String?> versionName = const Value.absent(),
    Value<int?> versionCode = const Value.absent(),
    String? category,
    bool? isSystemApp,
    bool? isFavorite,
    bool? isPinned,
    bool? isHidden,
    Value<String?> iconCacheKey = const Value.absent(),
    Value<DateTime?> installTime = const Value.absent(),
    Value<DateTime?> updateTime = const Value.absent(),
    Value<DateTime?> lastOpenedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => InstalledApp(
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    versionName: versionName.present ? versionName.value : this.versionName,
    versionCode: versionCode.present ? versionCode.value : this.versionCode,
    category: category ?? this.category,
    isSystemApp: isSystemApp ?? this.isSystemApp,
    isFavorite: isFavorite ?? this.isFavorite,
    isPinned: isPinned ?? this.isPinned,
    isHidden: isHidden ?? this.isHidden,
    iconCacheKey: iconCacheKey.present ? iconCacheKey.value : this.iconCacheKey,
    installTime: installTime.present ? installTime.value : this.installTime,
    updateTime: updateTime.present ? updateTime.value : this.updateTime,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  InstalledApp copyWithCompanion(InstalledAppsCompanion data) {
    return InstalledApp(
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      versionName: data.versionName.present
          ? data.versionName.value
          : this.versionName,
      versionCode: data.versionCode.present
          ? data.versionCode.value
          : this.versionCode,
      category: data.category.present ? data.category.value : this.category,
      isSystemApp: data.isSystemApp.present
          ? data.isSystemApp.value
          : this.isSystemApp,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      isHidden: data.isHidden.present ? data.isHidden.value : this.isHidden,
      iconCacheKey: data.iconCacheKey.present
          ? data.iconCacheKey.value
          : this.iconCacheKey,
      installTime: data.installTime.present
          ? data.installTime.value
          : this.installTime,
      updateTime: data.updateTime.present
          ? data.updateTime.value
          : this.updateTime,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstalledApp(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('versionName: $versionName, ')
          ..write('versionCode: $versionCode, ')
          ..write('category: $category, ')
          ..write('isSystemApp: $isSystemApp, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPinned: $isPinned, ')
          ..write('isHidden: $isHidden, ')
          ..write('iconCacheKey: $iconCacheKey, ')
          ..write('installTime: $installTime, ')
          ..write('updateTime: $updateTime, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packageName,
    appName,
    versionName,
    versionCode,
    category,
    isSystemApp,
    isFavorite,
    isPinned,
    isHidden,
    iconCacheKey,
    installTime,
    updateTime,
    lastOpenedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstalledApp &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.versionName == this.versionName &&
          other.versionCode == this.versionCode &&
          other.category == this.category &&
          other.isSystemApp == this.isSystemApp &&
          other.isFavorite == this.isFavorite &&
          other.isPinned == this.isPinned &&
          other.isHidden == this.isHidden &&
          other.iconCacheKey == this.iconCacheKey &&
          other.installTime == this.installTime &&
          other.updateTime == this.updateTime &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InstalledAppsCompanion extends UpdateCompanion<InstalledApp> {
  final Value<String> packageName;
  final Value<String> appName;
  final Value<String?> versionName;
  final Value<int?> versionCode;
  final Value<String> category;
  final Value<bool> isSystemApp;
  final Value<bool> isFavorite;
  final Value<bool> isPinned;
  final Value<bool> isHidden;
  final Value<String?> iconCacheKey;
  final Value<DateTime?> installTime;
  final Value<DateTime?> updateTime;
  final Value<DateTime?> lastOpenedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const InstalledAppsCompanion({
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.versionName = const Value.absent(),
    this.versionCode = const Value.absent(),
    this.category = const Value.absent(),
    this.isSystemApp = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.iconCacheKey = const Value.absent(),
    this.installTime = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstalledAppsCompanion.insert({
    required String packageName,
    required String appName,
    this.versionName = const Value.absent(),
    this.versionCode = const Value.absent(),
    this.category = const Value.absent(),
    this.isSystemApp = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.isHidden = const Value.absent(),
    this.iconCacheKey = const Value.absent(),
    this.installTime = const Value.absent(),
    this.updateTime = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageName = Value(packageName),
       appName = Value(appName);
  static Insertable<InstalledApp> custom({
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<String>? versionName,
    Expression<int>? versionCode,
    Expression<String>? category,
    Expression<bool>? isSystemApp,
    Expression<bool>? isFavorite,
    Expression<bool>? isPinned,
    Expression<bool>? isHidden,
    Expression<String>? iconCacheKey,
    Expression<DateTime>? installTime,
    Expression<DateTime>? updateTime,
    Expression<DateTime>? lastOpenedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (versionName != null) 'version_name': versionName,
      if (versionCode != null) 'version_code': versionCode,
      if (category != null) 'category': category,
      if (isSystemApp != null) 'is_system_app': isSystemApp,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isPinned != null) 'is_pinned': isPinned,
      if (isHidden != null) 'is_hidden': isHidden,
      if (iconCacheKey != null) 'icon_cache_key': iconCacheKey,
      if (installTime != null) 'install_time': installTime,
      if (updateTime != null) 'update_time': updateTime,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstalledAppsCompanion copyWith({
    Value<String>? packageName,
    Value<String>? appName,
    Value<String?>? versionName,
    Value<int?>? versionCode,
    Value<String>? category,
    Value<bool>? isSystemApp,
    Value<bool>? isFavorite,
    Value<bool>? isPinned,
    Value<bool>? isHidden,
    Value<String?>? iconCacheKey,
    Value<DateTime?>? installTime,
    Value<DateTime?>? updateTime,
    Value<DateTime?>? lastOpenedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return InstalledAppsCompanion(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      versionName: versionName ?? this.versionName,
      versionCode: versionCode ?? this.versionCode,
      category: category ?? this.category,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isFavorite: isFavorite ?? this.isFavorite,
      isPinned: isPinned ?? this.isPinned,
      isHidden: isHidden ?? this.isHidden,
      iconCacheKey: iconCacheKey ?? this.iconCacheKey,
      installTime: installTime ?? this.installTime,
      updateTime: updateTime ?? this.updateTime,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (versionName.present) {
      map['version_name'] = Variable<String>(versionName.value);
    }
    if (versionCode.present) {
      map['version_code'] = Variable<int>(versionCode.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isSystemApp.present) {
      map['is_system_app'] = Variable<bool>(isSystemApp.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (isHidden.present) {
      map['is_hidden'] = Variable<bool>(isHidden.value);
    }
    if (iconCacheKey.present) {
      map['icon_cache_key'] = Variable<String>(iconCacheKey.value);
    }
    if (installTime.present) {
      map['install_time'] = Variable<DateTime>(installTime.value);
    }
    if (updateTime.present) {
      map['update_time'] = Variable<DateTime>(updateTime.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstalledAppsCompanion(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('versionName: $versionName, ')
          ..write('versionCode: $versionCode, ')
          ..write('category: $category, ')
          ..write('isSystemApp: $isSystemApp, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isPinned: $isPinned, ')
          ..write('isHidden: $isHidden, ')
          ..write('iconCacheKey: $iconCacheKey, ')
          ..write('installTime: $installTime, ')
          ..write('updateTime: $updateTime, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsageSessionsTable extends UsageSessions
    with TableInfo<$UsageSessionsTable, UsageSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsageSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOngoingMeta = const VerificationMeta(
    'isOngoing',
  );
  @override
  late final GeneratedColumn<bool> isOngoing = GeneratedColumn<bool>(
    'is_ongoing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ongoing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    startedAt,
    endedAt,
    durationMs,
    dayKey,
    isOngoing,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usage_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('is_ongoing')) {
      context.handle(
        _isOngoingMeta,
        isOngoing.isAcceptableOrUnknown(data['is_ongoing']!, _isOngoingMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UsageSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      isOngoing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ongoing'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $UsageSessionsTable createAlias(String alias) {
    return $UsageSessionsTable(attachedDatabase, alias);
  }
}

class UsageSession extends DataClass implements Insertable<UsageSession> {
  final int id;
  final String packageName;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Duration in milliseconds; null while session is open.
  final int? durationMs;

  /// Local calendar day key `yyyy-MM-dd` for fast filtering.
  final String dayKey;
  final bool isOngoing;
  final DateTime createdAt;
  const UsageSession({
    required this.id,
    required this.packageName,
    required this.startedAt,
    this.endedAt,
    this.durationMs,
    required this.dayKey,
    required this.isOngoing,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['day_key'] = Variable<String>(dayKey);
    map['is_ongoing'] = Variable<bool>(isOngoing);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UsageSessionsCompanion toCompanion(bool nullToAbsent) {
    return UsageSessionsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      dayKey: Value(dayKey),
      isOngoing: Value(isOngoing),
      createdAt: Value(createdAt),
    );
  }

  factory UsageSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageSession(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      isOngoing: serializer.fromJson<bool>(json['isOngoing']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationMs': serializer.toJson<int?>(durationMs),
      'dayKey': serializer.toJson<String>(dayKey),
      'isOngoing': serializer.toJson<bool>(isOngoing),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UsageSession copyWith({
    int? id,
    String? packageName,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    String? dayKey,
    bool? isOngoing,
    DateTime? createdAt,
  }) => UsageSession(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    dayKey: dayKey ?? this.dayKey,
    isOngoing: isOngoing ?? this.isOngoing,
    createdAt: createdAt ?? this.createdAt,
  );
  UsageSession copyWithCompanion(UsageSessionsCompanion data) {
    return UsageSession(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      isOngoing: data.isOngoing.present ? data.isOngoing.value : this.isOngoing,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageSession(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('dayKey: $dayKey, ')
          ..write('isOngoing: $isOngoing, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    startedAt,
    endedAt,
    durationMs,
    dayKey,
    isOngoing,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageSession &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMs == this.durationMs &&
          other.dayKey == this.dayKey &&
          other.isOngoing == this.isOngoing &&
          other.createdAt == this.createdAt);
}

class UsageSessionsCompanion extends UpdateCompanion<UsageSession> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int?> durationMs;
  final Value<String> dayKey;
  final Value<bool> isOngoing;
  final Value<DateTime> createdAt;
  const UsageSessionsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.isOngoing = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  UsageSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationMs = const Value.absent(),
    required String dayKey,
    this.isOngoing = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : packageName = Value(packageName),
       startedAt = Value(startedAt),
       dayKey = Value(dayKey);
  static Insertable<UsageSession> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMs,
    Expression<String>? dayKey,
    Expression<bool>? isOngoing,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMs != null) 'duration_ms': durationMs,
      if (dayKey != null) 'day_key': dayKey,
      if (isOngoing != null) 'is_ongoing': isOngoing,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  UsageSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int?>? durationMs,
    Value<String>? dayKey,
    Value<bool>? isOngoing,
    Value<DateTime>? createdAt,
  }) {
    return UsageSessionsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMs: durationMs ?? this.durationMs,
      dayKey: dayKey ?? this.dayKey,
      isOngoing: isOngoing ?? this.isOngoing,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (isOngoing.present) {
      map['is_ongoing'] = Variable<bool>(isOngoing.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsageSessionsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMs: $durationMs, ')
          ..write('dayKey: $dayKey, ')
          ..write('isOngoing: $isOngoing, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DailySummariesTable extends DailySummaries
    with TableInfo<$DailySummariesTable, DailySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDurationMsMeta = const VerificationMeta(
    'totalDurationMs',
  );
  @override
  late final GeneratedColumn<int> totalDurationMs = GeneratedColumn<int>(
    'total_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _launchCountMeta = const VerificationMeta(
    'launchCount',
  );
  @override
  late final GeneratedColumn<int> launchCount = GeneratedColumn<int>(
    'launch_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _longestSessionMsMeta = const VerificationMeta(
    'longestSessionMs',
  );
  @override
  late final GeneratedColumn<int> longestSessionMs = GeneratedColumn<int>(
    'longest_session_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _shortestSessionMsMeta = const VerificationMeta(
    'shortestSessionMs',
  );
  @override
  late final GeneratedColumn<int> shortestSessionMs = GeneratedColumn<int>(
    'shortest_session_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    dayKey,
    totalDurationMs,
    launchCount,
    longestSessionMs,
    shortestSessionMs,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailySummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('total_duration_ms')) {
      context.handle(
        _totalDurationMsMeta,
        totalDurationMs.isAcceptableOrUnknown(
          data['total_duration_ms']!,
          _totalDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('launch_count')) {
      context.handle(
        _launchCountMeta,
        launchCount.isAcceptableOrUnknown(
          data['launch_count']!,
          _launchCountMeta,
        ),
      );
    }
    if (data.containsKey('longest_session_ms')) {
      context.handle(
        _longestSessionMsMeta,
        longestSessionMs.isAcceptableOrUnknown(
          data['longest_session_ms']!,
          _longestSessionMsMeta,
        ),
      );
    }
    if (data.containsKey('shortest_session_ms')) {
      context.handle(
        _shortestSessionMsMeta,
        shortestSessionMs.isAcceptableOrUnknown(
          data['shortest_session_ms']!,
          _shortestSessionMsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packageName, dayKey},
  ];
  @override
  DailySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailySummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      totalDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_ms'],
      )!,
      launchCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}launch_count'],
      )!,
      longestSessionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_session_ms'],
      )!,
      shortestSessionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}shortest_session_ms'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DailySummariesTable createAlias(String alias) {
    return $DailySummariesTable(attachedDatabase, alias);
  }
}

class DailySummary extends DataClass implements Insertable<DailySummary> {
  final int id;
  final String packageName;
  final String dayKey;
  final int totalDurationMs;
  final int launchCount;
  final int longestSessionMs;
  final int shortestSessionMs;
  final DateTime updatedAt;
  const DailySummary({
    required this.id,
    required this.packageName,
    required this.dayKey,
    required this.totalDurationMs,
    required this.launchCount,
    required this.longestSessionMs,
    required this.shortestSessionMs,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['day_key'] = Variable<String>(dayKey);
    map['total_duration_ms'] = Variable<int>(totalDurationMs);
    map['launch_count'] = Variable<int>(launchCount);
    map['longest_session_ms'] = Variable<int>(longestSessionMs);
    map['shortest_session_ms'] = Variable<int>(shortestSessionMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DailySummariesCompanion toCompanion(bool nullToAbsent) {
    return DailySummariesCompanion(
      id: Value(id),
      packageName: Value(packageName),
      dayKey: Value(dayKey),
      totalDurationMs: Value(totalDurationMs),
      launchCount: Value(launchCount),
      longestSessionMs: Value(longestSessionMs),
      shortestSessionMs: Value(shortestSessionMs),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailySummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailySummary(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      totalDurationMs: serializer.fromJson<int>(json['totalDurationMs']),
      launchCount: serializer.fromJson<int>(json['launchCount']),
      longestSessionMs: serializer.fromJson<int>(json['longestSessionMs']),
      shortestSessionMs: serializer.fromJson<int>(json['shortestSessionMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'dayKey': serializer.toJson<String>(dayKey),
      'totalDurationMs': serializer.toJson<int>(totalDurationMs),
      'launchCount': serializer.toJson<int>(launchCount),
      'longestSessionMs': serializer.toJson<int>(longestSessionMs),
      'shortestSessionMs': serializer.toJson<int>(shortestSessionMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DailySummary copyWith({
    int? id,
    String? packageName,
    String? dayKey,
    int? totalDurationMs,
    int? launchCount,
    int? longestSessionMs,
    int? shortestSessionMs,
    DateTime? updatedAt,
  }) => DailySummary(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    dayKey: dayKey ?? this.dayKey,
    totalDurationMs: totalDurationMs ?? this.totalDurationMs,
    launchCount: launchCount ?? this.launchCount,
    longestSessionMs: longestSessionMs ?? this.longestSessionMs,
    shortestSessionMs: shortestSessionMs ?? this.shortestSessionMs,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailySummary copyWithCompanion(DailySummariesCompanion data) {
    return DailySummary(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      totalDurationMs: data.totalDurationMs.present
          ? data.totalDurationMs.value
          : this.totalDurationMs,
      launchCount: data.launchCount.present
          ? data.launchCount.value
          : this.launchCount,
      longestSessionMs: data.longestSessionMs.present
          ? data.longestSessionMs.value
          : this.longestSessionMs,
      shortestSessionMs: data.shortestSessionMs.present
          ? data.shortestSessionMs.value
          : this.shortestSessionMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailySummary(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('dayKey: $dayKey, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('launchCount: $launchCount, ')
          ..write('longestSessionMs: $longestSessionMs, ')
          ..write('shortestSessionMs: $shortestSessionMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    dayKey,
    totalDurationMs,
    launchCount,
    longestSessionMs,
    shortestSessionMs,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailySummary &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.dayKey == this.dayKey &&
          other.totalDurationMs == this.totalDurationMs &&
          other.launchCount == this.launchCount &&
          other.longestSessionMs == this.longestSessionMs &&
          other.shortestSessionMs == this.shortestSessionMs &&
          other.updatedAt == this.updatedAt);
}

class DailySummariesCompanion extends UpdateCompanion<DailySummary> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> dayKey;
  final Value<int> totalDurationMs;
  final Value<int> launchCount;
  final Value<int> longestSessionMs;
  final Value<int> shortestSessionMs;
  final Value<DateTime> updatedAt;
  const DailySummariesCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.launchCount = const Value.absent(),
    this.longestSessionMs = const Value.absent(),
    this.shortestSessionMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailySummariesCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String dayKey,
    this.totalDurationMs = const Value.absent(),
    this.launchCount = const Value.absent(),
    this.longestSessionMs = const Value.absent(),
    this.shortestSessionMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : packageName = Value(packageName),
       dayKey = Value(dayKey);
  static Insertable<DailySummary> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? dayKey,
    Expression<int>? totalDurationMs,
    Expression<int>? launchCount,
    Expression<int>? longestSessionMs,
    Expression<int>? shortestSessionMs,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (dayKey != null) 'day_key': dayKey,
      if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
      if (launchCount != null) 'launch_count': launchCount,
      if (longestSessionMs != null) 'longest_session_ms': longestSessionMs,
      if (shortestSessionMs != null) 'shortest_session_ms': shortestSessionMs,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailySummariesCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? dayKey,
    Value<int>? totalDurationMs,
    Value<int>? launchCount,
    Value<int>? longestSessionMs,
    Value<int>? shortestSessionMs,
    Value<DateTime>? updatedAt,
  }) {
    return DailySummariesCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      dayKey: dayKey ?? this.dayKey,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      launchCount: launchCount ?? this.launchCount,
      longestSessionMs: longestSessionMs ?? this.longestSessionMs,
      shortestSessionMs: shortestSessionMs ?? this.shortestSessionMs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (totalDurationMs.present) {
      map['total_duration_ms'] = Variable<int>(totalDurationMs.value);
    }
    if (launchCount.present) {
      map['launch_count'] = Variable<int>(launchCount.value);
    }
    if (longestSessionMs.present) {
      map['longest_session_ms'] = Variable<int>(longestSessionMs.value);
    }
    if (shortestSessionMs.present) {
      map['shortest_session_ms'] = Variable<int>(shortestSessionMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailySummariesCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('dayKey: $dayKey, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('launchCount: $launchCount, ')
          ..write('longestSessionMs: $longestSessionMs, ')
          ..write('shortestSessionMs: $shortestSessionMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $WeeklySummariesTable extends WeeklySummaries
    with TableInfo<$WeeklySummariesTable, WeeklySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeeklySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekKeyMeta = const VerificationMeta(
    'weekKey',
  );
  @override
  late final GeneratedColumn<String> weekKey = GeneratedColumn<String>(
    'week_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDurationMsMeta = const VerificationMeta(
    'totalDurationMs',
  );
  @override
  late final GeneratedColumn<int> totalDurationMs = GeneratedColumn<int>(
    'total_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _launchCountMeta = const VerificationMeta(
    'launchCount',
  );
  @override
  late final GeneratedColumn<int> launchCount = GeneratedColumn<int>(
    'launch_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    weekKey,
    totalDurationMs,
    launchCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklySummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('week_key')) {
      context.handle(
        _weekKeyMeta,
        weekKey.isAcceptableOrUnknown(data['week_key']!, _weekKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_weekKeyMeta);
    }
    if (data.containsKey('total_duration_ms')) {
      context.handle(
        _totalDurationMsMeta,
        totalDurationMs.isAcceptableOrUnknown(
          data['total_duration_ms']!,
          _totalDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('launch_count')) {
      context.handle(
        _launchCountMeta,
        launchCount.isAcceptableOrUnknown(
          data['launch_count']!,
          _launchCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packageName, weekKey},
  ];
  @override
  WeeklySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklySummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      weekKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_key'],
      )!,
      totalDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_ms'],
      )!,
      launchCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}launch_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WeeklySummariesTable createAlias(String alias) {
    return $WeeklySummariesTable(attachedDatabase, alias);
  }
}

class WeeklySummary extends DataClass implements Insertable<WeeklySummary> {
  final int id;
  final String packageName;
  final String weekKey;
  final int totalDurationMs;
  final int launchCount;
  final DateTime updatedAt;
  const WeeklySummary({
    required this.id,
    required this.packageName,
    required this.weekKey,
    required this.totalDurationMs,
    required this.launchCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['week_key'] = Variable<String>(weekKey);
    map['total_duration_ms'] = Variable<int>(totalDurationMs);
    map['launch_count'] = Variable<int>(launchCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WeeklySummariesCompanion toCompanion(bool nullToAbsent) {
    return WeeklySummariesCompanion(
      id: Value(id),
      packageName: Value(packageName),
      weekKey: Value(weekKey),
      totalDurationMs: Value(totalDurationMs),
      launchCount: Value(launchCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory WeeklySummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklySummary(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      weekKey: serializer.fromJson<String>(json['weekKey']),
      totalDurationMs: serializer.fromJson<int>(json['totalDurationMs']),
      launchCount: serializer.fromJson<int>(json['launchCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'weekKey': serializer.toJson<String>(weekKey),
      'totalDurationMs': serializer.toJson<int>(totalDurationMs),
      'launchCount': serializer.toJson<int>(launchCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WeeklySummary copyWith({
    int? id,
    String? packageName,
    String? weekKey,
    int? totalDurationMs,
    int? launchCount,
    DateTime? updatedAt,
  }) => WeeklySummary(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    weekKey: weekKey ?? this.weekKey,
    totalDurationMs: totalDurationMs ?? this.totalDurationMs,
    launchCount: launchCount ?? this.launchCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WeeklySummary copyWithCompanion(WeeklySummariesCompanion data) {
    return WeeklySummary(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      weekKey: data.weekKey.present ? data.weekKey.value : this.weekKey,
      totalDurationMs: data.totalDurationMs.present
          ? data.totalDurationMs.value
          : this.totalDurationMs,
      launchCount: data.launchCount.present
          ? data.launchCount.value
          : this.launchCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklySummary(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('weekKey: $weekKey, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('launchCount: $launchCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    weekKey,
    totalDurationMs,
    launchCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklySummary &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.weekKey == this.weekKey &&
          other.totalDurationMs == this.totalDurationMs &&
          other.launchCount == this.launchCount &&
          other.updatedAt == this.updatedAt);
}

class WeeklySummariesCompanion extends UpdateCompanion<WeeklySummary> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> weekKey;
  final Value<int> totalDurationMs;
  final Value<int> launchCount;
  final Value<DateTime> updatedAt;
  const WeeklySummariesCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.weekKey = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.launchCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  WeeklySummariesCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String weekKey,
    this.totalDurationMs = const Value.absent(),
    this.launchCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : packageName = Value(packageName),
       weekKey = Value(weekKey);
  static Insertable<WeeklySummary> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? weekKey,
    Expression<int>? totalDurationMs,
    Expression<int>? launchCount,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (weekKey != null) 'week_key': weekKey,
      if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
      if (launchCount != null) 'launch_count': launchCount,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  WeeklySummariesCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? weekKey,
    Value<int>? totalDurationMs,
    Value<int>? launchCount,
    Value<DateTime>? updatedAt,
  }) {
    return WeeklySummariesCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      weekKey: weekKey ?? this.weekKey,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      launchCount: launchCount ?? this.launchCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (weekKey.present) {
      map['week_key'] = Variable<String>(weekKey.value);
    }
    if (totalDurationMs.present) {
      map['total_duration_ms'] = Variable<int>(totalDurationMs.value);
    }
    if (launchCount.present) {
      map['launch_count'] = Variable<int>(launchCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklySummariesCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('weekKey: $weekKey, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('launchCount: $launchCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $MonthlySummariesTable extends MonthlySummaries
    with TableInfo<$MonthlySummariesTable, MonthlySummary> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthlySummariesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _monthKeyMeta = const VerificationMeta(
    'monthKey',
  );
  @override
  late final GeneratedColumn<String> monthKey = GeneratedColumn<String>(
    'month_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalDurationMsMeta = const VerificationMeta(
    'totalDurationMs',
  );
  @override
  late final GeneratedColumn<int> totalDurationMs = GeneratedColumn<int>(
    'total_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _launchCountMeta = const VerificationMeta(
    'launchCount',
  );
  @override
  late final GeneratedColumn<int> launchCount = GeneratedColumn<int>(
    'launch_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    monthKey,
    totalDurationMs,
    launchCount,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monthly_summaries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonthlySummary> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('month_key')) {
      context.handle(
        _monthKeyMeta,
        monthKey.isAcceptableOrUnknown(data['month_key']!, _monthKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_monthKeyMeta);
    }
    if (data.containsKey('total_duration_ms')) {
      context.handle(
        _totalDurationMsMeta,
        totalDurationMs.isAcceptableOrUnknown(
          data['total_duration_ms']!,
          _totalDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('launch_count')) {
      context.handle(
        _launchCountMeta,
        launchCount.isAcceptableOrUnknown(
          data['launch_count']!,
          _launchCountMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packageName, monthKey},
  ];
  @override
  MonthlySummary map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthlySummary(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      monthKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}month_key'],
      )!,
      totalDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_ms'],
      )!,
      launchCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}launch_count'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MonthlySummariesTable createAlias(String alias) {
    return $MonthlySummariesTable(attachedDatabase, alias);
  }
}

class MonthlySummary extends DataClass implements Insertable<MonthlySummary> {
  final int id;
  final String packageName;
  final String monthKey;
  final int totalDurationMs;
  final int launchCount;
  final DateTime updatedAt;
  const MonthlySummary({
    required this.id,
    required this.packageName,
    required this.monthKey,
    required this.totalDurationMs,
    required this.launchCount,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['month_key'] = Variable<String>(monthKey);
    map['total_duration_ms'] = Variable<int>(totalDurationMs);
    map['launch_count'] = Variable<int>(launchCount);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MonthlySummariesCompanion toCompanion(bool nullToAbsent) {
    return MonthlySummariesCompanion(
      id: Value(id),
      packageName: Value(packageName),
      monthKey: Value(monthKey),
      totalDurationMs: Value(totalDurationMs),
      launchCount: Value(launchCount),
      updatedAt: Value(updatedAt),
    );
  }

  factory MonthlySummary.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthlySummary(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      monthKey: serializer.fromJson<String>(json['monthKey']),
      totalDurationMs: serializer.fromJson<int>(json['totalDurationMs']),
      launchCount: serializer.fromJson<int>(json['launchCount']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'monthKey': serializer.toJson<String>(monthKey),
      'totalDurationMs': serializer.toJson<int>(totalDurationMs),
      'launchCount': serializer.toJson<int>(launchCount),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MonthlySummary copyWith({
    int? id,
    String? packageName,
    String? monthKey,
    int? totalDurationMs,
    int? launchCount,
    DateTime? updatedAt,
  }) => MonthlySummary(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    monthKey: monthKey ?? this.monthKey,
    totalDurationMs: totalDurationMs ?? this.totalDurationMs,
    launchCount: launchCount ?? this.launchCount,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MonthlySummary copyWithCompanion(MonthlySummariesCompanion data) {
    return MonthlySummary(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      monthKey: data.monthKey.present ? data.monthKey.value : this.monthKey,
      totalDurationMs: data.totalDurationMs.present
          ? data.totalDurationMs.value
          : this.totalDurationMs,
      launchCount: data.launchCount.present
          ? data.launchCount.value
          : this.launchCount,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthlySummary(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('monthKey: $monthKey, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('launchCount: $launchCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    monthKey,
    totalDurationMs,
    launchCount,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthlySummary &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.monthKey == this.monthKey &&
          other.totalDurationMs == this.totalDurationMs &&
          other.launchCount == this.launchCount &&
          other.updatedAt == this.updatedAt);
}

class MonthlySummariesCompanion extends UpdateCompanion<MonthlySummary> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> monthKey;
  final Value<int> totalDurationMs;
  final Value<int> launchCount;
  final Value<DateTime> updatedAt;
  const MonthlySummariesCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.monthKey = const Value.absent(),
    this.totalDurationMs = const Value.absent(),
    this.launchCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MonthlySummariesCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String monthKey,
    this.totalDurationMs = const Value.absent(),
    this.launchCount = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : packageName = Value(packageName),
       monthKey = Value(monthKey);
  static Insertable<MonthlySummary> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? monthKey,
    Expression<int>? totalDurationMs,
    Expression<int>? launchCount,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (monthKey != null) 'month_key': monthKey,
      if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
      if (launchCount != null) 'launch_count': launchCount,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MonthlySummariesCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? monthKey,
    Value<int>? totalDurationMs,
    Value<int>? launchCount,
    Value<DateTime>? updatedAt,
  }) {
    return MonthlySummariesCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      monthKey: monthKey ?? this.monthKey,
      totalDurationMs: totalDurationMs ?? this.totalDurationMs,
      launchCount: launchCount ?? this.launchCount,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (monthKey.present) {
      map['month_key'] = Variable<String>(monthKey.value);
    }
    if (totalDurationMs.present) {
      map['total_duration_ms'] = Variable<int>(totalDurationMs.value);
    }
    if (launchCount.present) {
      map['launch_count'] = Variable<int>(launchCount.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthlySummariesCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('monthKey: $monthKey, ')
          ..write('totalDurationMs: $totalDurationMs, ')
          ..write('launchCount: $launchCount, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HourlyUsageTable extends HourlyUsage
    with TableInfo<$HourlyUsageTable, HourlyUsageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HourlyUsageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hourMeta = const VerificationMeta('hour');
  @override
  late final GeneratedColumn<int> hour = GeneratedColumn<int>(
    'hour',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    dayKey,
    hour,
    durationMs,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hourly_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<HourlyUsageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('hour')) {
      context.handle(
        _hourMeta,
        hour.isAcceptableOrUnknown(data['hour']!, _hourMeta),
      );
    } else if (isInserting) {
      context.missing(_hourMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packageName, dayKey, hour},
  ];
  @override
  HourlyUsageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HourlyUsageData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      hour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hour'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HourlyUsageTable createAlias(String alias) {
    return $HourlyUsageTable(attachedDatabase, alias);
  }
}

class HourlyUsageData extends DataClass implements Insertable<HourlyUsageData> {
  final int id;
  final String packageName;
  final String dayKey;

  /// Hour of day in local time, 0–23.
  final int hour;
  final int durationMs;
  final DateTime updatedAt;
  const HourlyUsageData({
    required this.id,
    required this.packageName,
    required this.dayKey,
    required this.hour,
    required this.durationMs,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['day_key'] = Variable<String>(dayKey);
    map['hour'] = Variable<int>(hour);
    map['duration_ms'] = Variable<int>(durationMs);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HourlyUsageCompanion toCompanion(bool nullToAbsent) {
    return HourlyUsageCompanion(
      id: Value(id),
      packageName: Value(packageName),
      dayKey: Value(dayKey),
      hour: Value(hour),
      durationMs: Value(durationMs),
      updatedAt: Value(updatedAt),
    );
  }

  factory HourlyUsageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HourlyUsageData(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      hour: serializer.fromJson<int>(json['hour']),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'dayKey': serializer.toJson<String>(dayKey),
      'hour': serializer.toJson<int>(hour),
      'durationMs': serializer.toJson<int>(durationMs),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HourlyUsageData copyWith({
    int? id,
    String? packageName,
    String? dayKey,
    int? hour,
    int? durationMs,
    DateTime? updatedAt,
  }) => HourlyUsageData(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    dayKey: dayKey ?? this.dayKey,
    hour: hour ?? this.hour,
    durationMs: durationMs ?? this.durationMs,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HourlyUsageData copyWithCompanion(HourlyUsageCompanion data) {
    return HourlyUsageData(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      hour: data.hour.present ? data.hour.value : this.hour,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HourlyUsageData(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('dayKey: $dayKey, ')
          ..write('hour: $hour, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, packageName, dayKey, hour, durationMs, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HourlyUsageData &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.dayKey == this.dayKey &&
          other.hour == this.hour &&
          other.durationMs == this.durationMs &&
          other.updatedAt == this.updatedAt);
}

class HourlyUsageCompanion extends UpdateCompanion<HourlyUsageData> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> dayKey;
  final Value<int> hour;
  final Value<int> durationMs;
  final Value<DateTime> updatedAt;
  const HourlyUsageCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.hour = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HourlyUsageCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String dayKey,
    required int hour,
    this.durationMs = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : packageName = Value(packageName),
       dayKey = Value(dayKey),
       hour = Value(hour);
  static Insertable<HourlyUsageData> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? dayKey,
    Expression<int>? hour,
    Expression<int>? durationMs,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (dayKey != null) 'day_key': dayKey,
      if (hour != null) 'hour': hour,
      if (durationMs != null) 'duration_ms': durationMs,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HourlyUsageCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? dayKey,
    Value<int>? hour,
    Value<int>? durationMs,
    Value<DateTime>? updatedAt,
  }) {
    return HourlyUsageCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      dayKey: dayKey ?? this.dayKey,
      hour: hour ?? this.hour,
      durationMs: durationMs ?? this.durationMs,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (hour.present) {
      map['hour'] = Variable<int>(hour.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HourlyUsageCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('dayKey: $dayKey, ')
          ..write('hour: $hour, ')
          ..write('durationMs: $durationMs, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppLimitsTable extends AppLimits
    with TableInfo<$AppLimitsTable, AppLimit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppLimitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitTypeMeta = const VerificationMeta(
    'limitType',
  );
  @override
  late final GeneratedColumn<String> limitType = GeneratedColumn<String>(
    'limit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _limitDurationMsMeta = const VerificationMeta(
    'limitDurationMs',
  );
  @override
  late final GeneratedColumn<int> limitDurationMs = GeneratedColumn<int>(
    'limit_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _actionOnReachMeta = const VerificationMeta(
    'actionOnReach',
  );
  @override
  late final GeneratedColumn<String> actionOnReach = GeneratedColumn<String>(
    'action_on_reach',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('onlyNotify'),
  );
  static const VerificationMeta _warnAtMinutesRemainingMeta =
      const VerificationMeta('warnAtMinutesRemaining');
  @override
  late final GeneratedColumn<int> warnAtMinutesRemaining = GeneratedColumn<int>(
    'warn_at_minutes_remaining',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  static const VerificationMeta _secondaryWarnAtMinutesRemainingMeta =
      const VerificationMeta('secondaryWarnAtMinutesRemaining');
  @override
  late final GeneratedColumn<int> secondaryWarnAtMinutesRemaining =
      GeneratedColumn<int>(
        'secondary_warn_at_minutes_remaining',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(10),
      );
  static const VerificationMeta _customWindowStartMeta = const VerificationMeta(
    'customWindowStart',
  );
  @override
  late final GeneratedColumn<DateTime> customWindowStart =
      GeneratedColumn<DateTime>(
        'custom_window_start',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customWindowEndMeta = const VerificationMeta(
    'customWindowEnd',
  );
  @override
  late final GeneratedColumn<DateTime> customWindowEnd =
      GeneratedColumn<DateTime>(
        'custom_window_end',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    limitType,
    limitDurationMs,
    isEnabled,
    actionOnReach,
    warnAtMinutesRemaining,
    secondaryWarnAtMinutesRemaining,
    customWindowStart,
    customWindowEnd,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_limits';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppLimit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('limit_type')) {
      context.handle(
        _limitTypeMeta,
        limitType.isAcceptableOrUnknown(data['limit_type']!, _limitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_limitTypeMeta);
    }
    if (data.containsKey('limit_duration_ms')) {
      context.handle(
        _limitDurationMsMeta,
        limitDurationMs.isAcceptableOrUnknown(
          data['limit_duration_ms']!,
          _limitDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_limitDurationMsMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('action_on_reach')) {
      context.handle(
        _actionOnReachMeta,
        actionOnReach.isAcceptableOrUnknown(
          data['action_on_reach']!,
          _actionOnReachMeta,
        ),
      );
    }
    if (data.containsKey('warn_at_minutes_remaining')) {
      context.handle(
        _warnAtMinutesRemainingMeta,
        warnAtMinutesRemaining.isAcceptableOrUnknown(
          data['warn_at_minutes_remaining']!,
          _warnAtMinutesRemainingMeta,
        ),
      );
    }
    if (data.containsKey('secondary_warn_at_minutes_remaining')) {
      context.handle(
        _secondaryWarnAtMinutesRemainingMeta,
        secondaryWarnAtMinutesRemaining.isAcceptableOrUnknown(
          data['secondary_warn_at_minutes_remaining']!,
          _secondaryWarnAtMinutesRemainingMeta,
        ),
      );
    }
    if (data.containsKey('custom_window_start')) {
      context.handle(
        _customWindowStartMeta,
        customWindowStart.isAcceptableOrUnknown(
          data['custom_window_start']!,
          _customWindowStartMeta,
        ),
      );
    }
    if (data.containsKey('custom_window_end')) {
      context.handle(
        _customWindowEndMeta,
        customWindowEnd.isAcceptableOrUnknown(
          data['custom_window_end']!,
          _customWindowEndMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packageName, limitType},
  ];
  @override
  AppLimit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppLimit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      limitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}limit_type'],
      )!,
      limitDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}limit_duration_ms'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      actionOnReach: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_on_reach'],
      )!,
      warnAtMinutesRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}warn_at_minutes_remaining'],
      )!,
      secondaryWarnAtMinutesRemaining: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}secondary_warn_at_minutes_remaining'],
      )!,
      customWindowStart: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}custom_window_start'],
      ),
      customWindowEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}custom_window_end'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppLimitsTable createAlias(String alias) {
    return $AppLimitsTable(attachedDatabase, alias);
  }
}

class AppLimit extends DataClass implements Insertable<AppLimit> {
  final int id;
  final String packageName;

  /// daily | weekly | monthly | custom
  final String limitType;

  /// Limit duration in milliseconds.
  final int limitDurationMs;
  final bool isEnabled;

  /// onlyNotify | fullScreen | overlay | confirm | delay | strict
  final String actionOnReach;
  final int warnAtMinutesRemaining;
  final int secondaryWarnAtMinutesRemaining;

  /// Inclusive start of a custom limit window (custom type only).
  final DateTime? customWindowStart;

  /// Inclusive end of a custom limit window (custom type only).
  final DateTime? customWindowEnd;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AppLimit({
    required this.id,
    required this.packageName,
    required this.limitType,
    required this.limitDurationMs,
    required this.isEnabled,
    required this.actionOnReach,
    required this.warnAtMinutesRemaining,
    required this.secondaryWarnAtMinutesRemaining,
    this.customWindowStart,
    this.customWindowEnd,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    map['limit_type'] = Variable<String>(limitType);
    map['limit_duration_ms'] = Variable<int>(limitDurationMs);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['action_on_reach'] = Variable<String>(actionOnReach);
    map['warn_at_minutes_remaining'] = Variable<int>(warnAtMinutesRemaining);
    map['secondary_warn_at_minutes_remaining'] = Variable<int>(
      secondaryWarnAtMinutesRemaining,
    );
    if (!nullToAbsent || customWindowStart != null) {
      map['custom_window_start'] = Variable<DateTime>(customWindowStart);
    }
    if (!nullToAbsent || customWindowEnd != null) {
      map['custom_window_end'] = Variable<DateTime>(customWindowEnd);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppLimitsCompanion toCompanion(bool nullToAbsent) {
    return AppLimitsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      limitType: Value(limitType),
      limitDurationMs: Value(limitDurationMs),
      isEnabled: Value(isEnabled),
      actionOnReach: Value(actionOnReach),
      warnAtMinutesRemaining: Value(warnAtMinutesRemaining),
      secondaryWarnAtMinutesRemaining: Value(secondaryWarnAtMinutesRemaining),
      customWindowStart: customWindowStart == null && nullToAbsent
          ? const Value.absent()
          : Value(customWindowStart),
      customWindowEnd: customWindowEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(customWindowEnd),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppLimit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppLimit(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      limitType: serializer.fromJson<String>(json['limitType']),
      limitDurationMs: serializer.fromJson<int>(json['limitDurationMs']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      actionOnReach: serializer.fromJson<String>(json['actionOnReach']),
      warnAtMinutesRemaining: serializer.fromJson<int>(
        json['warnAtMinutesRemaining'],
      ),
      secondaryWarnAtMinutesRemaining: serializer.fromJson<int>(
        json['secondaryWarnAtMinutesRemaining'],
      ),
      customWindowStart: serializer.fromJson<DateTime?>(
        json['customWindowStart'],
      ),
      customWindowEnd: serializer.fromJson<DateTime?>(json['customWindowEnd']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packageName': serializer.toJson<String>(packageName),
      'limitType': serializer.toJson<String>(limitType),
      'limitDurationMs': serializer.toJson<int>(limitDurationMs),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'actionOnReach': serializer.toJson<String>(actionOnReach),
      'warnAtMinutesRemaining': serializer.toJson<int>(warnAtMinutesRemaining),
      'secondaryWarnAtMinutesRemaining': serializer.toJson<int>(
        secondaryWarnAtMinutesRemaining,
      ),
      'customWindowStart': serializer.toJson<DateTime?>(customWindowStart),
      'customWindowEnd': serializer.toJson<DateTime?>(customWindowEnd),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppLimit copyWith({
    int? id,
    String? packageName,
    String? limitType,
    int? limitDurationMs,
    bool? isEnabled,
    String? actionOnReach,
    int? warnAtMinutesRemaining,
    int? secondaryWarnAtMinutesRemaining,
    Value<DateTime?> customWindowStart = const Value.absent(),
    Value<DateTime?> customWindowEnd = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AppLimit(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    limitType: limitType ?? this.limitType,
    limitDurationMs: limitDurationMs ?? this.limitDurationMs,
    isEnabled: isEnabled ?? this.isEnabled,
    actionOnReach: actionOnReach ?? this.actionOnReach,
    warnAtMinutesRemaining:
        warnAtMinutesRemaining ?? this.warnAtMinutesRemaining,
    secondaryWarnAtMinutesRemaining:
        secondaryWarnAtMinutesRemaining ?? this.secondaryWarnAtMinutesRemaining,
    customWindowStart: customWindowStart.present
        ? customWindowStart.value
        : this.customWindowStart,
    customWindowEnd: customWindowEnd.present
        ? customWindowEnd.value
        : this.customWindowEnd,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppLimit copyWithCompanion(AppLimitsCompanion data) {
    return AppLimit(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      limitType: data.limitType.present ? data.limitType.value : this.limitType,
      limitDurationMs: data.limitDurationMs.present
          ? data.limitDurationMs.value
          : this.limitDurationMs,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      actionOnReach: data.actionOnReach.present
          ? data.actionOnReach.value
          : this.actionOnReach,
      warnAtMinutesRemaining: data.warnAtMinutesRemaining.present
          ? data.warnAtMinutesRemaining.value
          : this.warnAtMinutesRemaining,
      secondaryWarnAtMinutesRemaining:
          data.secondaryWarnAtMinutesRemaining.present
          ? data.secondaryWarnAtMinutesRemaining.value
          : this.secondaryWarnAtMinutesRemaining,
      customWindowStart: data.customWindowStart.present
          ? data.customWindowStart.value
          : this.customWindowStart,
      customWindowEnd: data.customWindowEnd.present
          ? data.customWindowEnd.value
          : this.customWindowEnd,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppLimit(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('limitType: $limitType, ')
          ..write('limitDurationMs: $limitDurationMs, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('actionOnReach: $actionOnReach, ')
          ..write('warnAtMinutesRemaining: $warnAtMinutesRemaining, ')
          ..write(
            'secondaryWarnAtMinutesRemaining: $secondaryWarnAtMinutesRemaining, ',
          )
          ..write('customWindowStart: $customWindowStart, ')
          ..write('customWindowEnd: $customWindowEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    limitType,
    limitDurationMs,
    isEnabled,
    actionOnReach,
    warnAtMinutesRemaining,
    secondaryWarnAtMinutesRemaining,
    customWindowStart,
    customWindowEnd,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppLimit &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.limitType == this.limitType &&
          other.limitDurationMs == this.limitDurationMs &&
          other.isEnabled == this.isEnabled &&
          other.actionOnReach == this.actionOnReach &&
          other.warnAtMinutesRemaining == this.warnAtMinutesRemaining &&
          other.secondaryWarnAtMinutesRemaining ==
              this.secondaryWarnAtMinutesRemaining &&
          other.customWindowStart == this.customWindowStart &&
          other.customWindowEnd == this.customWindowEnd &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppLimitsCompanion extends UpdateCompanion<AppLimit> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String> limitType;
  final Value<int> limitDurationMs;
  final Value<bool> isEnabled;
  final Value<String> actionOnReach;
  final Value<int> warnAtMinutesRemaining;
  final Value<int> secondaryWarnAtMinutesRemaining;
  final Value<DateTime?> customWindowStart;
  final Value<DateTime?> customWindowEnd;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const AppLimitsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.limitType = const Value.absent(),
    this.limitDurationMs = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.actionOnReach = const Value.absent(),
    this.warnAtMinutesRemaining = const Value.absent(),
    this.secondaryWarnAtMinutesRemaining = const Value.absent(),
    this.customWindowStart = const Value.absent(),
    this.customWindowEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppLimitsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    required String limitType,
    required int limitDurationMs,
    this.isEnabled = const Value.absent(),
    this.actionOnReach = const Value.absent(),
    this.warnAtMinutesRemaining = const Value.absent(),
    this.secondaryWarnAtMinutesRemaining = const Value.absent(),
    this.customWindowStart = const Value.absent(),
    this.customWindowEnd = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : packageName = Value(packageName),
       limitType = Value(limitType),
       limitDurationMs = Value(limitDurationMs);
  static Insertable<AppLimit> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? limitType,
    Expression<int>? limitDurationMs,
    Expression<bool>? isEnabled,
    Expression<String>? actionOnReach,
    Expression<int>? warnAtMinutesRemaining,
    Expression<int>? secondaryWarnAtMinutesRemaining,
    Expression<DateTime>? customWindowStart,
    Expression<DateTime>? customWindowEnd,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (limitType != null) 'limit_type': limitType,
      if (limitDurationMs != null) 'limit_duration_ms': limitDurationMs,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (actionOnReach != null) 'action_on_reach': actionOnReach,
      if (warnAtMinutesRemaining != null)
        'warn_at_minutes_remaining': warnAtMinutesRemaining,
      if (secondaryWarnAtMinutesRemaining != null)
        'secondary_warn_at_minutes_remaining': secondaryWarnAtMinutesRemaining,
      if (customWindowStart != null) 'custom_window_start': customWindowStart,
      if (customWindowEnd != null) 'custom_window_end': customWindowEnd,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppLimitsCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String>? limitType,
    Value<int>? limitDurationMs,
    Value<bool>? isEnabled,
    Value<String>? actionOnReach,
    Value<int>? warnAtMinutesRemaining,
    Value<int>? secondaryWarnAtMinutesRemaining,
    Value<DateTime?>? customWindowStart,
    Value<DateTime?>? customWindowEnd,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return AppLimitsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      limitType: limitType ?? this.limitType,
      limitDurationMs: limitDurationMs ?? this.limitDurationMs,
      isEnabled: isEnabled ?? this.isEnabled,
      actionOnReach: actionOnReach ?? this.actionOnReach,
      warnAtMinutesRemaining:
          warnAtMinutesRemaining ?? this.warnAtMinutesRemaining,
      secondaryWarnAtMinutesRemaining:
          secondaryWarnAtMinutesRemaining ??
          this.secondaryWarnAtMinutesRemaining,
      customWindowStart: customWindowStart ?? this.customWindowStart,
      customWindowEnd: customWindowEnd ?? this.customWindowEnd,
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
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (limitType.present) {
      map['limit_type'] = Variable<String>(limitType.value);
    }
    if (limitDurationMs.present) {
      map['limit_duration_ms'] = Variable<int>(limitDurationMs.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (actionOnReach.present) {
      map['action_on_reach'] = Variable<String>(actionOnReach.value);
    }
    if (warnAtMinutesRemaining.present) {
      map['warn_at_minutes_remaining'] = Variable<int>(
        warnAtMinutesRemaining.value,
      );
    }
    if (secondaryWarnAtMinutesRemaining.present) {
      map['secondary_warn_at_minutes_remaining'] = Variable<int>(
        secondaryWarnAtMinutesRemaining.value,
      );
    }
    if (customWindowStart.present) {
      map['custom_window_start'] = Variable<DateTime>(customWindowStart.value);
    }
    if (customWindowEnd.present) {
      map['custom_window_end'] = Variable<DateTime>(customWindowEnd.value);
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
    return (StringBuffer('AppLimitsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('limitType: $limitType, ')
          ..write('limitDurationMs: $limitDurationMs, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('actionOnReach: $actionOnReach, ')
          ..write('warnAtMinutesRemaining: $warnAtMinutesRemaining, ')
          ..write(
            'secondaryWarnAtMinutesRemaining: $secondaryWarnAtMinutesRemaining, ',
          )
          ..write('customWindowStart: $customWindowStart, ')
          ..write('customWindowEnd: $customWindowEnd, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $FocusSessionsTable extends FocusSessions
    with TableInfo<$FocusSessionsTable, FocusSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FocusSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _plannedDurationMsMeta = const VerificationMeta(
    'plannedDurationMs',
  );
  @override
  late final GeneratedColumn<int> plannedDurationMs = GeneratedColumn<int>(
    'planned_duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualDurationMsMeta = const VerificationMeta(
    'actualDurationMs',
  );
  @override
  late final GeneratedColumn<int> actualDurationMs = GeneratedColumn<int>(
    'actual_duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _blockedPackagesJsonMeta =
      const VerificationMeta('blockedPackagesJson');
  @override
  late final GeneratedColumn<String> blockedPackagesJson =
      GeneratedColumn<String>(
        'blocked_packages_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _dayKeyMeta = const VerificationMeta('dayKey');
  @override
  late final GeneratedColumn<String> dayKey = GeneratedColumn<String>(
    'day_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    startedAt,
    endedAt,
    plannedDurationMs,
    actualDurationMs,
    blockedPackagesJson,
    status,
    dayKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'focus_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<FocusSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('planned_duration_ms')) {
      context.handle(
        _plannedDurationMsMeta,
        plannedDurationMs.isAcceptableOrUnknown(
          data['planned_duration_ms']!,
          _plannedDurationMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_plannedDurationMsMeta);
    }
    if (data.containsKey('actual_duration_ms')) {
      context.handle(
        _actualDurationMsMeta,
        actualDurationMs.isAcceptableOrUnknown(
          data['actual_duration_ms']!,
          _actualDurationMsMeta,
        ),
      );
    }
    if (data.containsKey('blocked_packages_json')) {
      context.handle(
        _blockedPackagesJsonMeta,
        blockedPackagesJson.isAcceptableOrUnknown(
          data['blocked_packages_json']!,
          _blockedPackagesJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_blockedPackagesJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('day_key')) {
      context.handle(
        _dayKeyMeta,
        dayKey.isAcceptableOrUnknown(data['day_key']!, _dayKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_dayKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FocusSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FocusSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      plannedDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}planned_duration_ms'],
      )!,
      actualDurationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_duration_ms'],
      ),
      blockedPackagesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blocked_packages_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      dayKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FocusSessionsTable createAlias(String alias) {
    return $FocusSessionsTable(attachedDatabase, alias);
  }
}

class FocusSession extends DataClass implements Insertable<FocusSession> {
  final int id;
  final DateTime startedAt;
  final DateTime? endedAt;

  /// Planned duration in milliseconds.
  final int plannedDurationMs;

  /// Actual completed duration in milliseconds.
  final int? actualDurationMs;

  /// JSON-encoded list of blocked package names.
  final String blockedPackagesJson;

  /// active | completed | cancelled
  final String status;
  final String dayKey;
  final DateTime createdAt;
  const FocusSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.plannedDurationMs,
    this.actualDurationMs,
    required this.blockedPackagesJson,
    required this.status,
    required this.dayKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['planned_duration_ms'] = Variable<int>(plannedDurationMs);
    if (!nullToAbsent || actualDurationMs != null) {
      map['actual_duration_ms'] = Variable<int>(actualDurationMs);
    }
    map['blocked_packages_json'] = Variable<String>(blockedPackagesJson);
    map['status'] = Variable<String>(status);
    map['day_key'] = Variable<String>(dayKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FocusSessionsCompanion toCompanion(bool nullToAbsent) {
    return FocusSessionsCompanion(
      id: Value(id),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      plannedDurationMs: Value(plannedDurationMs),
      actualDurationMs: actualDurationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(actualDurationMs),
      blockedPackagesJson: Value(blockedPackagesJson),
      status: Value(status),
      dayKey: Value(dayKey),
      createdAt: Value(createdAt),
    );
  }

  factory FocusSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FocusSession(
      id: serializer.fromJson<int>(json['id']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      plannedDurationMs: serializer.fromJson<int>(json['plannedDurationMs']),
      actualDurationMs: serializer.fromJson<int?>(json['actualDurationMs']),
      blockedPackagesJson: serializer.fromJson<String>(
        json['blockedPackagesJson'],
      ),
      status: serializer.fromJson<String>(json['status']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'plannedDurationMs': serializer.toJson<int>(plannedDurationMs),
      'actualDurationMs': serializer.toJson<int?>(actualDurationMs),
      'blockedPackagesJson': serializer.toJson<String>(blockedPackagesJson),
      'status': serializer.toJson<String>(status),
      'dayKey': serializer.toJson<String>(dayKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FocusSession copyWith({
    int? id,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? plannedDurationMs,
    Value<int?> actualDurationMs = const Value.absent(),
    String? blockedPackagesJson,
    String? status,
    String? dayKey,
    DateTime? createdAt,
  }) => FocusSession(
    id: id ?? this.id,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    plannedDurationMs: plannedDurationMs ?? this.plannedDurationMs,
    actualDurationMs: actualDurationMs.present
        ? actualDurationMs.value
        : this.actualDurationMs,
    blockedPackagesJson: blockedPackagesJson ?? this.blockedPackagesJson,
    status: status ?? this.status,
    dayKey: dayKey ?? this.dayKey,
    createdAt: createdAt ?? this.createdAt,
  );
  FocusSession copyWithCompanion(FocusSessionsCompanion data) {
    return FocusSession(
      id: data.id.present ? data.id.value : this.id,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      plannedDurationMs: data.plannedDurationMs.present
          ? data.plannedDurationMs.value
          : this.plannedDurationMs,
      actualDurationMs: data.actualDurationMs.present
          ? data.actualDurationMs.value
          : this.actualDurationMs,
      blockedPackagesJson: data.blockedPackagesJson.present
          ? data.blockedPackagesJson.value
          : this.blockedPackagesJson,
      status: data.status.present ? data.status.value : this.status,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FocusSession(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('plannedDurationMs: $plannedDurationMs, ')
          ..write('actualDurationMs: $actualDurationMs, ')
          ..write('blockedPackagesJson: $blockedPackagesJson, ')
          ..write('status: $status, ')
          ..write('dayKey: $dayKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    startedAt,
    endedAt,
    plannedDurationMs,
    actualDurationMs,
    blockedPackagesJson,
    status,
    dayKey,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FocusSession &&
          other.id == this.id &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.plannedDurationMs == this.plannedDurationMs &&
          other.actualDurationMs == this.actualDurationMs &&
          other.blockedPackagesJson == this.blockedPackagesJson &&
          other.status == this.status &&
          other.dayKey == this.dayKey &&
          other.createdAt == this.createdAt);
}

class FocusSessionsCompanion extends UpdateCompanion<FocusSession> {
  final Value<int> id;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> plannedDurationMs;
  final Value<int?> actualDurationMs;
  final Value<String> blockedPackagesJson;
  final Value<String> status;
  final Value<String> dayKey;
  final Value<DateTime> createdAt;
  const FocusSessionsCompanion({
    this.id = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.plannedDurationMs = const Value.absent(),
    this.actualDurationMs = const Value.absent(),
    this.blockedPackagesJson = const Value.absent(),
    this.status = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  FocusSessionsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    required int plannedDurationMs,
    this.actualDurationMs = const Value.absent(),
    required String blockedPackagesJson,
    this.status = const Value.absent(),
    required String dayKey,
    this.createdAt = const Value.absent(),
  }) : startedAt = Value(startedAt),
       plannedDurationMs = Value(plannedDurationMs),
       blockedPackagesJson = Value(blockedPackagesJson),
       dayKey = Value(dayKey);
  static Insertable<FocusSession> custom({
    Expression<int>? id,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? plannedDurationMs,
    Expression<int>? actualDurationMs,
    Expression<String>? blockedPackagesJson,
    Expression<String>? status,
    Expression<String>? dayKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (plannedDurationMs != null) 'planned_duration_ms': plannedDurationMs,
      if (actualDurationMs != null) 'actual_duration_ms': actualDurationMs,
      if (blockedPackagesJson != null)
        'blocked_packages_json': blockedPackagesJson,
      if (status != null) 'status': status,
      if (dayKey != null) 'day_key': dayKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  FocusSessionsCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? plannedDurationMs,
    Value<int?>? actualDurationMs,
    Value<String>? blockedPackagesJson,
    Value<String>? status,
    Value<String>? dayKey,
    Value<DateTime>? createdAt,
  }) {
    return FocusSessionsCompanion(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      plannedDurationMs: plannedDurationMs ?? this.plannedDurationMs,
      actualDurationMs: actualDurationMs ?? this.actualDurationMs,
      blockedPackagesJson: blockedPackagesJson ?? this.blockedPackagesJson,
      status: status ?? this.status,
      dayKey: dayKey ?? this.dayKey,
      createdAt: createdAt ?? this.createdAt,
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
    if (plannedDurationMs.present) {
      map['planned_duration_ms'] = Variable<int>(plannedDurationMs.value);
    }
    if (actualDurationMs.present) {
      map['actual_duration_ms'] = Variable<int>(actualDurationMs.value);
    }
    if (blockedPackagesJson.present) {
      map['blocked_packages_json'] = Variable<String>(
        blockedPackagesJson.value,
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FocusSessionsCompanion(')
          ..write('id: $id, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('plannedDurationMs: $plannedDurationMs, ')
          ..write('actualDurationMs: $actualDurationMs, ')
          ..write('blockedPackagesJson: $blockedPackagesJson, ')
          ..write('status: $status, ')
          ..write('dayKey: $dayKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $NotificationHistoryTable extends NotificationHistory
    with TableInfo<$NotificationHistoryTable, NotificationHistoryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotificationHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wasTappedMeta = const VerificationMeta(
    'wasTapped',
  );
  @override
  late final GeneratedColumn<bool> wasTapped = GeneratedColumn<bool>(
    'was_tapped',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("was_tapped" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shownAtMeta = const VerificationMeta(
    'shownAt',
  );
  @override
  late final GeneratedColumn<DateTime> shownAt = GeneratedColumn<DateTime>(
    'shown_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    body,
    category,
    packageName,
    wasTapped,
    shownAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notification_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<NotificationHistoryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    }
    if (data.containsKey('was_tapped')) {
      context.handle(
        _wasTappedMeta,
        wasTapped.isAcceptableOrUnknown(data['was_tapped']!, _wasTappedMeta),
      );
    }
    if (data.containsKey('shown_at')) {
      context.handle(
        _shownAtMeta,
        shownAt.isAcceptableOrUnknown(data['shown_at']!, _shownAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NotificationHistoryData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NotificationHistoryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      ),
      wasTapped: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}was_tapped'],
      )!,
      shownAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}shown_at'],
      )!,
    );
  }

  @override
  $NotificationHistoryTable createAlias(String alias) {
    return $NotificationHistoryTable(attachedDatabase, alias);
  }
}

class NotificationHistoryData extends DataClass
    implements Insertable<NotificationHistoryData> {
  final int id;
  final String title;
  final String body;

  /// limit | focus | tracking | general | report
  final String category;
  final String? packageName;
  final bool wasTapped;
  final DateTime shownAt;
  const NotificationHistoryData({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    this.packageName,
    required this.wasTapped,
    required this.shownAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || packageName != null) {
      map['package_name'] = Variable<String>(packageName);
    }
    map['was_tapped'] = Variable<bool>(wasTapped);
    map['shown_at'] = Variable<DateTime>(shownAt);
    return map;
  }

  NotificationHistoryCompanion toCompanion(bool nullToAbsent) {
    return NotificationHistoryCompanion(
      id: Value(id),
      title: Value(title),
      body: Value(body),
      category: Value(category),
      packageName: packageName == null && nullToAbsent
          ? const Value.absent()
          : Value(packageName),
      wasTapped: Value(wasTapped),
      shownAt: Value(shownAt),
    );
  }

  factory NotificationHistoryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NotificationHistoryData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      category: serializer.fromJson<String>(json['category']),
      packageName: serializer.fromJson<String?>(json['packageName']),
      wasTapped: serializer.fromJson<bool>(json['wasTapped']),
      shownAt: serializer.fromJson<DateTime>(json['shownAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'category': serializer.toJson<String>(category),
      'packageName': serializer.toJson<String?>(packageName),
      'wasTapped': serializer.toJson<bool>(wasTapped),
      'shownAt': serializer.toJson<DateTime>(shownAt),
    };
  }

  NotificationHistoryData copyWith({
    int? id,
    String? title,
    String? body,
    String? category,
    Value<String?> packageName = const Value.absent(),
    bool? wasTapped,
    DateTime? shownAt,
  }) => NotificationHistoryData(
    id: id ?? this.id,
    title: title ?? this.title,
    body: body ?? this.body,
    category: category ?? this.category,
    packageName: packageName.present ? packageName.value : this.packageName,
    wasTapped: wasTapped ?? this.wasTapped,
    shownAt: shownAt ?? this.shownAt,
  );
  NotificationHistoryData copyWithCompanion(NotificationHistoryCompanion data) {
    return NotificationHistoryData(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      category: data.category.present ? data.category.value : this.category,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      wasTapped: data.wasTapped.present ? data.wasTapped.value : this.wasTapped,
      shownAt: data.shownAt.present ? data.shownAt.value : this.shownAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NotificationHistoryData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category, ')
          ..write('packageName: $packageName, ')
          ..write('wasTapped: $wasTapped, ')
          ..write('shownAt: $shownAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, body, category, packageName, wasTapped, shownAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NotificationHistoryData &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.category == this.category &&
          other.packageName == this.packageName &&
          other.wasTapped == this.wasTapped &&
          other.shownAt == this.shownAt);
}

class NotificationHistoryCompanion
    extends UpdateCompanion<NotificationHistoryData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> body;
  final Value<String> category;
  final Value<String?> packageName;
  final Value<bool> wasTapped;
  final Value<DateTime> shownAt;
  const NotificationHistoryCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.category = const Value.absent(),
    this.packageName = const Value.absent(),
    this.wasTapped = const Value.absent(),
    this.shownAt = const Value.absent(),
  });
  NotificationHistoryCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String body,
    required String category,
    this.packageName = const Value.absent(),
    this.wasTapped = const Value.absent(),
    this.shownAt = const Value.absent(),
  }) : title = Value(title),
       body = Value(body),
       category = Value(category);
  static Insertable<NotificationHistoryData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? category,
    Expression<String>? packageName,
    Expression<bool>? wasTapped,
    Expression<DateTime>? shownAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (category != null) 'category': category,
      if (packageName != null) 'package_name': packageName,
      if (wasTapped != null) 'was_tapped': wasTapped,
      if (shownAt != null) 'shown_at': shownAt,
    });
  }

  NotificationHistoryCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? body,
    Value<String>? category,
    Value<String?>? packageName,
    Value<bool>? wasTapped,
    Value<DateTime>? shownAt,
  }) {
    return NotificationHistoryCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      category: category ?? this.category,
      packageName: packageName ?? this.packageName,
      wasTapped: wasTapped ?? this.wasTapped,
      shownAt: shownAt ?? this.shownAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (wasTapped.present) {
      map['was_tapped'] = Variable<bool>(wasTapped.value);
    }
    if (shownAt.present) {
      map['shown_at'] = Variable<DateTime>(shownAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotificationHistoryCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('category: $category, ')
          ..write('packageName: $packageName, ')
          ..write('wasTapped: $wasTapped, ')
          ..write('shownAt: $shownAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $InstalledAppsTable installedApps = $InstalledAppsTable(this);
  late final $UsageSessionsTable usageSessions = $UsageSessionsTable(this);
  late final $DailySummariesTable dailySummaries = $DailySummariesTable(this);
  late final $WeeklySummariesTable weeklySummaries = $WeeklySummariesTable(
    this,
  );
  late final $MonthlySummariesTable monthlySummaries = $MonthlySummariesTable(
    this,
  );
  late final $HourlyUsageTable hourlyUsage = $HourlyUsageTable(this);
  late final $AppLimitsTable appLimits = $AppLimitsTable(this);
  late final $FocusSessionsTable focusSessions = $FocusSessionsTable(this);
  late final $NotificationHistoryTable notificationHistory =
      $NotificationHistoryTable(this);
  late final AppsDao appsDao = AppsDao(this as AppDatabase);
  late final SessionsDao sessionsDao = SessionsDao(this as AppDatabase);
  late final SummariesDao summariesDao = SummariesDao(this as AppDatabase);
  late final LimitsDao limitsDao = LimitsDao(this as AppDatabase);
  late final FocusDao focusDao = FocusDao(this as AppDatabase);
  late final NotificationsDao notificationsDao = NotificationsDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    installedApps,
    usageSessions,
    dailySummaries,
    weeklySummaries,
    monthlySummaries,
    hourlyUsage,
    appLimits,
    focusSessions,
    notificationHistory,
  ];
}

typedef $$InstalledAppsTableCreateCompanionBuilder =
    InstalledAppsCompanion Function({
      required String packageName,
      required String appName,
      Value<String?> versionName,
      Value<int?> versionCode,
      Value<String> category,
      Value<bool> isSystemApp,
      Value<bool> isFavorite,
      Value<bool> isPinned,
      Value<bool> isHidden,
      Value<String?> iconCacheKey,
      Value<DateTime?> installTime,
      Value<DateTime?> updateTime,
      Value<DateTime?> lastOpenedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$InstalledAppsTableUpdateCompanionBuilder =
    InstalledAppsCompanion Function({
      Value<String> packageName,
      Value<String> appName,
      Value<String?> versionName,
      Value<int?> versionCode,
      Value<String> category,
      Value<bool> isSystemApp,
      Value<bool> isFavorite,
      Value<bool> isPinned,
      Value<bool> isHidden,
      Value<String?> iconCacheKey,
      Value<DateTime?> installTime,
      Value<DateTime?> updateTime,
      Value<DateTime?> lastOpenedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$InstalledAppsTableFilterComposer
    extends Composer<_$AppDatabase, $InstalledAppsTable> {
  $$InstalledAppsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versionCode => $composableBuilder(
    column: $table.versionCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystemApp => $composableBuilder(
    column: $table.isSystemApp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconCacheKey => $composableBuilder(
    column: $table.iconCacheKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get installTime => $composableBuilder(
    column: $table.installTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstalledAppsTableOrderingComposer
    extends Composer<_$AppDatabase, $InstalledAppsTable> {
  $$InstalledAppsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versionCode => $composableBuilder(
    column: $table.versionCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystemApp => $composableBuilder(
    column: $table.isSystemApp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPinned => $composableBuilder(
    column: $table.isPinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isHidden => $composableBuilder(
    column: $table.isHidden,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconCacheKey => $composableBuilder(
    column: $table.iconCacheKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get installTime => $composableBuilder(
    column: $table.installTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstalledAppsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InstalledAppsTable> {
  $$InstalledAppsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<String> get versionName => $composableBuilder(
    column: $table.versionName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versionCode => $composableBuilder(
    column: $table.versionCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<bool> get isSystemApp => $composableBuilder(
    column: $table.isSystemApp,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<bool> get isHidden =>
      $composableBuilder(column: $table.isHidden, builder: (column) => column);

  GeneratedColumn<String> get iconCacheKey => $composableBuilder(
    column: $table.iconCacheKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get installTime => $composableBuilder(
    column: $table.installTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updateTime => $composableBuilder(
    column: $table.updateTime,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$InstalledAppsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InstalledAppsTable,
          InstalledApp,
          $$InstalledAppsTableFilterComposer,
          $$InstalledAppsTableOrderingComposer,
          $$InstalledAppsTableAnnotationComposer,
          $$InstalledAppsTableCreateCompanionBuilder,
          $$InstalledAppsTableUpdateCompanionBuilder,
          (
            InstalledApp,
            BaseReferences<_$AppDatabase, $InstalledAppsTable, InstalledApp>,
          ),
          InstalledApp,
          PrefetchHooks Function()
        > {
  $$InstalledAppsTableTableManager(_$AppDatabase db, $InstalledAppsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstalledAppsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstalledAppsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstalledAppsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<String?> versionName = const Value.absent(),
                Value<int?> versionCode = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isSystemApp = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<String?> iconCacheKey = const Value.absent(),
                Value<DateTime?> installTime = const Value.absent(),
                Value<DateTime?> updateTime = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledAppsCompanion(
                packageName: packageName,
                appName: appName,
                versionName: versionName,
                versionCode: versionCode,
                category: category,
                isSystemApp: isSystemApp,
                isFavorite: isFavorite,
                isPinned: isPinned,
                isHidden: isHidden,
                iconCacheKey: iconCacheKey,
                installTime: installTime,
                updateTime: updateTime,
                lastOpenedAt: lastOpenedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageName,
                required String appName,
                Value<String?> versionName = const Value.absent(),
                Value<int?> versionCode = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<bool> isSystemApp = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isPinned = const Value.absent(),
                Value<bool> isHidden = const Value.absent(),
                Value<String?> iconCacheKey = const Value.absent(),
                Value<DateTime?> installTime = const Value.absent(),
                Value<DateTime?> updateTime = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstalledAppsCompanion.insert(
                packageName: packageName,
                appName: appName,
                versionName: versionName,
                versionCode: versionCode,
                category: category,
                isSystemApp: isSystemApp,
                isFavorite: isFavorite,
                isPinned: isPinned,
                isHidden: isHidden,
                iconCacheKey: iconCacheKey,
                installTime: installTime,
                updateTime: updateTime,
                lastOpenedAt: lastOpenedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstalledAppsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InstalledAppsTable,
      InstalledApp,
      $$InstalledAppsTableFilterComposer,
      $$InstalledAppsTableOrderingComposer,
      $$InstalledAppsTableAnnotationComposer,
      $$InstalledAppsTableCreateCompanionBuilder,
      $$InstalledAppsTableUpdateCompanionBuilder,
      (
        InstalledApp,
        BaseReferences<_$AppDatabase, $InstalledAppsTable, InstalledApp>,
      ),
      InstalledApp,
      PrefetchHooks Function()
    >;
typedef $$UsageSessionsTableCreateCompanionBuilder =
    UsageSessionsCompanion Function({
      Value<int> id,
      required String packageName,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int?> durationMs,
      required String dayKey,
      Value<bool> isOngoing,
      Value<DateTime> createdAt,
    });
typedef $$UsageSessionsTableUpdateCompanionBuilder =
    UsageSessionsCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int?> durationMs,
      Value<String> dayKey,
      Value<bool> isOngoing,
      Value<DateTime> createdAt,
    });

class $$UsageSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $UsageSessionsTable> {
  $$UsageSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOngoing => $composableBuilder(
    column: $table.isOngoing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsageSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $UsageSessionsTable> {
  $$UsageSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOngoing => $composableBuilder(
    column: $table.isOngoing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsageSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsageSessionsTable> {
  $$UsageSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<bool> get isOngoing =>
      $composableBuilder(column: $table.isOngoing, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UsageSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsageSessionsTable,
          UsageSession,
          $$UsageSessionsTableFilterComposer,
          $$UsageSessionsTableOrderingComposer,
          $$UsageSessionsTableAnnotationComposer,
          $$UsageSessionsTableCreateCompanionBuilder,
          $$UsageSessionsTableUpdateCompanionBuilder,
          (
            UsageSession,
            BaseReferences<_$AppDatabase, $UsageSessionsTable, UsageSession>,
          ),
          UsageSession,
          PrefetchHooks Function()
        > {
  $$UsageSessionsTableTableManager(_$AppDatabase db, $UsageSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsageSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UsageSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UsageSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<bool> isOngoing = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsageSessionsCompanion(
                id: id,
                packageName: packageName,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                dayKey: dayKey,
                isOngoing: isOngoing,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required String dayKey,
                Value<bool> isOngoing = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => UsageSessionsCompanion.insert(
                id: id,
                packageName: packageName,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMs: durationMs,
                dayKey: dayKey,
                isOngoing: isOngoing,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsageSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsageSessionsTable,
      UsageSession,
      $$UsageSessionsTableFilterComposer,
      $$UsageSessionsTableOrderingComposer,
      $$UsageSessionsTableAnnotationComposer,
      $$UsageSessionsTableCreateCompanionBuilder,
      $$UsageSessionsTableUpdateCompanionBuilder,
      (
        UsageSession,
        BaseReferences<_$AppDatabase, $UsageSessionsTable, UsageSession>,
      ),
      UsageSession,
      PrefetchHooks Function()
    >;
typedef $$DailySummariesTableCreateCompanionBuilder =
    DailySummariesCompanion Function({
      Value<int> id,
      required String packageName,
      required String dayKey,
      Value<int> totalDurationMs,
      Value<int> launchCount,
      Value<int> longestSessionMs,
      Value<int> shortestSessionMs,
      Value<DateTime> updatedAt,
    });
typedef $$DailySummariesTableUpdateCompanionBuilder =
    DailySummariesCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> dayKey,
      Value<int> totalDurationMs,
      Value<int> launchCount,
      Value<int> longestSessionMs,
      Value<int> shortestSessionMs,
      Value<DateTime> updatedAt,
    });

class $$DailySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestSessionMs => $composableBuilder(
    column: $table.longestSessionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get shortestSessionMs => $composableBuilder(
    column: $table.shortestSessionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestSessionMs => $composableBuilder(
    column: $table.longestSessionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get shortestSessionMs => $composableBuilder(
    column: $table.shortestSessionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailySummariesTable> {
  $$DailySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestSessionMs => $composableBuilder(
    column: $table.longestSessionMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get shortestSessionMs => $composableBuilder(
    column: $table.shortestSessionMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DailySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailySummariesTable,
          DailySummary,
          $$DailySummariesTableFilterComposer,
          $$DailySummariesTableOrderingComposer,
          $$DailySummariesTableAnnotationComposer,
          $$DailySummariesTableCreateCompanionBuilder,
          $$DailySummariesTableUpdateCompanionBuilder,
          (
            DailySummary,
            BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummary>,
          ),
          DailySummary,
          PrefetchHooks Function()
        > {
  $$DailySummariesTableTableManager(
    _$AppDatabase db,
    $DailySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> launchCount = const Value.absent(),
                Value<int> longestSessionMs = const Value.absent(),
                Value<int> shortestSessionMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailySummariesCompanion(
                id: id,
                packageName: packageName,
                dayKey: dayKey,
                totalDurationMs: totalDurationMs,
                launchCount: launchCount,
                longestSessionMs: longestSessionMs,
                shortestSessionMs: shortestSessionMs,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String dayKey,
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> launchCount = const Value.absent(),
                Value<int> longestSessionMs = const Value.absent(),
                Value<int> shortestSessionMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DailySummariesCompanion.insert(
                id: id,
                packageName: packageName,
                dayKey: dayKey,
                totalDurationMs: totalDurationMs,
                launchCount: launchCount,
                longestSessionMs: longestSessionMs,
                shortestSessionMs: shortestSessionMs,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailySummariesTable,
      DailySummary,
      $$DailySummariesTableFilterComposer,
      $$DailySummariesTableOrderingComposer,
      $$DailySummariesTableAnnotationComposer,
      $$DailySummariesTableCreateCompanionBuilder,
      $$DailySummariesTableUpdateCompanionBuilder,
      (
        DailySummary,
        BaseReferences<_$AppDatabase, $DailySummariesTable, DailySummary>,
      ),
      DailySummary,
      PrefetchHooks Function()
    >;
typedef $$WeeklySummariesTableCreateCompanionBuilder =
    WeeklySummariesCompanion Function({
      Value<int> id,
      required String packageName,
      required String weekKey,
      Value<int> totalDurationMs,
      Value<int> launchCount,
      Value<DateTime> updatedAt,
    });
typedef $$WeeklySummariesTableUpdateCompanionBuilder =
    WeeklySummariesCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> weekKey,
      Value<int> totalDurationMs,
      Value<int> launchCount,
      Value<DateTime> updatedAt,
    });

class $$WeeklySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $WeeklySummariesTable> {
  $$WeeklySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekKey => $composableBuilder(
    column: $table.weekKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeeklySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeeklySummariesTable> {
  $$WeeklySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekKey => $composableBuilder(
    column: $table.weekKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeeklySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeeklySummariesTable> {
  $$WeeklySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekKey =>
      $composableBuilder(column: $table.weekKey, builder: (column) => column);

  GeneratedColumn<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WeeklySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WeeklySummariesTable,
          WeeklySummary,
          $$WeeklySummariesTableFilterComposer,
          $$WeeklySummariesTableOrderingComposer,
          $$WeeklySummariesTableAnnotationComposer,
          $$WeeklySummariesTableCreateCompanionBuilder,
          $$WeeklySummariesTableUpdateCompanionBuilder,
          (
            WeeklySummary,
            BaseReferences<_$AppDatabase, $WeeklySummariesTable, WeeklySummary>,
          ),
          WeeklySummary,
          PrefetchHooks Function()
        > {
  $$WeeklySummariesTableTableManager(
    _$AppDatabase db,
    $WeeklySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeeklySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeeklySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeeklySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> weekKey = const Value.absent(),
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> launchCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeeklySummariesCompanion(
                id: id,
                packageName: packageName,
                weekKey: weekKey,
                totalDurationMs: totalDurationMs,
                launchCount: launchCount,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String weekKey,
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> launchCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => WeeklySummariesCompanion.insert(
                id: id,
                packageName: packageName,
                weekKey: weekKey,
                totalDurationMs: totalDurationMs,
                launchCount: launchCount,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeeklySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WeeklySummariesTable,
      WeeklySummary,
      $$WeeklySummariesTableFilterComposer,
      $$WeeklySummariesTableOrderingComposer,
      $$WeeklySummariesTableAnnotationComposer,
      $$WeeklySummariesTableCreateCompanionBuilder,
      $$WeeklySummariesTableUpdateCompanionBuilder,
      (
        WeeklySummary,
        BaseReferences<_$AppDatabase, $WeeklySummariesTable, WeeklySummary>,
      ),
      WeeklySummary,
      PrefetchHooks Function()
    >;
typedef $$MonthlySummariesTableCreateCompanionBuilder =
    MonthlySummariesCompanion Function({
      Value<int> id,
      required String packageName,
      required String monthKey,
      Value<int> totalDurationMs,
      Value<int> launchCount,
      Value<DateTime> updatedAt,
    });
typedef $$MonthlySummariesTableUpdateCompanionBuilder =
    MonthlySummariesCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> monthKey,
      Value<int> totalDurationMs,
      Value<int> launchCount,
      Value<DateTime> updatedAt,
    });

class $$MonthlySummariesTableFilterComposer
    extends Composer<_$AppDatabase, $MonthlySummariesTable> {
  $$MonthlySummariesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonthlySummariesTableOrderingComposer
    extends Composer<_$AppDatabase, $MonthlySummariesTable> {
  $$MonthlySummariesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get monthKey => $composableBuilder(
    column: $table.monthKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonthlySummariesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonthlySummariesTable> {
  $$MonthlySummariesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get monthKey =>
      $composableBuilder(column: $table.monthKey, builder: (column) => column);

  GeneratedColumn<int> get totalDurationMs => $composableBuilder(
    column: $table.totalDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get launchCount => $composableBuilder(
    column: $table.launchCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MonthlySummariesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonthlySummariesTable,
          MonthlySummary,
          $$MonthlySummariesTableFilterComposer,
          $$MonthlySummariesTableOrderingComposer,
          $$MonthlySummariesTableAnnotationComposer,
          $$MonthlySummariesTableCreateCompanionBuilder,
          $$MonthlySummariesTableUpdateCompanionBuilder,
          (
            MonthlySummary,
            BaseReferences<
              _$AppDatabase,
              $MonthlySummariesTable,
              MonthlySummary
            >,
          ),
          MonthlySummary,
          PrefetchHooks Function()
        > {
  $$MonthlySummariesTableTableManager(
    _$AppDatabase db,
    $MonthlySummariesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthlySummariesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthlySummariesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthlySummariesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> monthKey = const Value.absent(),
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> launchCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MonthlySummariesCompanion(
                id: id,
                packageName: packageName,
                monthKey: monthKey,
                totalDurationMs: totalDurationMs,
                launchCount: launchCount,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String monthKey,
                Value<int> totalDurationMs = const Value.absent(),
                Value<int> launchCount = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => MonthlySummariesCompanion.insert(
                id: id,
                packageName: packageName,
                monthKey: monthKey,
                totalDurationMs: totalDurationMs,
                launchCount: launchCount,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonthlySummariesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonthlySummariesTable,
      MonthlySummary,
      $$MonthlySummariesTableFilterComposer,
      $$MonthlySummariesTableOrderingComposer,
      $$MonthlySummariesTableAnnotationComposer,
      $$MonthlySummariesTableCreateCompanionBuilder,
      $$MonthlySummariesTableUpdateCompanionBuilder,
      (
        MonthlySummary,
        BaseReferences<_$AppDatabase, $MonthlySummariesTable, MonthlySummary>,
      ),
      MonthlySummary,
      PrefetchHooks Function()
    >;
typedef $$HourlyUsageTableCreateCompanionBuilder =
    HourlyUsageCompanion Function({
      Value<int> id,
      required String packageName,
      required String dayKey,
      required int hour,
      Value<int> durationMs,
      Value<DateTime> updatedAt,
    });
typedef $$HourlyUsageTableUpdateCompanionBuilder =
    HourlyUsageCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> dayKey,
      Value<int> hour,
      Value<int> durationMs,
      Value<DateTime> updatedAt,
    });

class $$HourlyUsageTableFilterComposer
    extends Composer<_$AppDatabase, $HourlyUsageTable> {
  $$HourlyUsageTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HourlyUsageTableOrderingComposer
    extends Composer<_$AppDatabase, $HourlyUsageTable> {
  $$HourlyUsageTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hour => $composableBuilder(
    column: $table.hour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HourlyUsageTableAnnotationComposer
    extends Composer<_$AppDatabase, $HourlyUsageTable> {
  $$HourlyUsageTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<int> get hour =>
      $composableBuilder(column: $table.hour, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$HourlyUsageTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HourlyUsageTable,
          HourlyUsageData,
          $$HourlyUsageTableFilterComposer,
          $$HourlyUsageTableOrderingComposer,
          $$HourlyUsageTableAnnotationComposer,
          $$HourlyUsageTableCreateCompanionBuilder,
          $$HourlyUsageTableUpdateCompanionBuilder,
          (
            HourlyUsageData,
            BaseReferences<_$AppDatabase, $HourlyUsageTable, HourlyUsageData>,
          ),
          HourlyUsageData,
          PrefetchHooks Function()
        > {
  $$HourlyUsageTableTableManager(_$AppDatabase db, $HourlyUsageTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HourlyUsageTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HourlyUsageTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HourlyUsageTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<int> hour = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HourlyUsageCompanion(
                id: id,
                packageName: packageName,
                dayKey: dayKey,
                hour: hour,
                durationMs: durationMs,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String dayKey,
                required int hour,
                Value<int> durationMs = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HourlyUsageCompanion.insert(
                id: id,
                packageName: packageName,
                dayKey: dayKey,
                hour: hour,
                durationMs: durationMs,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HourlyUsageTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HourlyUsageTable,
      HourlyUsageData,
      $$HourlyUsageTableFilterComposer,
      $$HourlyUsageTableOrderingComposer,
      $$HourlyUsageTableAnnotationComposer,
      $$HourlyUsageTableCreateCompanionBuilder,
      $$HourlyUsageTableUpdateCompanionBuilder,
      (
        HourlyUsageData,
        BaseReferences<_$AppDatabase, $HourlyUsageTable, HourlyUsageData>,
      ),
      HourlyUsageData,
      PrefetchHooks Function()
    >;
typedef $$AppLimitsTableCreateCompanionBuilder =
    AppLimitsCompanion Function({
      Value<int> id,
      required String packageName,
      required String limitType,
      required int limitDurationMs,
      Value<bool> isEnabled,
      Value<String> actionOnReach,
      Value<int> warnAtMinutesRemaining,
      Value<int> secondaryWarnAtMinutesRemaining,
      Value<DateTime?> customWindowStart,
      Value<DateTime?> customWindowEnd,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$AppLimitsTableUpdateCompanionBuilder =
    AppLimitsCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String> limitType,
      Value<int> limitDurationMs,
      Value<bool> isEnabled,
      Value<String> actionOnReach,
      Value<int> warnAtMinutesRemaining,
      Value<int> secondaryWarnAtMinutesRemaining,
      Value<DateTime?> customWindowStart,
      Value<DateTime?> customWindowEnd,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$AppLimitsTableFilterComposer
    extends Composer<_$AppDatabase, $AppLimitsTable> {
  $$AppLimitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get limitType => $composableBuilder(
    column: $table.limitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get limitDurationMs => $composableBuilder(
    column: $table.limitDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionOnReach => $composableBuilder(
    column: $table.actionOnReach,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get warnAtMinutesRemaining => $composableBuilder(
    column: $table.warnAtMinutesRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get secondaryWarnAtMinutesRemaining => $composableBuilder(
    column: $table.secondaryWarnAtMinutesRemaining,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get customWindowStart => $composableBuilder(
    column: $table.customWindowStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get customWindowEnd => $composableBuilder(
    column: $table.customWindowEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppLimitsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppLimitsTable> {
  $$AppLimitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get limitType => $composableBuilder(
    column: $table.limitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get limitDurationMs => $composableBuilder(
    column: $table.limitDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionOnReach => $composableBuilder(
    column: $table.actionOnReach,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get warnAtMinutesRemaining => $composableBuilder(
    column: $table.warnAtMinutesRemaining,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get secondaryWarnAtMinutesRemaining =>
      $composableBuilder(
        column: $table.secondaryWarnAtMinutesRemaining,
        builder: (column) => ColumnOrderings(column),
      );

  ColumnOrderings<DateTime> get customWindowStart => $composableBuilder(
    column: $table.customWindowStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get customWindowEnd => $composableBuilder(
    column: $table.customWindowEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppLimitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppLimitsTable> {
  $$AppLimitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get limitType =>
      $composableBuilder(column: $table.limitType, builder: (column) => column);

  GeneratedColumn<int> get limitDurationMs => $composableBuilder(
    column: $table.limitDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<String> get actionOnReach => $composableBuilder(
    column: $table.actionOnReach,
    builder: (column) => column,
  );

  GeneratedColumn<int> get warnAtMinutesRemaining => $composableBuilder(
    column: $table.warnAtMinutesRemaining,
    builder: (column) => column,
  );

  GeneratedColumn<int> get secondaryWarnAtMinutesRemaining =>
      $composableBuilder(
        column: $table.secondaryWarnAtMinutesRemaining,
        builder: (column) => column,
      );

  GeneratedColumn<DateTime> get customWindowStart => $composableBuilder(
    column: $table.customWindowStart,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get customWindowEnd => $composableBuilder(
    column: $table.customWindowEnd,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppLimitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppLimitsTable,
          AppLimit,
          $$AppLimitsTableFilterComposer,
          $$AppLimitsTableOrderingComposer,
          $$AppLimitsTableAnnotationComposer,
          $$AppLimitsTableCreateCompanionBuilder,
          $$AppLimitsTableUpdateCompanionBuilder,
          (AppLimit, BaseReferences<_$AppDatabase, $AppLimitsTable, AppLimit>),
          AppLimit,
          PrefetchHooks Function()
        > {
  $$AppLimitsTableTableManager(_$AppDatabase db, $AppLimitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppLimitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppLimitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppLimitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> limitType = const Value.absent(),
                Value<int> limitDurationMs = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<String> actionOnReach = const Value.absent(),
                Value<int> warnAtMinutesRemaining = const Value.absent(),
                Value<int> secondaryWarnAtMinutesRemaining =
                    const Value.absent(),
                Value<DateTime?> customWindowStart = const Value.absent(),
                Value<DateTime?> customWindowEnd = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppLimitsCompanion(
                id: id,
                packageName: packageName,
                limitType: limitType,
                limitDurationMs: limitDurationMs,
                isEnabled: isEnabled,
                actionOnReach: actionOnReach,
                warnAtMinutesRemaining: warnAtMinutesRemaining,
                secondaryWarnAtMinutesRemaining:
                    secondaryWarnAtMinutesRemaining,
                customWindowStart: customWindowStart,
                customWindowEnd: customWindowEnd,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                required String limitType,
                required int limitDurationMs,
                Value<bool> isEnabled = const Value.absent(),
                Value<String> actionOnReach = const Value.absent(),
                Value<int> warnAtMinutesRemaining = const Value.absent(),
                Value<int> secondaryWarnAtMinutesRemaining =
                    const Value.absent(),
                Value<DateTime?> customWindowStart = const Value.absent(),
                Value<DateTime?> customWindowEnd = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppLimitsCompanion.insert(
                id: id,
                packageName: packageName,
                limitType: limitType,
                limitDurationMs: limitDurationMs,
                isEnabled: isEnabled,
                actionOnReach: actionOnReach,
                warnAtMinutesRemaining: warnAtMinutesRemaining,
                secondaryWarnAtMinutesRemaining:
                    secondaryWarnAtMinutesRemaining,
                customWindowStart: customWindowStart,
                customWindowEnd: customWindowEnd,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppLimitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppLimitsTable,
      AppLimit,
      $$AppLimitsTableFilterComposer,
      $$AppLimitsTableOrderingComposer,
      $$AppLimitsTableAnnotationComposer,
      $$AppLimitsTableCreateCompanionBuilder,
      $$AppLimitsTableUpdateCompanionBuilder,
      (AppLimit, BaseReferences<_$AppDatabase, $AppLimitsTable, AppLimit>),
      AppLimit,
      PrefetchHooks Function()
    >;
typedef $$FocusSessionsTableCreateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      required int plannedDurationMs,
      Value<int?> actualDurationMs,
      required String blockedPackagesJson,
      Value<String> status,
      required String dayKey,
      Value<DateTime> createdAt,
    });
typedef $$FocusSessionsTableUpdateCompanionBuilder =
    FocusSessionsCompanion Function({
      Value<int> id,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> plannedDurationMs,
      Value<int?> actualDurationMs,
      Value<String> blockedPackagesJson,
      Value<String> status,
      Value<String> dayKey,
      Value<DateTime> createdAt,
    });

class $$FocusSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get plannedDurationMs => $composableBuilder(
    column: $table.plannedDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualDurationMs => $composableBuilder(
    column: $table.actualDurationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get blockedPackagesJson => $composableBuilder(
    column: $table.blockedPackagesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FocusSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get plannedDurationMs => $composableBuilder(
    column: $table.plannedDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualDurationMs => $composableBuilder(
    column: $table.actualDurationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get blockedPackagesJson => $composableBuilder(
    column: $table.blockedPackagesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FocusSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FocusSessionsTable> {
  $$FocusSessionsTableAnnotationComposer({
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

  GeneratedColumn<int> get plannedDurationMs => $composableBuilder(
    column: $table.plannedDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualDurationMs => $composableBuilder(
    column: $table.actualDurationMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get blockedPackagesJson => $composableBuilder(
    column: $table.blockedPackagesJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FocusSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FocusSessionsTable,
          FocusSession,
          $$FocusSessionsTableFilterComposer,
          $$FocusSessionsTableOrderingComposer,
          $$FocusSessionsTableAnnotationComposer,
          $$FocusSessionsTableCreateCompanionBuilder,
          $$FocusSessionsTableUpdateCompanionBuilder,
          (
            FocusSession,
            BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession>,
          ),
          FocusSession,
          PrefetchHooks Function()
        > {
  $$FocusSessionsTableTableManager(_$AppDatabase db, $FocusSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FocusSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FocusSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FocusSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> plannedDurationMs = const Value.absent(),
                Value<int?> actualDurationMs = const Value.absent(),
                Value<String> blockedPackagesJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => FocusSessionsCompanion(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                plannedDurationMs: plannedDurationMs,
                actualDurationMs: actualDurationMs,
                blockedPackagesJson: blockedPackagesJson,
                status: status,
                dayKey: dayKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                required int plannedDurationMs,
                Value<int?> actualDurationMs = const Value.absent(),
                required String blockedPackagesJson,
                Value<String> status = const Value.absent(),
                required String dayKey,
                Value<DateTime> createdAt = const Value.absent(),
              }) => FocusSessionsCompanion.insert(
                id: id,
                startedAt: startedAt,
                endedAt: endedAt,
                plannedDurationMs: plannedDurationMs,
                actualDurationMs: actualDurationMs,
                blockedPackagesJson: blockedPackagesJson,
                status: status,
                dayKey: dayKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FocusSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FocusSessionsTable,
      FocusSession,
      $$FocusSessionsTableFilterComposer,
      $$FocusSessionsTableOrderingComposer,
      $$FocusSessionsTableAnnotationComposer,
      $$FocusSessionsTableCreateCompanionBuilder,
      $$FocusSessionsTableUpdateCompanionBuilder,
      (
        FocusSession,
        BaseReferences<_$AppDatabase, $FocusSessionsTable, FocusSession>,
      ),
      FocusSession,
      PrefetchHooks Function()
    >;
typedef $$NotificationHistoryTableCreateCompanionBuilder =
    NotificationHistoryCompanion Function({
      Value<int> id,
      required String title,
      required String body,
      required String category,
      Value<String?> packageName,
      Value<bool> wasTapped,
      Value<DateTime> shownAt,
    });
typedef $$NotificationHistoryTableUpdateCompanionBuilder =
    NotificationHistoryCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> body,
      Value<String> category,
      Value<String?> packageName,
      Value<bool> wasTapped,
      Value<DateTime> shownAt,
    });

class $$NotificationHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $NotificationHistoryTable> {
  $$NotificationHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wasTapped => $composableBuilder(
    column: $table.wasTapped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get shownAt => $composableBuilder(
    column: $table.shownAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NotificationHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $NotificationHistoryTable> {
  $$NotificationHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wasTapped => $composableBuilder(
    column: $table.wasTapped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get shownAt => $composableBuilder(
    column: $table.shownAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NotificationHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotificationHistoryTable> {
  $$NotificationHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wasTapped =>
      $composableBuilder(column: $table.wasTapped, builder: (column) => column);

  GeneratedColumn<DateTime> get shownAt =>
      $composableBuilder(column: $table.shownAt, builder: (column) => column);
}

class $$NotificationHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotificationHistoryTable,
          NotificationHistoryData,
          $$NotificationHistoryTableFilterComposer,
          $$NotificationHistoryTableOrderingComposer,
          $$NotificationHistoryTableAnnotationComposer,
          $$NotificationHistoryTableCreateCompanionBuilder,
          $$NotificationHistoryTableUpdateCompanionBuilder,
          (
            NotificationHistoryData,
            BaseReferences<
              _$AppDatabase,
              $NotificationHistoryTable,
              NotificationHistoryData
            >,
          ),
          NotificationHistoryData,
          PrefetchHooks Function()
        > {
  $$NotificationHistoryTableTableManager(
    _$AppDatabase db,
    $NotificationHistoryTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotificationHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotificationHistoryTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$NotificationHistoryTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> packageName = const Value.absent(),
                Value<bool> wasTapped = const Value.absent(),
                Value<DateTime> shownAt = const Value.absent(),
              }) => NotificationHistoryCompanion(
                id: id,
                title: title,
                body: body,
                category: category,
                packageName: packageName,
                wasTapped: wasTapped,
                shownAt: shownAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String body,
                required String category,
                Value<String?> packageName = const Value.absent(),
                Value<bool> wasTapped = const Value.absent(),
                Value<DateTime> shownAt = const Value.absent(),
              }) => NotificationHistoryCompanion.insert(
                id: id,
                title: title,
                body: body,
                category: category,
                packageName: packageName,
                wasTapped: wasTapped,
                shownAt: shownAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NotificationHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotificationHistoryTable,
      NotificationHistoryData,
      $$NotificationHistoryTableFilterComposer,
      $$NotificationHistoryTableOrderingComposer,
      $$NotificationHistoryTableAnnotationComposer,
      $$NotificationHistoryTableCreateCompanionBuilder,
      $$NotificationHistoryTableUpdateCompanionBuilder,
      (
        NotificationHistoryData,
        BaseReferences<
          _$AppDatabase,
          $NotificationHistoryTable,
          NotificationHistoryData
        >,
      ),
      NotificationHistoryData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$InstalledAppsTableTableManager get installedApps =>
      $$InstalledAppsTableTableManager(_db, _db.installedApps);
  $$UsageSessionsTableTableManager get usageSessions =>
      $$UsageSessionsTableTableManager(_db, _db.usageSessions);
  $$DailySummariesTableTableManager get dailySummaries =>
      $$DailySummariesTableTableManager(_db, _db.dailySummaries);
  $$WeeklySummariesTableTableManager get weeklySummaries =>
      $$WeeklySummariesTableTableManager(_db, _db.weeklySummaries);
  $$MonthlySummariesTableTableManager get monthlySummaries =>
      $$MonthlySummariesTableTableManager(_db, _db.monthlySummaries);
  $$HourlyUsageTableTableManager get hourlyUsage =>
      $$HourlyUsageTableTableManager(_db, _db.hourlyUsage);
  $$AppLimitsTableTableManager get appLimits =>
      $$AppLimitsTableTableManager(_db, _db.appLimits);
  $$FocusSessionsTableTableManager get focusSessions =>
      $$FocusSessionsTableTableManager(_db, _db.focusSessions);
  $$NotificationHistoryTableTableManager get notificationHistory =>
      $$NotificationHistoryTableTableManager(_db, _db.notificationHistory);
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wellness_entry_native.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetWellnessEntryCollection on Isar {
  IsarCollection<WellnessEntry> get wellnessEntrys => this.collection();
}

const WellnessEntrySchema = CollectionSchema(
  name: r'WellnessEntry',
  id: -8709916360329735599,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'diarrhea': PropertySchema(
      id: 1,
      name: r'diarrhea',
      type: IsarType.bool,
    ),
    r'gutPeace': PropertySchema(
      id: 2,
      name: r'gutPeace',
      type: IsarType.long,
    ),
    r'heartburn': PropertySchema(
      id: 3,
      name: r'heartburn',
      type: IsarType.long,
    ),
    r'isSample': PropertySchema(
      id: 4,
      name: r'isSample',
      type: IsarType.bool,
    ),
    r'linkedMealIds': PropertySchema(
      id: 5,
      name: r'linkedMealIds',
      type: IsarType.longList,
    ),
    r'notes': PropertySchema(
      id: 6,
      name: r'notes',
      type: IsarType.string,
    ),
    r'recordedAt': PropertySchema(
      id: 7,
      name: r'recordedAt',
      type: IsarType.dateTime,
    ),
    r'wellnessScore': PropertySchema(
      id: 8,
      name: r'wellnessScore',
      type: IsarType.double,
    )
  },
  estimateSize: _wellnessEntryEstimateSize,
  serialize: _wellnessEntrySerialize,
  deserialize: _wellnessEntryDeserialize,
  deserializeProp: _wellnessEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'recordedAt': IndexSchema(
      id: -5046025352082009396,
      name: r'recordedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'recordedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _wellnessEntryGetId,
  getLinks: _wellnessEntryGetLinks,
  attach: _wellnessEntryAttach,
  version: '3.1.0+1',
);

int _wellnessEntryEstimateSize(
  WellnessEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.linkedMealIds.length * 8;
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _wellnessEntrySerialize(
  WellnessEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeBool(offsets[1], object.diarrhea);
  writer.writeLong(offsets[2], object.gutPeace);
  writer.writeLong(offsets[3], object.heartburn);
  writer.writeBool(offsets[4], object.isSample);
  writer.writeLongList(offsets[5], object.linkedMealIds);
  writer.writeString(offsets[6], object.notes);
  writer.writeDateTime(offsets[7], object.recordedAt);
  writer.writeDouble(offsets[8], object.wellnessScore);
}

WellnessEntry _wellnessEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = WellnessEntry();
  object.createdAt = reader.readDateTime(offsets[0]);
  object.diarrhea = reader.readBool(offsets[1]);
  object.gutPeace = reader.readLong(offsets[2]);
  object.heartburn = reader.readLong(offsets[3]);
  object.id = id;
  object.isSample = reader.readBool(offsets[4]);
  object.linkedMealIds = reader.readLongList(offsets[5]) ?? [];
  object.notes = reader.readStringOrNull(offsets[6]);
  object.recordedAt = reader.readDateTime(offsets[7]);
  object.wellnessScore = reader.readDouble(offsets[8]);
  return object;
}

P _wellnessEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readBool(offset)) as P;
    case 2:
      return (reader.readLong(offset)) as P;
    case 3:
      return (reader.readLong(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readLongList(offset) ?? []) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readDateTime(offset)) as P;
    case 8:
      return (reader.readDouble(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _wellnessEntryGetId(WellnessEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _wellnessEntryGetLinks(WellnessEntry object) {
  return [];
}

void _wellnessEntryAttach(
    IsarCollection<dynamic> col, Id id, WellnessEntry object) {
  object.id = id;
}

extension WellnessEntryQueryWhereSort
    on QueryBuilder<WellnessEntry, WellnessEntry, QWhere> {
  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhere> anyRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'recordedAt'),
      );
    });
  }
}

extension WellnessEntryQueryWhere
    on QueryBuilder<WellnessEntry, WellnessEntry, QWhereClause> {
  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause> idNotEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause> idGreaterThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause> idLessThan(
      Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause>
      recordedAtEqualTo(DateTime recordedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'recordedAt',
        value: [recordedAt],
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause>
      recordedAtNotEqualTo(DateTime recordedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [],
              upper: [recordedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [recordedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [recordedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'recordedAt',
              lower: [],
              upper: [recordedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause>
      recordedAtGreaterThan(
    DateTime recordedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [recordedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause>
      recordedAtLessThan(
    DateTime recordedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [],
        upper: [recordedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterWhereClause>
      recordedAtBetween(
    DateTime lowerRecordedAt,
    DateTime upperRecordedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'recordedAt',
        lower: [lowerRecordedAt],
        includeLower: includeLower,
        upper: [upperRecordedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension WellnessEntryQueryFilter
    on QueryBuilder<WellnessEntry, WellnessEntry, QFilterCondition> {
  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      diarrheaEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'diarrhea',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      gutPeaceEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gutPeace',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      gutPeaceGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gutPeace',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      gutPeaceLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gutPeace',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      gutPeaceBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gutPeace',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      heartburnEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'heartburn',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      heartburnGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'heartburn',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      heartburnLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'heartburn',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      heartburnBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'heartburn',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      isSampleEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSample',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsElementEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'linkedMealIds',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsElementGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'linkedMealIds',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsElementLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'linkedMealIds',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsElementBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'linkedMealIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedMealIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedMealIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedMealIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedMealIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedMealIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      linkedMealIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'linkedMealIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'notes',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      recordedAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      recordedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      recordedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'recordedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      recordedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'recordedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      wellnessScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'wellnessScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      wellnessScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'wellnessScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      wellnessScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'wellnessScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterFilterCondition>
      wellnessScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'wellnessScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }
}

extension WellnessEntryQueryObject
    on QueryBuilder<WellnessEntry, WellnessEntry, QFilterCondition> {}

extension WellnessEntryQueryLinks
    on QueryBuilder<WellnessEntry, WellnessEntry, QFilterCondition> {}

extension WellnessEntryQuerySortBy
    on QueryBuilder<WellnessEntry, WellnessEntry, QSortBy> {
  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByDiarrhea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diarrhea', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByDiarrheaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diarrhea', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByGutPeace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPeace', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByGutPeaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPeace', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByHeartburn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartburn', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByHeartburnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartburn', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByIsSample() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByIsSampleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> sortByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByWellnessScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellnessScore', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      sortByWellnessScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellnessScore', Sort.desc);
    });
  }
}

extension WellnessEntryQuerySortThenBy
    on QueryBuilder<WellnessEntry, WellnessEntry, QSortThenBy> {
  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByDiarrhea() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diarrhea', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByDiarrheaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'diarrhea', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByGutPeace() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPeace', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByGutPeaceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gutPeace', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByHeartburn() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartburn', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByHeartburnDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'heartburn', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByIsSample() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByIsSampleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy> thenByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByRecordedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'recordedAt', Sort.desc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByWellnessScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellnessScore', Sort.asc);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QAfterSortBy>
      thenByWellnessScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'wellnessScore', Sort.desc);
    });
  }
}

extension WellnessEntryQueryWhereDistinct
    on QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> {
  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> distinctByDiarrhea() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'diarrhea');
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> distinctByGutPeace() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gutPeace');
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> distinctByHeartburn() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'heartburn');
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> distinctByIsSample() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSample');
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct>
      distinctByLinkedMealIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'linkedMealIds');
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct> distinctByRecordedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'recordedAt');
    });
  }

  QueryBuilder<WellnessEntry, WellnessEntry, QDistinct>
      distinctByWellnessScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'wellnessScore');
    });
  }
}

extension WellnessEntryQueryProperty
    on QueryBuilder<WellnessEntry, WellnessEntry, QQueryProperty> {
  QueryBuilder<WellnessEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<WellnessEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<WellnessEntry, bool, QQueryOperations> diarrheaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'diarrhea');
    });
  }

  QueryBuilder<WellnessEntry, int, QQueryOperations> gutPeaceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gutPeace');
    });
  }

  QueryBuilder<WellnessEntry, int, QQueryOperations> heartburnProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'heartburn');
    });
  }

  QueryBuilder<WellnessEntry, bool, QQueryOperations> isSampleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSample');
    });
  }

  QueryBuilder<WellnessEntry, List<int>, QQueryOperations>
      linkedMealIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'linkedMealIds');
    });
  }

  QueryBuilder<WellnessEntry, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<WellnessEntry, DateTime, QQueryOperations> recordedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'recordedAt');
    });
  }

  QueryBuilder<WellnessEntry, double, QQueryOperations>
      wellnessScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'wellnessScore');
    });
  }
}

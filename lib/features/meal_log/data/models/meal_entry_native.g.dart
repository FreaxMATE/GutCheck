// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal_entry_native.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetMealEntryCollection on Isar {
  IsarCollection<MealEntry> get mealEntrys => this.collection();
}

const MealEntrySchema = CollectionSchema(
  name: r'MealEntry',
  id: 2136597722614945685,
  properties: {
    r'consumedAt': PropertySchema(
      id: 0,
      name: r'consumedAt',
      type: IsarType.dateTime,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'ingredients': PropertySchema(
      id: 2,
      name: r'ingredients',
      type: IsarType.objectList,
      target: r'MealIngredient',
    ),
    r'isSample': PropertySchema(
      id: 3,
      name: r'isSample',
      type: IsarType.bool,
    ),
    r'mealLabel': PropertySchema(
      id: 4,
      name: r'mealLabel',
      type: IsarType.string,
    ),
    r'notes': PropertySchema(
      id: 5,
      name: r'notes',
      type: IsarType.string,
    ),
    r'photoPath': PropertySchema(
      id: 6,
      name: r'photoPath',
      type: IsarType.string,
    )
  },
  estimateSize: _mealEntryEstimateSize,
  serialize: _mealEntrySerialize,
  deserialize: _mealEntryDeserialize,
  deserializeProp: _mealEntryDeserializeProp,
  idName: r'id',
  indexes: {
    r'consumedAt': IndexSchema(
      id: 6740938944004732187,
      name: r'consumedAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'consumedAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {r'MealIngredient': MealIngredientSchema},
  getId: _mealEntryGetId,
  getLinks: _mealEntryGetLinks,
  attach: _mealEntryAttach,
  version: '3.1.0+1',
);

int _mealEntryEstimateSize(
  MealEntry object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.ingredients.length * 3;
  {
    final offsets = allOffsets[MealIngredient]!;
    for (var i = 0; i < object.ingredients.length; i++) {
      final value = object.ingredients[i];
      bytesCount +=
          MealIngredientSchema.estimateSize(value, offsets, allOffsets);
    }
  }
  {
    final value = object.mealLabel;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.notes;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.photoPath;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _mealEntrySerialize(
  MealEntry object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.consumedAt);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeObjectList<MealIngredient>(
    offsets[2],
    allOffsets,
    MealIngredientSchema.serialize,
    object.ingredients,
  );
  writer.writeBool(offsets[3], object.isSample);
  writer.writeString(offsets[4], object.mealLabel);
  writer.writeString(offsets[5], object.notes);
  writer.writeString(offsets[6], object.photoPath);
}

MealEntry _mealEntryDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = MealEntry();
  object.consumedAt = reader.readDateTime(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.id = id;
  object.ingredients = reader.readObjectList<MealIngredient>(
        offsets[2],
        MealIngredientSchema.deserialize,
        allOffsets,
        MealIngredient(),
      ) ??
      [];
  object.isSample = reader.readBool(offsets[3]);
  object.mealLabel = reader.readStringOrNull(offsets[4]);
  object.notes = reader.readStringOrNull(offsets[5]);
  object.photoPath = reader.readStringOrNull(offsets[6]);
  return object;
}

P _mealEntryDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readObjectList<MealIngredient>(
            offset,
            MealIngredientSchema.deserialize,
            allOffsets,
            MealIngredient(),
          ) ??
          []) as P;
    case 3:
      return (reader.readBool(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _mealEntryGetId(MealEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _mealEntryGetLinks(MealEntry object) {
  return [];
}

void _mealEntryAttach(IsarCollection<dynamic> col, Id id, MealEntry object) {
  object.id = id;
}

extension MealEntryQueryWhereSort
    on QueryBuilder<MealEntry, MealEntry, QWhere> {
  QueryBuilder<MealEntry, MealEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhere> anyConsumedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'consumedAt'),
      );
    });
  }
}

extension MealEntryQueryWhere
    on QueryBuilder<MealEntry, MealEntry, QWhereClause> {
  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> idBetween(
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

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> consumedAtEqualTo(
      DateTime consumedAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'consumedAt',
        value: [consumedAt],
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> consumedAtNotEqualTo(
      DateTime consumedAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumedAt',
              lower: [],
              upper: [consumedAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumedAt',
              lower: [consumedAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumedAt',
              lower: [consumedAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'consumedAt',
              lower: [],
              upper: [consumedAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> consumedAtGreaterThan(
    DateTime consumedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'consumedAt',
        lower: [consumedAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> consumedAtLessThan(
    DateTime consumedAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'consumedAt',
        lower: [],
        upper: [consumedAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterWhereClause> consumedAtBetween(
    DateTime lowerConsumedAt,
    DateTime upperConsumedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'consumedAt',
        lower: [lowerConsumedAt],
        includeLower: includeLower,
        upper: [upperConsumedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension MealEntryQueryFilter
    on QueryBuilder<MealEntry, MealEntry, QFilterCondition> {
  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> consumedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'consumedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      consumedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'consumedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> consumedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'consumedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> consumedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'consumedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> createdAtLessThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> createdAtBetween(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> idBetween(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      ingredientsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredients',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      ingredientsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredients',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      ingredientsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredients',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      ingredientsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredients',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      ingredientsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredients',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      ingredientsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'ingredients',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> isSampleEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isSample',
        value: value,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'mealLabel',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      mealLabelIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'mealLabel',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      mealLabelGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'mealLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'mealLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'mealLabel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'mealLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'mealLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'mealLabel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'mealLabel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> mealLabelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'mealLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      mealLabelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'mealLabel',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'notes',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesEqualTo(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesGreaterThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesLessThan(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesBetween(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesStartsWith(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesEndsWith(
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

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'notes',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'notes',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> notesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'notes',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      photoPathIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'photoPath',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      photoPathGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'photoPath',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'photoPath',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'photoPath',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> photoPathIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'photoPath',
        value: '',
      ));
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition>
      photoPathIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'photoPath',
        value: '',
      ));
    });
  }
}

extension MealEntryQueryObject
    on QueryBuilder<MealEntry, MealEntry, QFilterCondition> {
  QueryBuilder<MealEntry, MealEntry, QAfterFilterCondition> ingredientsElement(
      FilterQuery<MealIngredient> q) {
    return QueryBuilder.apply(this, (query) {
      return query.object(q, r'ingredients');
    });
  }
}

extension MealEntryQueryLinks
    on QueryBuilder<MealEntry, MealEntry, QFilterCondition> {}

extension MealEntryQuerySortBy on QueryBuilder<MealEntry, MealEntry, QSortBy> {
  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByConsumedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumedAt', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByConsumedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumedAt', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByIsSample() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByIsSampleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByMealLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealLabel', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByMealLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealLabel', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> sortByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }
}

extension MealEntryQuerySortThenBy
    on QueryBuilder<MealEntry, MealEntry, QSortThenBy> {
  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByConsumedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumedAt', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByConsumedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'consumedAt', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByIsSample() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByIsSampleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isSample', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByMealLabel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealLabel', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByMealLabelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'mealLabel', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByNotes() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByNotesDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'notes', Sort.desc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByPhotoPath() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.asc);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QAfterSortBy> thenByPhotoPathDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'photoPath', Sort.desc);
    });
  }
}

extension MealEntryQueryWhereDistinct
    on QueryBuilder<MealEntry, MealEntry, QDistinct> {
  QueryBuilder<MealEntry, MealEntry, QDistinct> distinctByConsumedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'consumedAt');
    });
  }

  QueryBuilder<MealEntry, MealEntry, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<MealEntry, MealEntry, QDistinct> distinctByIsSample() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isSample');
    });
  }

  QueryBuilder<MealEntry, MealEntry, QDistinct> distinctByMealLabel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'mealLabel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QDistinct> distinctByNotes(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'notes', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<MealEntry, MealEntry, QDistinct> distinctByPhotoPath(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'photoPath', caseSensitive: caseSensitive);
    });
  }
}

extension MealEntryQueryProperty
    on QueryBuilder<MealEntry, MealEntry, QQueryProperty> {
  QueryBuilder<MealEntry, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<MealEntry, DateTime, QQueryOperations> consumedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'consumedAt');
    });
  }

  QueryBuilder<MealEntry, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<MealEntry, List<MealIngredient>, QQueryOperations>
      ingredientsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'ingredients');
    });
  }

  QueryBuilder<MealEntry, bool, QQueryOperations> isSampleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isSample');
    });
  }

  QueryBuilder<MealEntry, String?, QQueryOperations> mealLabelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'mealLabel');
    });
  }

  QueryBuilder<MealEntry, String?, QQueryOperations> notesProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'notes');
    });
  }

  QueryBuilder<MealEntry, String?, QQueryOperations> photoPathProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'photoPath');
    });
  }
}

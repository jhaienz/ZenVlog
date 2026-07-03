// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'persona.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetPersonaCollection on Isar {
  IsarCollection<Persona> get personas => this.collection();
}

const PersonaSchema = CollectionSchema(
  name: r'Persona',
  id: 4221547609351888181,
  properties: {
    r'completedJourneys': PropertySchema(
      id: 0,
      name: r'completedJourneys',
      type: IsarType.long,
    ),
    r'culturalAffinity': PropertySchema(
      id: 1,
      name: r'culturalAffinity',
      type: IsarType.double,
    ),
    r'curiosity': PropertySchema(
      id: 2,
      name: r'curiosity',
      type: IsarType.double,
    ),
    r'natureAffinity': PropertySchema(
      id: 3,
      name: r'natureAffinity',
      type: IsarType.double,
    ),
    r'solitudeNeed': PropertySchema(
      id: 4,
      name: r'solitudeNeed',
      type: IsarType.double,
    ),
    r'stamina': PropertySchema(
      id: 5,
      name: r'stamina',
      type: IsarType.double,
    ),
    r'updatedAt': PropertySchema(
      id: 6,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _personaEstimateSize,
  serialize: _personaSerialize,
  deserialize: _personaDeserialize,
  deserializeProp: _personaDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _personaGetId,
  getLinks: _personaGetLinks,
  attach: _personaAttach,
  version: '3.1.0+1',
);

int _personaEstimateSize(
  Persona object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  return bytesCount;
}

void _personaSerialize(
  Persona object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.completedJourneys);
  writer.writeDouble(offsets[1], object.culturalAffinity);
  writer.writeDouble(offsets[2], object.curiosity);
  writer.writeDouble(offsets[3], object.natureAffinity);
  writer.writeDouble(offsets[4], object.solitudeNeed);
  writer.writeDouble(offsets[5], object.stamina);
  writer.writeDateTime(offsets[6], object.updatedAt);
}

Persona _personaDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Persona();
  object.completedJourneys = reader.readLong(offsets[0]);
  object.culturalAffinity = reader.readDouble(offsets[1]);
  object.curiosity = reader.readDouble(offsets[2]);
  object.id = id;
  object.natureAffinity = reader.readDouble(offsets[3]);
  object.solitudeNeed = reader.readDouble(offsets[4]);
  object.stamina = reader.readDouble(offsets[5]);
  object.updatedAt = reader.readDateTime(offsets[6]);
  return object;
}

P _personaDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLong(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDouble(offset)) as P;
    case 5:
      return (reader.readDouble(offset)) as P;
    case 6:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _personaGetId(Persona object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _personaGetLinks(Persona object) {
  return [];
}

void _personaAttach(IsarCollection<dynamic> col, Id id, Persona object) {
  object.id = id;
}

extension PersonaQueryWhereSort on QueryBuilder<Persona, Persona, QWhere> {
  QueryBuilder<Persona, Persona, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension PersonaQueryWhere on QueryBuilder<Persona, Persona, QWhereClause> {
  QueryBuilder<Persona, Persona, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Persona, Persona, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Persona, Persona, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Persona, Persona, QAfterWhereClause> idBetween(
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
}

extension PersonaQueryFilter
    on QueryBuilder<Persona, Persona, QFilterCondition> {
  QueryBuilder<Persona, Persona, QAfterFilterCondition>
      completedJourneysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'completedJourneys',
        value: value,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition>
      completedJourneysGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'completedJourneys',
        value: value,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition>
      completedJourneysLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'completedJourneys',
        value: value,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition>
      completedJourneysBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'completedJourneys',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> culturalAffinityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'culturalAffinity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition>
      culturalAffinityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'culturalAffinity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition>
      culturalAffinityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'culturalAffinity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> culturalAffinityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'culturalAffinity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> curiosityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'curiosity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> curiosityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'curiosity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> curiosityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'curiosity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> curiosityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'curiosity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Persona, Persona, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Persona, Persona, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Persona, Persona, QAfterFilterCondition> natureAffinityEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'natureAffinity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition>
      natureAffinityGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'natureAffinity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> natureAffinityLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'natureAffinity',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> natureAffinityBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'natureAffinity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> solitudeNeedEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'solitudeNeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> solitudeNeedGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'solitudeNeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> solitudeNeedLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'solitudeNeed',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> solitudeNeedBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'solitudeNeed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> staminaEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'stamina',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> staminaGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'stamina',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> staminaLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'stamina',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> staminaBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'stamina',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Persona, Persona, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension PersonaQueryObject
    on QueryBuilder<Persona, Persona, QFilterCondition> {}

extension PersonaQueryLinks
    on QueryBuilder<Persona, Persona, QFilterCondition> {}

extension PersonaQuerySortBy on QueryBuilder<Persona, Persona, QSortBy> {
  QueryBuilder<Persona, Persona, QAfterSortBy> sortByCompletedJourneys() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedJourneys', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByCompletedJourneysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedJourneys', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByCulturalAffinity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culturalAffinity', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByCulturalAffinityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culturalAffinity', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByCuriosity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'curiosity', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByCuriosityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'curiosity', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByNatureAffinity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'natureAffinity', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByNatureAffinityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'natureAffinity', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortBySolitudeNeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solitudeNeed', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortBySolitudeNeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solitudeNeed', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByStamina() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stamina', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByStaminaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stamina', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PersonaQuerySortThenBy
    on QueryBuilder<Persona, Persona, QSortThenBy> {
  QueryBuilder<Persona, Persona, QAfterSortBy> thenByCompletedJourneys() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedJourneys', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByCompletedJourneysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'completedJourneys', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByCulturalAffinity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culturalAffinity', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByCulturalAffinityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'culturalAffinity', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByCuriosity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'curiosity', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByCuriosityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'curiosity', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByNatureAffinity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'natureAffinity', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByNatureAffinityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'natureAffinity', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenBySolitudeNeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solitudeNeed', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenBySolitudeNeedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'solitudeNeed', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByStamina() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stamina', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByStaminaDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'stamina', Sort.desc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Persona, Persona, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension PersonaQueryWhereDistinct
    on QueryBuilder<Persona, Persona, QDistinct> {
  QueryBuilder<Persona, Persona, QDistinct> distinctByCompletedJourneys() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'completedJourneys');
    });
  }

  QueryBuilder<Persona, Persona, QDistinct> distinctByCulturalAffinity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'culturalAffinity');
    });
  }

  QueryBuilder<Persona, Persona, QDistinct> distinctByCuriosity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'curiosity');
    });
  }

  QueryBuilder<Persona, Persona, QDistinct> distinctByNatureAffinity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'natureAffinity');
    });
  }

  QueryBuilder<Persona, Persona, QDistinct> distinctBySolitudeNeed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'solitudeNeed');
    });
  }

  QueryBuilder<Persona, Persona, QDistinct> distinctByStamina() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'stamina');
    });
  }

  QueryBuilder<Persona, Persona, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension PersonaQueryProperty
    on QueryBuilder<Persona, Persona, QQueryProperty> {
  QueryBuilder<Persona, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Persona, int, QQueryOperations> completedJourneysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'completedJourneys');
    });
  }

  QueryBuilder<Persona, double, QQueryOperations> culturalAffinityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'culturalAffinity');
    });
  }

  QueryBuilder<Persona, double, QQueryOperations> curiosityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'curiosity');
    });
  }

  QueryBuilder<Persona, double, QQueryOperations> natureAffinityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'natureAffinity');
    });
  }

  QueryBuilder<Persona, double, QQueryOperations> solitudeNeedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'solitudeNeed');
    });
  }

  QueryBuilder<Persona, double, QQueryOperations> staminaProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'stamina');
    });
  }

  QueryBuilder<Persona, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}

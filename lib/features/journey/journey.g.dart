// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journey.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetJourneyCollection on Isar {
  IsarCollection<Journey> get journeys => this.collection();
}

const JourneySchema = CollectionSchema(
  name: r'Journey',
  id: -8558722542222695166,
  properties: {
    r'endTime': PropertySchema(
      id: 0,
      name: r'endTime',
      type: IsarType.dateTime,
    ),
    r'spotIds': PropertySchema(
      id: 1,
      name: r'spotIds',
      type: IsarType.stringList,
    ),
    r'startTime': PropertySchema(
      id: 2,
      name: r'startTime',
      type: IsarType.dateTime,
    ),
    r'totalDistanceM': PropertySchema(
      id: 3,
      name: r'totalDistanceM',
      type: IsarType.double,
    ),
    r'trackLats': PropertySchema(
      id: 4,
      name: r'trackLats',
      type: IsarType.doubleList,
    ),
    r'trackLngs': PropertySchema(
      id: 5,
      name: r'trackLngs',
      type: IsarType.doubleList,
    ),
    r'weatherSnapshot': PropertySchema(
      id: 6,
      name: r'weatherSnapshot',
      type: IsarType.string,
    )
  },
  estimateSize: _journeyEstimateSize,
  serialize: _journeySerialize,
  deserialize: _journeyDeserialize,
  deserializeProp: _journeyDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _journeyGetId,
  getLinks: _journeyGetLinks,
  attach: _journeyAttach,
  version: '3.1.0+1',
);

int _journeyEstimateSize(
  Journey object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.spotIds.length * 3;
  {
    for (var i = 0; i < object.spotIds.length; i++) {
      final value = object.spotIds[i];
      bytesCount += value.length * 3;
    }
  }
  bytesCount += 3 + object.trackLats.length * 8;
  bytesCount += 3 + object.trackLngs.length * 8;
  bytesCount += 3 + object.weatherSnapshot.length * 3;
  return bytesCount;
}

void _journeySerialize(
  Journey object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.endTime);
  writer.writeStringList(offsets[1], object.spotIds);
  writer.writeDateTime(offsets[2], object.startTime);
  writer.writeDouble(offsets[3], object.totalDistanceM);
  writer.writeDoubleList(offsets[4], object.trackLats);
  writer.writeDoubleList(offsets[5], object.trackLngs);
  writer.writeString(offsets[6], object.weatherSnapshot);
}

Journey _journeyDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Journey();
  object.endTime = reader.readDateTimeOrNull(offsets[0]);
  object.id = id;
  object.spotIds = reader.readStringList(offsets[1]) ?? [];
  object.startTime = reader.readDateTime(offsets[2]);
  object.totalDistanceM = reader.readDouble(offsets[3]);
  object.trackLats = reader.readDoubleList(offsets[4]) ?? [];
  object.trackLngs = reader.readDoubleList(offsets[5]) ?? [];
  object.weatherSnapshot = reader.readString(offsets[6]);
  return object;
}

P _journeyDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 1:
      return (reader.readStringList(offset) ?? []) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readDouble(offset)) as P;
    case 4:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 5:
      return (reader.readDoubleList(offset) ?? []) as P;
    case 6:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _journeyGetId(Journey object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _journeyGetLinks(Journey object) {
  return [];
}

void _journeyAttach(IsarCollection<dynamic> col, Id id, Journey object) {
  object.id = id;
}

extension JourneyQueryWhereSort on QueryBuilder<Journey, Journey, QWhere> {
  QueryBuilder<Journey, Journey, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension JourneyQueryWhere on QueryBuilder<Journey, Journey, QWhereClause> {
  QueryBuilder<Journey, Journey, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Journey, Journey, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterWhereClause> idBetween(
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

extension JourneyQueryFilter
    on QueryBuilder<Journey, Journey, QFilterCondition> {
  QueryBuilder<Journey, Journey, QAfterFilterCondition> endTimeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> endTimeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endTime',
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> endTimeEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> endTimeGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> endTimeLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> endTimeBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Journey, Journey, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Journey, Journey, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spotIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      spotIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'spotIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'spotIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'spotIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      spotIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'spotIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'spotIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'spotIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'spotIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      spotIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'spotIds',
        value: '',
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      spotIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'spotIds',
        value: '',
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      spotIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> spotIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'spotIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> startTimeEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> startTimeGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> startTimeLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startTime',
        value: value,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> startTimeBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> totalDistanceMEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalDistanceM',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      totalDistanceMGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalDistanceM',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> totalDistanceMLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalDistanceM',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> totalDistanceMBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalDistanceM',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLatsElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackLats',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      trackLatsElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackLats',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      trackLatsElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackLats',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLatsElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackLats',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLatsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLats',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLatsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLats',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLatsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLats',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLatsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLats',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      trackLatsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLats',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLatsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLats',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLngsElementEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'trackLngs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      trackLngsElementGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'trackLngs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      trackLngsElementLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'trackLngs',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLngsElementBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'trackLngs',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLngsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLngs',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLngsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLngs',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLngsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLngs',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLngsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLngs',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      trackLngsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLngs',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> trackLngsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'trackLngs',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> weatherSnapshotEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      weatherSnapshotGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'weatherSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> weatherSnapshotLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'weatherSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> weatherSnapshotBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'weatherSnapshot',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      weatherSnapshotStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'weatherSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> weatherSnapshotEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'weatherSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> weatherSnapshotContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'weatherSnapshot',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition> weatherSnapshotMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'weatherSnapshot',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      weatherSnapshotIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'weatherSnapshot',
        value: '',
      ));
    });
  }

  QueryBuilder<Journey, Journey, QAfterFilterCondition>
      weatherSnapshotIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'weatherSnapshot',
        value: '',
      ));
    });
  }
}

extension JourneyQueryObject
    on QueryBuilder<Journey, Journey, QFilterCondition> {}

extension JourneyQueryLinks
    on QueryBuilder<Journey, Journey, QFilterCondition> {}

extension JourneyQuerySortBy on QueryBuilder<Journey, Journey, QSortBy> {
  QueryBuilder<Journey, Journey, QAfterSortBy> sortByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> sortByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> sortByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> sortByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> sortByTotalDistanceM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceM', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> sortByTotalDistanceMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceM', Sort.desc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> sortByWeatherSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherSnapshot', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> sortByWeatherSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherSnapshot', Sort.desc);
    });
  }
}

extension JourneyQuerySortThenBy
    on QueryBuilder<Journey, Journey, QSortThenBy> {
  QueryBuilder<Journey, Journey, QAfterSortBy> thenByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByEndTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endTime', Sort.desc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByStartTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startTime', Sort.desc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByTotalDistanceM() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceM', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByTotalDistanceMDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalDistanceM', Sort.desc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByWeatherSnapshot() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherSnapshot', Sort.asc);
    });
  }

  QueryBuilder<Journey, Journey, QAfterSortBy> thenByWeatherSnapshotDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'weatherSnapshot', Sort.desc);
    });
  }
}

extension JourneyQueryWhereDistinct
    on QueryBuilder<Journey, Journey, QDistinct> {
  QueryBuilder<Journey, Journey, QDistinct> distinctByEndTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endTime');
    });
  }

  QueryBuilder<Journey, Journey, QDistinct> distinctBySpotIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'spotIds');
    });
  }

  QueryBuilder<Journey, Journey, QDistinct> distinctByStartTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startTime');
    });
  }

  QueryBuilder<Journey, Journey, QDistinct> distinctByTotalDistanceM() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalDistanceM');
    });
  }

  QueryBuilder<Journey, Journey, QDistinct> distinctByTrackLats() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackLats');
    });
  }

  QueryBuilder<Journey, Journey, QDistinct> distinctByTrackLngs() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'trackLngs');
    });
  }

  QueryBuilder<Journey, Journey, QDistinct> distinctByWeatherSnapshot(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'weatherSnapshot',
          caseSensitive: caseSensitive);
    });
  }
}

extension JourneyQueryProperty
    on QueryBuilder<Journey, Journey, QQueryProperty> {
  QueryBuilder<Journey, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Journey, DateTime?, QQueryOperations> endTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endTime');
    });
  }

  QueryBuilder<Journey, List<String>, QQueryOperations> spotIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'spotIds');
    });
  }

  QueryBuilder<Journey, DateTime, QQueryOperations> startTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startTime');
    });
  }

  QueryBuilder<Journey, double, QQueryOperations> totalDistanceMProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalDistanceM');
    });
  }

  QueryBuilder<Journey, List<double>, QQueryOperations> trackLatsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackLats');
    });
  }

  QueryBuilder<Journey, List<double>, QQueryOperations> trackLngsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'trackLngs');
    });
  }

  QueryBuilder<Journey, String, QQueryOperations> weatherSnapshotProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'weatherSnapshot');
    });
  }
}

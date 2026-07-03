// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'spot.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSpotCollection on Isar {
  IsarCollection<Spot> get spots => this.collection();
}

const SpotSchema = CollectionSchema(
  name: r'Spot',
  id: -7509269144347303799,
  properties: {
    r'discoveredAt': PropertySchema(
      id: 0,
      name: r'discoveredAt',
      type: IsarType.dateTime,
    ),
    r'lat': PropertySchema(
      id: 1,
      name: r'lat',
      type: IsarType.double,
    ),
    r'lng': PropertySchema(
      id: 2,
      name: r'lng',
      type: IsarType.double,
    ),
    r'name': PropertySchema(
      id: 3,
      name: r'name',
      type: IsarType.string,
    ),
    r'osmId': PropertySchema(
      id: 4,
      name: r'osmId',
      type: IsarType.string,
    ),
    r'osmTags': PropertySchema(
      id: 5,
      name: r'osmTags',
      type: IsarType.stringList,
    ),
    r'personaScore': PropertySchema(
      id: 6,
      name: r'personaScore',
      type: IsarType.double,
    ),
    r'tagDensity': PropertySchema(
      id: 7,
      name: r'tagDensity',
      type: IsarType.long,
    )
  },
  estimateSize: _spotEstimateSize,
  serialize: _spotSerialize,
  deserialize: _spotDeserialize,
  deserializeProp: _spotDeserializeProp,
  idName: r'id',
  indexes: {
    r'osmId': IndexSchema(
      id: 4686384316130810525,
      name: r'osmId',
      unique: true,
      replace: true,
      properties: [
        IndexPropertySchema(
          name: r'osmId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _spotGetId,
  getLinks: _spotGetLinks,
  attach: _spotAttach,
  version: '3.1.0+1',
);

int _spotEstimateSize(
  Spot object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  bytesCount += 3 + object.osmId.length * 3;
  bytesCount += 3 + object.osmTags.length * 3;
  {
    for (var i = 0; i < object.osmTags.length; i++) {
      final value = object.osmTags[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _spotSerialize(
  Spot object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.discoveredAt);
  writer.writeDouble(offsets[1], object.lat);
  writer.writeDouble(offsets[2], object.lng);
  writer.writeString(offsets[3], object.name);
  writer.writeString(offsets[4], object.osmId);
  writer.writeStringList(offsets[5], object.osmTags);
  writer.writeDouble(offsets[6], object.personaScore);
  writer.writeLong(offsets[7], object.tagDensity);
}

Spot _spotDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Spot();
  object.discoveredAt = reader.readDateTime(offsets[0]);
  object.id = id;
  object.lat = reader.readDouble(offsets[1]);
  object.lng = reader.readDouble(offsets[2]);
  object.name = reader.readString(offsets[3]);
  object.osmId = reader.readString(offsets[4]);
  object.osmTags = reader.readStringList(offsets[5]) ?? [];
  object.personaScore = reader.readDouble(offsets[6]);
  object.tagDensity = reader.readLong(offsets[7]);
  return object;
}

P _spotDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readDouble(offset)) as P;
    case 2:
      return (reader.readDouble(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readString(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? []) as P;
    case 6:
      return (reader.readDouble(offset)) as P;
    case 7:
      return (reader.readLong(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _spotGetId(Spot object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _spotGetLinks(Spot object) {
  return [];
}

void _spotAttach(IsarCollection<dynamic> col, Id id, Spot object) {
  object.id = id;
}

extension SpotByIndex on IsarCollection<Spot> {
  Future<Spot?> getByOsmId(String osmId) {
    return getByIndex(r'osmId', [osmId]);
  }

  Spot? getByOsmIdSync(String osmId) {
    return getByIndexSync(r'osmId', [osmId]);
  }

  Future<bool> deleteByOsmId(String osmId) {
    return deleteByIndex(r'osmId', [osmId]);
  }

  bool deleteByOsmIdSync(String osmId) {
    return deleteByIndexSync(r'osmId', [osmId]);
  }

  Future<List<Spot?>> getAllByOsmId(List<String> osmIdValues) {
    final values = osmIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'osmId', values);
  }

  List<Spot?> getAllByOsmIdSync(List<String> osmIdValues) {
    final values = osmIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'osmId', values);
  }

  Future<int> deleteAllByOsmId(List<String> osmIdValues) {
    final values = osmIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'osmId', values);
  }

  int deleteAllByOsmIdSync(List<String> osmIdValues) {
    final values = osmIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'osmId', values);
  }

  Future<Id> putByOsmId(Spot object) {
    return putByIndex(r'osmId', object);
  }

  Id putByOsmIdSync(Spot object, {bool saveLinks = true}) {
    return putByIndexSync(r'osmId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByOsmId(List<Spot> objects) {
    return putAllByIndex(r'osmId', objects);
  }

  List<Id> putAllByOsmIdSync(List<Spot> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'osmId', objects, saveLinks: saveLinks);
  }
}

extension SpotQueryWhereSort on QueryBuilder<Spot, Spot, QWhere> {
  QueryBuilder<Spot, Spot, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension SpotQueryWhere on QueryBuilder<Spot, Spot, QWhereClause> {
  QueryBuilder<Spot, Spot, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Spot, Spot, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterWhereClause> idBetween(
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

  QueryBuilder<Spot, Spot, QAfterWhereClause> osmIdEqualTo(String osmId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'osmId',
        value: [osmId],
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterWhereClause> osmIdNotEqualTo(String osmId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'osmId',
              lower: [],
              upper: [osmId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'osmId',
              lower: [osmId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'osmId',
              lower: [osmId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'osmId',
              lower: [],
              upper: [osmId],
              includeUpper: false,
            ));
      }
    });
  }
}

extension SpotQueryFilter on QueryBuilder<Spot, Spot, QFilterCondition> {
  QueryBuilder<Spot, Spot, QAfterFilterCondition> discoveredAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'discoveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> discoveredAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'discoveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> discoveredAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'discoveredAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> discoveredAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'discoveredAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Spot, Spot, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Spot, Spot, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Spot, Spot, QAfterFilterCondition> latEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> latGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> latLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lat',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> latBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lat',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> lngEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> lngGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> lngLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lng',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> lngBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lng',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'osmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'osmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'osmId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'osmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'osmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'osmId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'osmId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osmId',
        value: '',
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'osmId',
        value: '',
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osmTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'osmTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'osmTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'osmTags',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'osmTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'osmTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'osmTags',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'osmTags',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'osmTags',
        value: '',
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'osmTags',
        value: '',
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsLengthEqualTo(
      int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'osmTags',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'osmTags',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'osmTags',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'osmTags',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'osmTags',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> osmTagsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'osmTags',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> personaScoreEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'personaScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> personaScoreGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'personaScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> personaScoreLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'personaScore',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> personaScoreBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'personaScore',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> tagDensityEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'tagDensity',
        value: value,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> tagDensityGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'tagDensity',
        value: value,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> tagDensityLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'tagDensity',
        value: value,
      ));
    });
  }

  QueryBuilder<Spot, Spot, QAfterFilterCondition> tagDensityBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'tagDensity',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension SpotQueryObject on QueryBuilder<Spot, Spot, QFilterCondition> {}

extension SpotQueryLinks on QueryBuilder<Spot, Spot, QFilterCondition> {}

extension SpotQuerySortBy on QueryBuilder<Spot, Spot, QSortBy> {
  QueryBuilder<Spot, Spot, QAfterSortBy> sortByDiscoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discoveredAt', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByDiscoveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discoveredAt', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByOsmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osmId', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByOsmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osmId', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByPersonaScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personaScore', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByPersonaScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personaScore', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByTagDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagDensity', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> sortByTagDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagDensity', Sort.desc);
    });
  }
}

extension SpotQuerySortThenBy on QueryBuilder<Spot, Spot, QSortThenBy> {
  QueryBuilder<Spot, Spot, QAfterSortBy> thenByDiscoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discoveredAt', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByDiscoveredAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'discoveredAt', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByLatDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lat', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByLngDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lng', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByOsmId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osmId', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByOsmIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'osmId', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByPersonaScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personaScore', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByPersonaScoreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'personaScore', Sort.desc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByTagDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagDensity', Sort.asc);
    });
  }

  QueryBuilder<Spot, Spot, QAfterSortBy> thenByTagDensityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'tagDensity', Sort.desc);
    });
  }
}

extension SpotQueryWhereDistinct on QueryBuilder<Spot, Spot, QDistinct> {
  QueryBuilder<Spot, Spot, QDistinct> distinctByDiscoveredAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'discoveredAt');
    });
  }

  QueryBuilder<Spot, Spot, QDistinct> distinctByLat() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lat');
    });
  }

  QueryBuilder<Spot, Spot, QDistinct> distinctByLng() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lng');
    });
  }

  QueryBuilder<Spot, Spot, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Spot, Spot, QDistinct> distinctByOsmId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'osmId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Spot, Spot, QDistinct> distinctByOsmTags() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'osmTags');
    });
  }

  QueryBuilder<Spot, Spot, QDistinct> distinctByPersonaScore() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'personaScore');
    });
  }

  QueryBuilder<Spot, Spot, QDistinct> distinctByTagDensity() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'tagDensity');
    });
  }
}

extension SpotQueryProperty on QueryBuilder<Spot, Spot, QQueryProperty> {
  QueryBuilder<Spot, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Spot, DateTime, QQueryOperations> discoveredAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'discoveredAt');
    });
  }

  QueryBuilder<Spot, double, QQueryOperations> latProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lat');
    });
  }

  QueryBuilder<Spot, double, QQueryOperations> lngProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lng');
    });
  }

  QueryBuilder<Spot, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }

  QueryBuilder<Spot, String, QQueryOperations> osmIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'osmId');
    });
  }

  QueryBuilder<Spot, List<String>, QQueryOperations> osmTagsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'osmTags');
    });
  }

  QueryBuilder<Spot, double, QQueryOperations> personaScoreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'personaScore');
    });
  }

  QueryBuilder<Spot, int, QQueryOperations> tagDensityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'tagDensity');
    });
  }
}

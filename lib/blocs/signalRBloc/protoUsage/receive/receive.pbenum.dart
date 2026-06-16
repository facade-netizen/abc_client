// This is a generated file - do not edit.
//
// Generated from receive.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

/// Enums
class StatusType extends $pb.ProtobufEnum {
  static const StatusType ACTIVE =
      StatusType._(0, _omitEnumNames ? '' : 'ACTIVE');
  static const StatusType SUSPENDED =
      StatusType._(1, _omitEnumNames ? '' : 'SUSPENDED');
  static const StatusType SUSPEND =
      StatusType._(2, _omitEnumNames ? '' : 'SUSPEND');
  static const StatusType INACTIVE =
      StatusType._(3, _omitEnumNames ? '' : 'INACTIVE');
  static const StatusType WINNER =
      StatusType._(4, _omitEnumNames ? '' : 'WINNER');
  static const StatusType LOSER =
      StatusType._(5, _omitEnumNames ? '' : 'LOSER');
  static const StatusType REMOVED_VACANT =
      StatusType._(6, _omitEnumNames ? '' : 'REMOVED_VACANT');
  static const StatusType REMOVED =
      StatusType._(7, _omitEnumNames ? '' : 'REMOVED');
  static const StatusType CLOSED =
      StatusType._(8, _omitEnumNames ? '' : 'CLOSED');
  static const StatusType OPEN = StatusType._(9, _omitEnumNames ? '' : 'OPEN');
  static const StatusType VOID = StatusType._(10, _omitEnumNames ? '' : 'VOID');
  static const StatusType SETTLED =
      StatusType._(11, _omitEnumNames ? '' : 'SETTLED');
  static const StatusType VOIDED =
      StatusType._(12, _omitEnumNames ? '' : 'VOIDED');
  static const StatusType OFFLINE =
      StatusType._(13, _omitEnumNames ? '' : 'OFFLINE');
  static const StatusType ONLINE =
      StatusType._(14, _omitEnumNames ? '' : 'ONLINE');
  static const StatusType BALL_RUN =
      StatusType._(15, _omitEnumNames ? '' : 'BALL_RUN');
  static const StatusType SETTLE_PROCESSING =
      StatusType._(16, _omitEnumNames ? '' : 'SETTLE_PROCESSING');
  static const StatusType VOID_PROCESSING =
      StatusType._(17, _omitEnumNames ? '' : 'VOID_PROCESSING');

  static const $core.List<StatusType> values = <StatusType>[
    ACTIVE,
    SUSPENDED,
    SUSPEND,
    INACTIVE,
    WINNER,
    LOSER,
    REMOVED_VACANT,
    REMOVED,
    CLOSED,
    OPEN,
    VOID,
    SETTLED,
    VOIDED,
    OFFLINE,
    ONLINE,
    BALL_RUN,
    SETTLE_PROCESSING,
    VOID_PROCESSING,
  ];

  static final $core.List<StatusType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 17);
  static StatusType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const StatusType._(super.value, super.name);
}

class BettingType extends $pb.ProtobufEnum {
  static const BettingType ODDS =
      BettingType._(0, _omitEnumNames ? '' : 'ODDS');
  static const BettingType LINE =
      BettingType._(1, _omitEnumNames ? '' : 'LINE');
  static const BettingType BOOKMAKER =
      BettingType._(2, _omitEnumNames ? '' : 'BOOKMAKER');

  static const $core.List<BettingType> values = <BettingType>[
    ODDS,
    LINE,
    BOOKMAKER,
  ];

  static final $core.List<BettingType?> _byValue =
      $pb.ProtobufEnum.$_initByValueList(values, 2);
  static BettingType? valueOf($core.int value) =>
      value < 0 || value >= _byValue.length ? null : _byValue[value];

  const BettingType._(super.value, super.name);
}

const $core.bool _omitEnumNames =
    $core.bool.fromEnvironment('protobuf.omit_enum_names');

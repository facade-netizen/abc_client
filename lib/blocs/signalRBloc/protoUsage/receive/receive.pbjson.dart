// This is a generated file - do not edit.
//
// Generated from receive.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports
// ignore_for_file: unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use statusTypeDescriptor instead')
const StatusType$json = {
  '1': 'StatusType',
  '2': [
    {'1': 'ACTIVE', '2': 0},
    {'1': 'SUSPENDED', '2': 1},
    {'1': 'SUSPEND', '2': 2},
    {'1': 'INACTIVE', '2': 3},
    {'1': 'WINNER', '2': 4},
    {'1': 'LOSER', '2': 5},
    {'1': 'REMOVED_VACANT', '2': 6},
    {'1': 'REMOVED', '2': 7},
    {'1': 'CLOSED', '2': 8},
    {'1': 'OPEN', '2': 9},
    {'1': 'VOID', '2': 10},
    {'1': 'SETTLED', '2': 11},
    {'1': 'VOIDED', '2': 12},
    {'1': 'OFFLINE', '2': 13},
    {'1': 'ONLINE', '2': 14},
    {'1': 'BALL_RUN', '2': 15},
    {'1': 'SETTLE_PROCESSING', '2': 16},
    {'1': 'VOID_PROCESSING', '2': 17},
  ],
};

/// Descriptor for `StatusType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List statusTypeDescriptor = $convert.base64Decode(
    'CgpTdGF0dXNUeXBlEgoKBkFDVElWRRAAEg0KCVNVU1BFTkRFRBABEgsKB1NVU1BFTkQQAhIMCg'
    'hJTkFDVElWRRADEgoKBldJTk5FUhAEEgkKBUxPU0VSEAUSEgoOUkVNT1ZFRF9WQUNBTlQQBhIL'
    'CgdSRU1PVkVEEAcSCgoGQ0xPU0VEEAgSCAoET1BFThAJEggKBFZPSUQQChILCgdTRVRUTEVEEA'
    'sSCgoGVk9JREVEEAwSCwoHT0ZGTElORRANEgoKBk9OTElORRAOEgwKCEJBTExfUlVOEA8SFQoR'
    'U0VUVExFX1BST0NFU1NJTkcQEBITCg9WT0lEX1BST0NFU1NJTkcQEQ==');

@$core.Deprecated('Use bettingTypeDescriptor instead')
const BettingType$json = {
  '1': 'BettingType',
  '2': [
    {'1': 'ODDS', '2': 0},
    {'1': 'LINE', '2': 1},
    {'1': 'BOOKMAKER', '2': 2},
  ],
};

/// Descriptor for `BettingType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List bettingTypeDescriptor = $convert.base64Decode(
    'CgtCZXR0aW5nVHlwZRIICgRPRERTEAASCAoETElORRABEg0KCUJPT0tNQUtFUhAC');

@$core.Deprecated('Use aBCModelListDescriptor instead')
const ABCModelList$json = {
  '1': 'ABCModelList',
  '2': [
    {
      '1': 'items',
      '3': 1,
      '4': 3,
      '5': 11,
      '6': '.abc.ABCModel',
      '10': 'items'
    },
  ],
};

/// Descriptor for `ABCModelList`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aBCModelListDescriptor = $convert.base64Decode(
    'CgxBQkNNb2RlbExpc3QSIwoFaXRlbXMYASADKAsyDS5hYmMuQUJDTW9kZWxSBWl0ZW1z');

@$core.Deprecated('Use aBCModelDescriptor instead')
const ABCModel$json = {
  '1': 'ABCModel',
  '2': [
    {'1': 'eventId', '3': 1, '4': 1, '5': 9, '10': 'eventId'},
    {'1': 'marketId', '3': 2, '4': 1, '5': 9, '10': 'marketId'},
    {'1': 'inPlay', '3': 3, '4': 1, '5': 8, '10': 'inPlay'},
    {
      '1': 'runner',
      '3': 4,
      '4': 3,
      '5': 11,
      '6': '.abc.AbcRunner',
      '10': 'runner'
    },
    {
      '1': 'bettingType',
      '3': 5,
      '4': 1,
      '5': 14,
      '6': '.abc.BettingType',
      '10': 'bettingType'
    },
    {'1': 'sportingEvent', '3': 6, '4': 1, '5': 8, '10': 'sportingEvent'},
    {'1': 'marketType', '3': 7, '4': 1, '5': 9, '10': 'marketType'},
    {'1': 'marketName', '3': 8, '4': 1, '5': 9, '10': 'marketName'},
    {
      '1': 'status',
      '3': 9,
      '4': 1,
      '5': 14,
      '6': '.abc.StatusType',
      '10': 'status'
    },
    {'1': 'marketTime', '3': 10, '4': 1, '5': 9, '10': 'marketTime'},
    {
      '1': 'marketCondition',
      '3': 11,
      '4': 1,
      '5': 11,
      '6': '.abc.MarketCondition',
      '10': 'marketCondition'
    },
    {'1': 'sorting', '3': 12, '4': 1, '5': 5, '10': 'sorting'},
  ],
};

/// Descriptor for `ABCModel`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aBCModelDescriptor = $convert.base64Decode(
    'CghBQkNNb2RlbBIYCgdldmVudElkGAEgASgJUgdldmVudElkEhoKCG1hcmtldElkGAIgASgJUg'
    'htYXJrZXRJZBIWCgZpblBsYXkYAyABKAhSBmluUGxheRImCgZydW5uZXIYBCADKAsyDi5hYmMu'
    'QWJjUnVubmVyUgZydW5uZXISMgoLYmV0dGluZ1R5cGUYBSABKA4yEC5hYmMuQmV0dGluZ1R5cG'
    'VSC2JldHRpbmdUeXBlEiQKDXNwb3J0aW5nRXZlbnQYBiABKAhSDXNwb3J0aW5nRXZlbnQSHgoK'
    'bWFya2V0VHlwZRgHIAEoCVIKbWFya2V0VHlwZRIeCgptYXJrZXROYW1lGAggASgJUgptYXJrZX'
    'ROYW1lEicKBnN0YXR1cxgJIAEoDjIPLmFiYy5TdGF0dXNUeXBlUgZzdGF0dXMSHgoKbWFya2V0'
    'VGltZRgKIAEoCVIKbWFya2V0VGltZRI+Cg9tYXJrZXRDb25kaXRpb24YCyABKAsyFC5hYmMuTW'
    'Fya2V0Q29uZGl0aW9uUg9tYXJrZXRDb25kaXRpb24SGAoHc29ydGluZxgMIAEoBVIHc29ydGlu'
    'Zw==');

@$core.Deprecated('Use marketConditionDescriptor instead')
const MarketCondition$json = {
  '1': 'MarketCondition',
  '2': [
    {'1': 'betLock', '3': 1, '4': 1, '5': 8, '10': 'betLock'},
    {'1': 'minBet', '3': 2, '4': 1, '5': 5, '10': 'minBet'},
    {'1': 'maxBet', '3': 3, '4': 1, '5': 5, '10': 'maxBet'},
    {'1': 'maxProfit', '3': 4, '4': 1, '5': 5, '10': 'maxProfit'},
    {'1': 'betDelay', '3': 5, '4': 1, '5': 5, '10': 'betDelay'},
    {'1': 'mtp', '3': 6, '4': 1, '5': 5, '10': 'mtp'},
    {'1': 'allowUnmatchBet', '3': 7, '4': 1, '5': 8, '10': 'allowUnmatchBet'},
    {'1': 'potLimit', '3': 8, '4': 1, '5': 5, '10': 'potLimit'},
    {'1': 'volume', '3': 9, '4': 1, '5': 5, '10': 'volume'},
  ],
};

/// Descriptor for `MarketCondition`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List marketConditionDescriptor = $convert.base64Decode(
    'Cg9NYXJrZXRDb25kaXRpb24SGAoHYmV0TG9jaxgBIAEoCFIHYmV0TG9jaxIWCgZtaW5CZXQYAi'
    'ABKAVSBm1pbkJldBIWCgZtYXhCZXQYAyABKAVSBm1heEJldBIcCgltYXhQcm9maXQYBCABKAVS'
    'CW1heFByb2ZpdBIaCghiZXREZWxheRgFIAEoBVIIYmV0RGVsYXkSEAoDbXRwGAYgASgFUgNtdH'
    'ASKAoPYWxsb3dVbm1hdGNoQmV0GAcgASgIUg9hbGxvd1VubWF0Y2hCZXQSGgoIcG90TGltaXQY'
    'CCABKAVSCHBvdExpbWl0EhYKBnZvbHVtZRgJIAEoBVIGdm9sdW1l');

@$core.Deprecated('Use abcRunnerDescriptor instead')
const AbcRunner$json = {
  '1': 'AbcRunner',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {
      '1': 'backs',
      '3': 2,
      '4': 3,
      '5': 11,
      '6': '.abc.ABCPrice',
      '10': 'backs'
    },
    {'1': 'lays', '3': 3, '4': 3, '5': 11, '6': '.abc.ABCPrice', '10': 'lays'},
    {
      '1': 'status',
      '3': 4,
      '4': 1,
      '5': 14,
      '6': '.abc.StatusType',
      '10': 'status'
    },
    {'1': 'runnerId', '3': 5, '4': 1, '5': 9, '10': 'runnerId'},
  ],
};

/// Descriptor for `AbcRunner`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List abcRunnerDescriptor = $convert.base64Decode(
    'CglBYmNSdW5uZXISEgoEbmFtZRgBIAEoCVIEbmFtZRIjCgViYWNrcxgCIAMoCzINLmFiYy5BQk'
    'NQcmljZVIFYmFja3MSIQoEbGF5cxgDIAMoCzINLmFiYy5BQkNQcmljZVIEbGF5cxInCgZzdGF0'
    'dXMYBCABKA4yDy5hYmMuU3RhdHVzVHlwZVIGc3RhdHVzEhoKCHJ1bm5lcklkGAUgASgJUghydW'
    '5uZXJJZA==');

@$core.Deprecated('Use aBCPriceDescriptor instead')
const ABCPrice$json = {
  '1': 'ABCPrice',
  '2': [
    {'1': 'price', '3': 1, '4': 1, '5': 1, '10': 'price'},
    {'1': 'size', '3': 2, '4': 1, '5': 1, '10': 'size'},
    {'1': 'line', '3': 3, '4': 1, '5': 9, '10': 'line'},
  ],
};

/// Descriptor for `ABCPrice`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List aBCPriceDescriptor = $convert.base64Decode(
    'CghBQkNQcmljZRIUCgVwcmljZRgBIAEoAVIFcHJpY2USEgoEc2l6ZRgCIAEoAVIEc2l6ZRISCg'
    'RsaW5lGAMgASgJUgRsaW5l');

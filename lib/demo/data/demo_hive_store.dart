import 'dart:convert';

import 'package:hive/hive.dart';

import 'demo_seed_data.dart';

class DemoHiveStore {
  DemoHiveStore._();

  static final DemoHiveStore instance = DemoHiveStore._();

  static const String boxName = 'dmx_demo_state_v1';

  Box<dynamic>? _box;

  Future<Box<dynamic>> get box async {
    if (_box != null && _box!.isOpen) return _box!;
    _box = Hive.isBoxOpen(boxName) ? Hive.box<dynamic>(boxName) : await Hive.openBox<dynamic>(boxName);
    return _box!;
  }

  Future<void> ensureReady() async {
    final demoBox = await box;
    if (!demoBox.containsKey('session')) {
      await demoBox.putAll(DemoSeedData.initialState());
    }
  }

  Future<void> resetToSeed() async {
    final demoBox = await box;
    await demoBox.clear();
    await demoBox.putAll(DemoSeedData.initialState());
  }

  Future<void> endSession() async {
    final session = await map('session');
    session['active'] = false;
    await putMap('session', session);
  }

  Future<Map<String, dynamic>> map(String key) async {
    final demoBox = await box;
    return _asMap(demoBox.get(key));
  }

  Future<List<Map<String, dynamic>>> list(String key) async {
    final demoBox = await box;
    return _asMapList(demoBox.get(key));
  }

  Future<void> putMap(String key, Map<String, dynamic> value) async {
    final demoBox = await box;
    await demoBox.put(key, _jsonClone(value));
  }

  Future<void> putList(String key, List<Map<String, dynamic>> value) async {
    final demoBox = await box;
    await demoBox.put(key, _jsonClone(value));
  }

  Future<int> takeNextOrderId() async {
    final demoBox = await box;
    final current = int.tryParse('${demoBox.get('nextOrderId') ?? 9000002}') ?? 9000002;
    await demoBox.put('nextOrderId', current + 1);
    return current;
  }

  Future<Map<String, dynamic>> marketForEvent(String eventId, int bettingType) async {
    if (bettingType == 2) {
      final markets = await map('bookmakerByEvent');
      return _asMap(_asMap(markets[eventId])['data']);
    }
    if (bettingType == 1) {
      final markets = await map('fancyByEvent');
      final eventMarkets = _asMapList(markets[eventId]);
      return eventMarkets.isEmpty ? <String, dynamic>{} : eventMarkets.first;
    }
    final markets = await map('oddsByEvent');
    return _asMap(_asMap(markets[eventId])['data']);
  }

  Future<List<Map<String, dynamic>>> allOrders() async {
    return [...await list('orders'), ...await list('settledOrders')];
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value == null) return <String, dynamic>{};
    final cloned = _jsonClone(value);
    if (cloned is Map) return Map<String, dynamic>.from(cloned);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> _asMapList(dynamic value) {
    if (value == null) return <Map<String, dynamic>>[];
    final cloned = _jsonClone(value);
    if (cloned is List) {
      return cloned.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return <Map<String, dynamic>>[];
  }

  static dynamic _jsonClone(dynamic value) => _normalize(jsonDecode(jsonEncode(value)));

  static dynamic _normalize(dynamic value) {
    if (value is Map) {
      return <String, dynamic>{for (final entry in value.entries) entry.key.toString(): _normalize(entry.value)};
    }
    if (value is List) {
      return value.map(_normalize).toList();
    }
    return value;
  }
}

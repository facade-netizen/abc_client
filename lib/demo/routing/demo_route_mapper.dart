import '../services/demo_session.dart';
import 'demo_routes.dart';

class DemoRouteMapper {
  static String? redirectToDemoIfNeeded(String location) {
    if (!DemoSession.isActive || location.startsWith(DemoRoutes.base)) return null;

    if (location == '/' || location == '/home') return DemoRoutes.home;
    if (location.startsWith('/inplay')) return '${DemoRoutes.base}$location';
    if (location.startsWith('/sport')) return '${DemoRoutes.base}$location';
    if (location.startsWith('/multimarkets')) return DemoRoutes.multimarkets;
    if (location.startsWith('/result')) return '${DemoRoutes.base}$location';
    if (location.startsWith('/account')) return '${DemoRoutes.base}$location';

    return null;
  }

  static String stripDemoPrefix(String location) {
    if (!location.startsWith(DemoRoutes.base)) return location;
    final stripped = location.substring(DemoRoutes.base.length);
    return stripped.isEmpty ? '/home' : stripped;
  }
}

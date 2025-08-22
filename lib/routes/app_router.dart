import 'package:auto_route/auto_route.dart';

@AutoRouterConfig(replaceInRouteName: "Screen|Page,Route")
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [];

  // Root route guards
  @override
  List<AutoRouteGuard> get guards => [];

  @override
  RouteType get defaultRouteType => RouteType.adaptive();
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteState {
  final String currentRoute;

  RouteState({this.currentRoute = '/'});

  RouteState copyWith({String? currentRoute}) {
    return RouteState(
      currentRoute: currentRoute ?? this.currentRoute,
    );
  }
}

class RouteNotifier extends StateNotifier<RouteState> {
  RouteNotifier() : super(RouteState());

  void updateRoute(String route) {
    state = state.copyWith(currentRoute: route);
  }

  void popRoute() {
    // For simplicity, just go to home when popping
    state = state.copyWith(currentRoute: '/');
  }
}

final routeProvider = StateNotifierProvider<RouteNotifier, RouteState>((ref) {
  return RouteNotifier();
});

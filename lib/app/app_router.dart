import 'package:flutter/material.dart';
import 'package:flutter_realtime_object_detection/pages/home_screen.dart';
import 'package:flutter_realtime_object_detection/pages/local_screen.dart';
import 'package:flutter_realtime_object_detection/pages/splash_screen.dart';
import 'package:flutter_realtime_object_detection/services/tensorflow_service.dart';
import 'package:flutter_realtime_object_detection/view_models/home_view_model.dart';
import 'package:flutter_realtime_object_detection/view_models/local_view_model.dart';
import 'package:provider/provider.dart';

class AppRoute {
  static const splashScreen = '/splashScreen';
  static const homeScreen = '/homeScreen';
  static const localScreen = '/localScreen';

  static final AppRoute _instance = AppRoute._private();
  factory AppRoute() => _instance;
  AppRoute._private();

  static Widget createProvider<P extends ChangeNotifier>(
      P Function(BuildContext context) provider,
      Widget child,
      ) {
    return ChangeNotifierProvider<P>(
      create: provider,
      child: child,
    );
  }

  Route<Object>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashScreen:
        return AppPageRoute(builder: (_) => SplashScreen());

      case homeScreen:
        Duration? duration;
        if (settings.arguments is Map<String, dynamic>) {
          final args = settings.arguments as Map<String, dynamic>;
          if (args['isWithoutAnimation'] is bool && args['isWithoutAnimation']) {
            duration = Duration.zero;
          }
        }
        return AppPageRoute(
          appTransitionDuration: duration,
          appSettings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (context) => HomeViewModel(
              context,
              Provider.of<TensorFlowService>(context, listen: false),
            ),
            child: HomeScreen(),
          ),
        );

      case localScreen:
        return AppPageRoute(
          appSettings: settings,
          builder: (context) => ChangeNotifierProvider(
            create: (context) => LocalViewModel(
              context,
              Provider.of<TensorFlowService>(context, listen: false),
            ),
            child: LocalScreen(),
          ),
        );

      default:
        return null;
    }
  }
}

class AppPageRoute extends MaterialPageRoute<Object> {
  final Duration? appTransitionDuration;
  final RouteSettings? appSettings;

  AppPageRoute({
    required WidgetBuilder builder,
    this.appSettings,
    this.appTransitionDuration,
  }) : super(builder: builder, settings: appSettings ?? const RouteSettings());

  @override
  Duration get transitionDuration =>
      appTransitionDuration ?? super.transitionDuration;
}

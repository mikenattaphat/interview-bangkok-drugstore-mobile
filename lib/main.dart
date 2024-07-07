import 'package:bangkok_drugstore_mobile/screens/map_navigate_screen.dart';
import 'package:bangkok_drugstore_mobile/screens/site_list_screen.dart';
import 'package:bangkok_drugstore_mobile/states/mark_state.dart';
import 'package:bangkok_drugstore_mobile/states/site_navigator_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'screens/map_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MarkState()),
        ChangeNotifierProvider(create: (_) => SiteNavigatorState()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangkok Drugstore Mobile',
      theme: ThemeData(
        fontFamily: 'Prompt',
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.normal),
          bodySmall: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal),
          headlineMedium: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.blue),
          // Define other text styles as needed
        ),
      ),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _buildPageRoute(const MapScreen(), settings);
          case '/site-list':
            return _buildPageRoute(const SiteListScreen(), settings);
          case '/map-navigate':
            return _buildPageRoute(const MapNavigateScreen(), settings);
          default:
            return null;
        }
      },
    );
  }

  PageRouteBuilder _buildPageRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }
}

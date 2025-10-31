import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:digilocal/pages/splash_screen.dart';
import 'package:digilocal/pages/portfolioDetailLoader.dart';
import 'firebase_options.dart';

const kWindowsScheme = 'sample';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _linkSubscription = AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        debugPrint('onAppLink: $uri');
        openAppLink(uri);
      }
    });
  }

  void openAppLink(Uri uri) {
    final String? fragment = uri.fragment;
    if (fragment != null && fragment.startsWith('/shops/')) {
      final String portfolioId = fragment.substring('/shops/'.length);
      _navigatorKey.currentState?.pushNamed(fragment);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF4ECDC4),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      title: 'Digi-Local',
      onGenerateRoute: (RouteSettings settings) {
        final String? routeName = settings.name;
        
        // Check if URL has shop route in fragment (for web deep links)
        if (kIsWeb) {
          final uri = Uri.base;
          final fragment = uri.fragment;
          if (fragment.isNotEmpty && fragment.startsWith('/shops/')) {
            final String portfolioId = fragment.substring('/shops/'.length);
            return MaterialPageRoute(
              builder: (context) => PortfolioDetailLoader(portfolioId: portfolioId),
              settings: settings,
            );
          }
        }
        
        // Check if route name has shop path
        if (routeName != null && routeName.startsWith('/shops/')) {
          final String portfolioId = routeName.substring('/shops/'.length);
          return MaterialPageRoute(
            builder: (context) => PortfolioDetailLoader(portfolioId: portfolioId),
            settings: settings,
          );
        }

        // Default to splash screen
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );
      },
    );
  }
}




// colors  for our app:
// orange: #ff7648
//white
// purple: #8f98ff
//pink type : #fe8183
//blue type : #5e83ec
//another pink: #ec5e78
//green: #4dc590
//another blue: #65a5db


//Color(0xffF2F0EF), //off white

//
//
// //this is code is working perfectly and correct (final code for flutter web app)
// //
// import 'dart:async';
// import 'package:app_links/app_links.dart';
// import 'package:digilocal/pages/portfolioDetailLoader.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
//
//
// const kWindowsScheme = 'sample';
//
// void main() async {
//   // Uncomment if you want to register a custom protocol on Windows.
//   // registerProtocolHandler(kWindowsScheme);
//
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(const MyApp());
// }
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   final _navigatorKey = GlobalKey<NavigatorState>();
//   StreamSubscription<Uri>? _linkSubscription;
//
//   @override
//   void initState() {
//     super.initState();
//     initDeepLinks();
//   }
//
//   @override
//   void dispose() {
//     _linkSubscription?.cancel();
//     super.dispose();
//   }
//
//   Future<void> initDeepLinks() async {
//     // Listen for incoming deep links.
//     _linkSubscription = AppLinks().uriLinkStream.listen((Uri? uri) {
//       if (uri != null) {
//         debugPrint('onAppLink: $uri');
//         openAppLink(uri);
//       }
//     });
//   }
//
//   void openAppLink(Uri uri) {
//     // Here we assume that the deep link is in the form:
//     // sample://foo/#/portfolio/PortFolio000017
//     // We use the URL fragment (i.e. the part after the '#') for routing.
//     final String? fragment = uri.fragment;
//     if (fragment != null && fragment.startsWith('/shops/')) {
//       // Extract the portfolio ID from the route.
//       final String portfolioId = fragment.substring('/shops/'.length);
//       _navigatorKey.currentState?.pushNamed(fragment);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: _navigatorKey,
//       initialRoute: "/",
//       onGenerateRoute: (RouteSettings settings) {
//         Widget routeWidget = defaultScreen();
//
//         // Mimic web routing
//         final String? routeName = settings.name;
//         if (routeName != null) {
//           if (routeName.startsWith('/shops/')) {
//             // Extract portfolio ID and return PortfolioDetailLoader
//             final String portfolioId =
//             routeName.substring('/shops/'.length);
//             routeWidget = PortfolioDetailLoader(portfolioId: portfolioId);
//           }
//         }
//
//         return MaterialPageRoute(
//           builder: (context) => routeWidget,
//           settings: settings,
//           fullscreenDialog: true,
//         );
//       },
//     );
//   }
//
//   Widget defaultScreen() {
//     return Scaffold(
//       backgroundColor: Colors.blue,
//       appBar: AppBar(title: const Text('Default Screen')),
//       body: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text("Hello User",style: TextStyle(
//               color: Colors.white,
//               fontSize: 30,
//             ),),
//             const SizedBox(height: 20),
//             buildWindowsUnregisterBtn(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget buildWindowsUnregisterBtn() {
//     if (defaultTargetPlatform == TargetPlatform.windows) {
//       return TextButton(
//         onPressed: () {
//           // Your unregister code here if needed.
//         },
//         child: const Text('Remove Windows protocol registration'),
//       );
//     }
//     return const SizedBox.shrink();
//   }
// }
//
//
//
//

import 'package:economycraft/classes/company.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:economycraft/screens/home_screen.dart';
import 'package:economycraft/screens/error_screen.dart';
import 'package:economycraft/screens/login/login_screen.dart';
import 'package:economycraft/screens/login/signup_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:economycraft/screens/holding/holdings_screen.dart';
import 'package:economycraft/screens/player_overview_screen.dart';
import 'package:economycraft/screens/order/order_selection_screen.dart';
import 'package:economycraft/screens/order/order_company_screen.dart';
import 'package:economycraft/screens/order/order_user_screen.dart';
import 'package:economycraft/screens/market_screen.dart';
import 'package:economycraft/screens/player_profile_screen.dart';
import 'package:economycraft/screens/company/company_page_screen.dart';
import 'package:economycraft/screens/shopping_cart_screen.dart';
import 'package:economycraft/screens/holding/company_page_backend_screen.dart';
import 'package:economycraft/screens/holding/make_new_company_screen.dart';

const supabaseUrl = 'https://ylgfgklcypqtbqrkhsba.supabase.co';
const supabaseKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlsZ2Zna2xjeXBxdGJxcmtoc2JhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU3MDA4NzcsImV4cCI6MjA2MTI3Njg3N30.o3uGNWrn-AFnTZa4eWiTPGDZ01EI_6FjojV3W-mAIoc";

Future<void> main() async {
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
    ),
  );

  runApp(MyApp());
}

final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/', redirect: (_, __) => '/home'),
    GoRoute(
      path: '/home',
      builder: (BuildContext context, GoRouterState state) {
        return const MyHomePage();
      },
      routes: [
        GoRoute(
          path: 'holdings',
          builder: (BuildContext context, GoRouterState state) {
            return const HoldingsScreen();
          },
          routes: [
            GoRoute(
              path: 'backend',
              builder: (BuildContext context, GoRouterState state) {
                final data = state.extra as Company;
                return CompanyPageBackendScreen(company: data);
              },
            ),
            GoRoute(
              path: 'make_new_company',
              builder: (BuildContext context, GoRouterState state) {
                return const MakeNewCompanyScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: 'player_overview',
          builder: (BuildContext context, GoRouterState state) {
            return const PlayerOverviewScreen();
          },
        ),
        GoRoute(
          path: 'orders',
          builder: (BuildContext context, GoRouterState state) {
            return const OrderSelectionScreen();
          },
          routes: [
            GoRoute(
              path: 'company_orders',
              builder: (BuildContext context, GoRouterState state) {
                return const OrderCompanyScreen();
              },
            ),
            GoRoute(
              path: 'user_orders',
              builder: (BuildContext context, GoRouterState state) {
                return const OrderUserScreen();
              },
            ),
          ],
        ),
        GoRoute(
          path: 'market',
          builder: (BuildContext context, GoRouterState state) {
            return const MarketScreen();
          },
          routes: [
            GoRoute(
              path: 'company_page',
              builder: (BuildContext context, GoRouterState state) {
                final data = state.extra as Company;
                return CompanyPageScreen(company: data);
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const PlayerProfileScreen();
          },
        ),
        GoRoute(
          path: 'shopping_cart',
          builder: (BuildContext context, GoRouterState state) {
            return const ShoppingCartScreen();
          },
        ),
      ],
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
      routes: [
        GoRoute(
          path: 'signup',
          builder: (BuildContext context, GoRouterState state) {
            return const SignupScreen();
          },
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    final session = Supabase.instance.client.auth.currentSession;

    final isLoggingIn = state.matchedLocation.startsWith('/login');

    // If user is not logged in, and they're NOT at a login-related route -> redirect to login
    if (session == null && !isLoggingIn) {
      return '/login';
    }

    // If user IS logged in, and they are trying to access a login-related route -> redirect to home
    if (session != null && isLoggingIn) {
      return '/home';
    }

    // No redirect needed
    return null;
  },
  errorBuilder: (context, state) => const ErrorScreen(),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'EconomyCraft',
      routerConfig: _router,
      theme: ThemeData(fontFamily: 'Minecraft'),
    );
  }
}

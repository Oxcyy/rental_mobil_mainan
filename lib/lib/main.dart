import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app_store.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'notification_service.dart'; 
import 'screens/login_screen.dart';

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('id_ID', null);
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStore()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

const kPrimary = Color(0xFF7B1FA2);
const kPrimaryDark = Color(0xFF4A148C);
const kPrimaryLight = Color(0xFFCE93D8);

void showSnackBarWithOK(String message, {Color? backgroundColor}) {
  final isDark = scaffoldMessengerKey.currentContext != null 
      ? Theme.of(scaffoldMessengerKey.currentContext!).brightness == Brightness.dark 
      : false;
  final borderColor = isDark ? Colors.white : Colors.black;

  scaffoldMessengerKey.currentState
    ?..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
      backgroundColor: backgroundColor ?? const Color(0xFFFFF59D), 
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: borderColor, width: 3),
        borderRadius: BorderRadius.circular(8),
      ),
      action: SnackBarAction(
        label: 'OK',
        textColor: Colors.black, 
        onPressed: () => scaffoldMessengerKey.currentState?.hideCurrentSnackBar(),
      ),
    ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'ToyCar Rental',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      themeMode: themeProvider.themeMode,

      // LIGHT THEME
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.light),
        useMaterial3: true,
      ),

      // DARK THEME 
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: ColorScheme.fromSeed(seedColor: kPrimary, brightness: Brightness.dark),
        useMaterial3: true,
      ),

      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final session = snapshot.data?.session;
        if (session != null) {
          return const HomeScreen(); 
        }
        return const LoginScreen();
      },
    );
  }
}
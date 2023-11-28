import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: "assets/.env");
  if (dotenv.get("USE_FIREBASE_EMU", fallback: "false") == "true") {
    await _configureFirebaseAuth();
    await _configureFirebaseNoSQL();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.user});

  final String title;
  final User? user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<ProfileScreen>(
                      builder: (context) => ProfileScreen(
                            appBar: AppBar(
                                title: Text(widget.user?.displayName ??
                                    widget.user?.email ??
                                    "User")),
                            actions: [
                              SignedOutAction((context) {
                                Navigator.of(context).pop();
                              })
                            ],
                            children: [
                              const Divider(),
                              Padding(
                                  padding: const EdgeInsets.all(2),
                                  child: Image.asset(
                                      'assets/images/buildarc-logo.webp'))
                            ],
                          )));
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return SignInScreen(
              providers: [
                EmailAuthProvider(),
                GoogleProvider(clientId: "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")
              ],
              headerBuilder: (context, constraints, shrinkOffset) {
                return Padding(
                    padding: const EdgeInsets.all(20),
                    child: AspectRatio(
                        aspectRatio: 1,
                        child:
                            Image.asset('assets/images/buildarc-logo.webp')));
              },
              subtitleBuilder: (context, action) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: action == AuthAction.signIn
                      ? Text(
                          'Welcome to BuildArc, please sign in to continue.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      : Text(
                          'Welcome to BuildArc, please sign up to continue.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                );
              },
              footerBuilder: (context, action) {
                return Padding(
                    padding: const EdgeInsets.only(top: 32),
                    child: Text(
                      "By signing in, you agree to our Terms of Service and Privacy Policy",
                      style: Theme.of(context).textTheme.bodySmall,
                    ));
              },
              sideBuilder: (context, shrinkOffset) {
                return Padding(
                  padding: const EdgeInsets.all(20),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.asset('assets/images/buildarc-logo.webp'),
                  ),
                );
              },
            );
          }
          return MyHomePage(
              title: 'Flutter Demo Home Page',
              user: FirebaseAuth.instance.currentUser);
        });
  }
}

Future<void> _configureFirebaseAuth() async {
  var host = dotenv.get("FIREBASE_EMU_URL", fallback: "localhost");
  var port = int.parse(dotenv.get("AUTH_EMU_PORT", fallback: "9099"));
  await FirebaseAuth.instance.useAuthEmulator(host, port);
  debugPrint('Using Firebase Auth emulator on: $host:$port');
}

Future<void> _configureFirebaseNoSQL() async {
  var host = dotenv.get("FIREBASE_EMU_URL", fallback: "localhost");
  var port = int.parse(dotenv.get("FIRESTORE_EMU_PORT", fallback: "8080"));
  FirebaseFirestore.instance.useFirestoreEmulator(host, port);
  debugPrint('Using Firebase Firestore emulator on: $host:$port');
}

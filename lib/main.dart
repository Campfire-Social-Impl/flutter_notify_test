import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_notify_test/firebase_options.dart';

AndroidNotificationChannel androidChannel = const AndroidNotificationChannel(
  'firebase messages',
  'push messages',
  importance: Importance.max,
);

RemoteMessage? initialMessage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final messaging = FirebaseMessaging.instance;

  await messaging.requestPermission(
    alert: false,
    announcement: false,
    badge: false,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: false,
  );
  await messaging.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );
  messaging.subscribeToTopic("test");

  final token = await messaging.getToken();
  debugPrint('Token: $token');

  final notificationPlugin = FlutterLocalNotificationsPlugin();
  if (Platform.isAndroid) {
    final androidImpl =
        notificationPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(androidChannel);
    await androidImpl?.requestNotificationsPermission();
  } else if (Platform.isIOS) {}

  notificationPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
    onDidReceiveNotificationResponse: (details) {
      debugPrint('Notification received: ${details.payload}');
    },
  );

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessages);
  FirebaseMessaging.onMessage.listen(handleForegroundMessages);

  initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    debugPrint('Initial message: ${initialMessage!.data}');
  }

  runApp(
    const MyApp(),
  );
}

Future<void> handleBackgroundMessages(RemoteMessage message) async {
  if (message.data.isEmpty) {
    return;
  }

  final notificationPlugin = FlutterLocalNotificationsPlugin();
  await notificationPlugin.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    ),
  );
  notificationPlugin.show(
    0,
    "score : ${message.data['score']}",
    "time : ${message.data['time']}",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'firebase messages',
        'push messages',
        importance: Importance.max,
      ),
    ),
  );
}

void handleForegroundMessages(RemoteMessage message) {
  if (message.data.isEmpty) {
    return;
  }

  final notificationPlugin = FlutterLocalNotificationsPlugin();
  notificationPlugin.show(
    0,
    "score : ${message.data['score']}",
    "time : ${message.data['time']}",
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'firebase messages',
        'push messages',
        importance: Importance.max,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
          MyHomePage(title: 'Flutter Demo Home Page', message: initialMessage),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, this.message});
  final String title;
  final RemoteMessage? message;

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              widget.message != null
                  ? 'Initial message: ${widget.message!.data}'
                  : 'No initial message',
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
      ),
    );
  }
}

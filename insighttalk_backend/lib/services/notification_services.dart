import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:insighttalk_backend/modal/modal_notification.dart';
import 'package:go_router/go_router.dart';

class DsdNotificationService {
  final String _tokenCollection = "fcmTokens";
  final _db = FirebaseFirestore.instance;
  final String uid;
  final BuildContext context;

  DsdNotificationService({required this.uid, required this.context}) {
    print("##........## Notifaction service call huaa ##........##");
    _initializeNotifications();
  }

  _checkToken(String token) async {
    print("##........## token check hone aaya ##........##");
    try {
      var doc = await _db
          .collection(_tokenCollection)
          .where("token", isEqualTo: token)
          .get();
      print(doc.size);
      print("##........## Token shi s check huaa ##........##");
      return doc.size > 0;
    } catch (e) {
      rethrow;
    }
  }

  _sendTokenToServer(String token) async {
    try {
      await _db.collection(_tokenCollection).add({
        "id": uid,
        "token": token,
        "createdAt": FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _initializeNotifications() async {
    print("##........## Initialize notifications ##........##");
    await FirebaseMessaging.instance.requestPermission(provisional: true);
    var token = await FirebaseMessaging.instance.getToken();
    print("##........## FCM Token: $token  ##........##");
    if (token != null) {
      if (!(await _checkToken(token))) {
        print("##........## If k andr aaya ##........##");
        _sendTokenToServer(token);
        print("##........## SendToken bhi chl gya ##........##");
      }
      print("##........## If ke Bahar bhi aa gya ##........##");
      print("Initializing Local Notifications");
      _initializeLocalNotifications();
      print("Before calling _initializeForegroundHandler()");
      _initializeForegroundHandler();
      print("After calling _initializeForegroundHandler()");
    }
  }

  Future<void> _initializeLocalNotifications() async {
    print("##........## Initialize Local notifications ##........##");
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
            'Insight Talk_appointments', 'Important Appointments',
            channelDescription: 'See notifications about your appointments',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    print("##........## Yha kch to set up hua hai ##........##");
    globalNotificationListener?.cancel();
    globalNotificationListener =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      print("kya y call huaaaaaaaaa");
      if ((message.data["actions"] as String?)?.isNotEmpty ?? false) {
        var actions = jsonDecode(message.data["actions"]);

        for (var actionJson in (actions as List<dynamic>)) {
          var action = DsdNotificationAction.fromJson(actionJson);

          if (action.actionType == "link") {
            print("Its a link");
            print(action.toJson());
          }
        }
      }
      if (message.notification != null) {
        await flutterLocalNotificationsPlugin.show(
          Random().nextInt(1000000),
          '${message.notification!.title}',
          '${message.notification!.body}',
          notificationDetails,
        );
      }
    });
  }

  Future<void> _initializeForegroundHandler() async {
    print("Initializing Foreground Handler");
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      print("Initial message received");
      _handleMessage(initialMessage);
    } else {
      print("No initial message found");
    }
    print("Setting up onMessageOpenedApp listener");
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Message opened from background");
      _handleMessage(message);
    });
    print("Foreground Handler setup complete");
  }

  void _handleMessage(RemoteMessage message) {
    if (message.data["actions"] != null) {
      var actions = jsonDecode(message.data["actions"]);
      for (var actionJson in (actions as List<dynamic>)) {
        var action = DsdNotificationAction.fromJson(actionJson);
        if (action.actionType == "link") {
          if (action.actionLink != null) {
            context.push(action.actionLink!);
          }
        }
      }
    }
  }
}

StreamSubscription<RemoteMessage>? globalNotificationListener;
StreamSubscription<RemoteMessage>? globalForegroundNotificationListener;
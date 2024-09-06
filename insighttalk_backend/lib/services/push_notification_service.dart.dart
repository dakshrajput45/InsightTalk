import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DsdPushNotificationService {
  final String endpointFirebaseCloudMessaging = '${dotenv.env['FIREBASE_CLOUD_MESSAGING_URL']}';

  static Future<String> getAcessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": dotenv.env['PROJECT_ID'], // Loaded from .env
      "private_key_id": dotenv.env['PRIVATE_KEY_ID'], // Loaded from .env
      "private_key": dotenv.env['PRIVATE_KEY'], // Loaded from .env
      "client_email": dotenv.env['CLIENT_EMAIL'], // Loaded from .env
      "client_id": dotenv.env['CLIENT_ID'], // Loaded from .env
      "auth_uri": dotenv.env['AUTH_URI'], // Loaded from .env
      "token_uri": dotenv.env['TOKEN_URI'], // Loaded from .env
      "auth_provider_x509_cert_url": dotenv.env['AUTH_PROVIDER_CERT_URL'], // Loaded from .env
      "client_x509_cert_url": dotenv.env['CLIENT_CERT_URL'], // Loaded from .env
    };
    print(serviceAccountJson);

    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    http.Client client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    //get the access token
    auth.AccessCredentials credentials = await auth.obtainAccessCredentialsViaServiceAccount(
        auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes, client);

    client.close();
    return credentials.accessToken.data;
  }

  void sendMessageNotification(String token, String senderName, String text) async {
    final String serverAccessTokenKey = await getAcessToken();

    // String endpointFirebaseCloudMessaging = '${dotenv.env['FIREBASE_CLOUD_MESSAGING_URL']}';

    final Map<String, dynamic> message = {
      "message": {
        "notification": {"title": "New Message from $senderName", "body": text},
        "data": {},
        "token": token
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(message),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification");
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  void sendAppointmentRequest(String token) async {
    final String serverAccessTokenKey = await getAcessToken();

    // String endpointFirebaseCloudMessaging = '${dotenv.env['FIREBASE_CLOUD_MESSAGING_URL']}';

    final Map<String, dynamic> requestNotify = {
      "message": {
        "notification": {"title": "New Appointment Request", "body": ""},
        "data": {},
        "token": token
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(requestNotify),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification");
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }

  void sendAppointmentLinkAdded(String token) async {
    final String serverAccessTokenKey = await getAcessToken();

    // String endpointFirebaseCloudMessaging = '${dotenv.env['FIREBASE_CLOUD_MESSAGING_URL']}';

    final Map<String, dynamic> requestNotify = {
      "message": {

        "notification": {"title": "Your appointment is confirmed and Link is added you can join the meeting on time of appointment","body":""},

        "data": {},
        "token": token
      }
    };

    final http.Response response = await http.post(
      Uri.parse(endpointFirebaseCloudMessaging),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $serverAccessTokenKey'
      },
      body: jsonEncode(requestNotify),
    );

    if (response.statusCode == 200) {
      print("Notification sent successfully");
    } else {
      print("Failed to send notification");
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
  }
}
